import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/application/pdf/pdf_import_service.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_auth.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_repository.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_sync_service.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_local_storage.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/connectivity_service.dart';

/// Notifier verwaltet die in-memory Sammlung handschriftlicher Notizen und
/// synchronisiert sie optional mit Appwrite.
class InkNotesController extends ChangeNotifier {
  /// Erstellt einen neuen [InkNotesController]. Wird sowohl ein
  /// [InkNotesSync] als auch ein [InkNotesAuth] übergeben, werden
  /// Notizen automatisch für angemeldete E-Mail-Nutzer mit Appwrite
  /// synchronisiert.
  InkNotesController({
    InkNotesRepository? repository,
    InkNotesSync? syncService,
    InkNotesAuth? auth,
    ConnectivityService? connectivityService,
    bool enableConnectivityMonitoring = true,
    this.debounceDuration = const Duration(seconds: 3),
  })  : _repository = repository ?? InkNotesRepository(localStorage: InkNotesLocalStorage(), syncService: syncService),
        _auth = auth {
    final authBridge = _auth;
    if (authBridge != null) {
      authBridge.addListener(_handleAuthChanged);
    }
    // Load local notes immediately regardless of auth
    unawaited(_loadLocalNotes());
    // Start connectivity monitoring and auto-sync when online
    if (enableConnectivityMonitoring) {
      _connectivityService = connectivityService ?? ConnectivityService(repository: _repository);
      _connectivityService!.startMonitoring();
      _connectivitySubscription = _connectivityService!.isOnline.listen((online) async {
        if (online && _activeUserId != null) {
          await _repository.syncAll(userId: _activeUserId!);
          await _repository.processQueueOnce(userId: _activeUserId!);
          // reload local notes after sync
          final local = await _repository.getLocalNotes();
          _notes
            ..clear()
            ..addAll(local.where((n) => !_pendingDeletionIds.contains(n.id)))
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          _safelyNotifyListeners();
        }
      });
    }
  }

  final List<InkNote> _notes = [];
  final InkNotesRepository _repository;
  final InkNotesAuth? _auth;
  // Debounce timers to avoid spamming the backend on rapid consecutive edits.
  // Keyed by note id for upserts and by note id for deletes as well.
  final Map<String, Timer> _debounceTimers = {};
  // Caches aggregierte Seitenänderungen, die beim nächsten Sync gesendet
  // werden sollen. `null` kennzeichnet eine vollständige Synchronisation.
  final Map<String, Set<int>?> _pendingPageChanges = <String, Set<int>?>{};
  /// Verzögerung für Debounce-Operationen beim Synchronisieren von Notizen.
  /// Standardmäßig 3 Sekunden; wird nach jeder Änderung für dieselbe Notiz-ID zurückgesetzt.
  final Duration debounceDuration;

  InkNotesRealtimeSubscription? _realtimeSubscription;
  String? _activeUserId;
  bool _applyingRemoteUpdate = false;
  ConnectivityService? _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _foregroundSyncTimer;
  Duration _foregroundSyncInterval = const Duration(minutes: 5);

  // Flüchtige Scroll-Offsets pro Notiz und Seite (nur zur Laufzeit im Speicher)
  final Map<String, Map<int, double>> _scrollOffsets = <String, Map<int, double>>{};

  // PDF-Hintergrundverarbeitung: Speichert IDs von Notizen, die gerade verarbeitet werden
  final Set<String> _pdfProcessingNoteIds = <String>{};

  // Speichert IDs von Notizen, die zum Löschen markiert sind (Debounce),
  // damit sie bei einem Reload nicht wieder auftauchen.
  final Set<String> _pendingDeletionIds = <String>{};

  /// Unveränderliche Sicht auf alle Notizen.
  List<InkNote> get notes => List.unmodifiable(_notes);

  /// Prüft, ob für eine bestimmte Notiz noch PDF-Text extrahiert wird.
  bool isPdfProcessing(String noteId) => _pdfProcessingNoteIds.contains(noteId);

  /// Stream-Controller für PDF-Fortschrittsmeldungen.
  final StreamController<PdfProcessingUpdate> _pdfProgressController =
      StreamController<PdfProcessingUpdate>.broadcast();

  /// Stream von PDF-Verarbeitungs-Updates.
  Stream<PdfProcessingUpdate> get pdfProcessingUpdates => _pdfProgressController.stream;

  /// Liefert den zuletzt bekannten Scroll-Offset für [noteId] und [pageIndex].
  double? getScrollOffset(String noteId, int pageIndex) {
    final Map<int, double>? pages = _scrollOffsets[noteId];
    return pages?[pageIndex];
  }

  /// Setzt den Scroll-Offset für [noteId] und [pageIndex].
  void setScrollOffset(String noteId, int pageIndex, double offset) {
    final Map<int, double> pages = _scrollOffsets.putIfAbsent(noteId, () => <int, double>{});
    pages[pageIndex] = offset;
  }

  /// Legt eine neue leere Notiz an und gibt sie zurück.
  InkNote createEmpty({
    String? title,
    String? parentId,
    NotePaperStyle paperStyle = NotePaperStyle.plain,
  }) {
    final String? cleanedTitle = title?.trim();
    final note = InkNote.empty(
      title: (cleanedTitle?.isEmpty ?? true) ? null : cleanedTitle,
      parentId: parentId,
      paperStyle: paperStyle,
    );
    _notes.insert(0, note);
    _safelyNotifyListeners();
    _syncIfPossible(note, changedPageIndices: const <int>{0});
    return note;
  }

  /// Erstellt eine neue Notiz aus importierten PDF-Seiten.
  ///
  /// [extractedTexts] enthält die extrahierten Texte für jede PDF-Seite.
  /// Für jede Seite wird eine [NotePage] mit leerem Strich-Array und dem
  /// importierten Text als `importedPdfText` erstellt.
  InkNote createFromPdfImport({
    required List<String> extractedTexts,
    String? title,
    NotePaperStyle paperStyle = NotePaperStyle.plain,
  }) {
    final String? cleanedTitle = title?.trim();
    final DateTime now = DateTime.now().toLocal();
    
    final List<NotePage> pages = extractedTexts
        .map((text) => NotePage(
              strokes: const <Stroke>[],
              importedPdfText: text.trim().isEmpty ? null : text.trim(),
            ))
        .toList();

    // Mindestens eine Seite erstellen, falls extractedTexts leer ist
    if (pages.isEmpty) {
      pages.add(NotePage(strokes: const <Stroke>[]));
    }

    final note = InkNote(
      id: now.microsecondsSinceEpoch.toString(),
      title: (cleanedTitle?.isEmpty ?? true) 
          ? InkNote.generateTitle(now) 
          : cleanedTitle!,
      updatedAt: now,
      pages: List<NotePage>.unmodifiable(pages),
      paperStyle: paperStyle,
    );

    _notes.insert(0, note);
    _safelyNotifyListeners();
    
    // Alle Seiten als geändert markieren
    final Set<int> allPageIndices = Set<int>.from(
      List<int>.generate(pages.length, (i) => i),
    );
    _syncIfPossible(note, changedPageIndices: allPageIndices);
    
    return note;
  }

  /// Erstellt eine leere Notiz mit einer Platzhalter-Seite für PDF-Import.
  ///
  /// Die Notiz wird sofort erstellt und kann geöffnet werden. Die PDF-Extraktion
  /// läuft dann im Hintergrund, und die Seiten werden nach dem Aufgaben-Parsing
  /// dynamisch erstellt (eine Seite pro erkannter Aufgabe).
  InkNote createEmptyForPdfImport({
    required int pageCount,
    String? title,
    NotePaperStyle paperStyle = NotePaperStyle.plain,
  }) {
    final String? cleanedTitle = title?.trim();
    final DateTime now = DateTime.now().toLocal();
    
    // Erstelle nur eine Platzhalter-Seite - die finalen Aufgaben-Seiten
    // werden nach dem Parsing dynamisch erstellt
    final List<NotePage> pages = <NotePage>[
      NotePage(strokes: const <Stroke>[]),
    ];

    final note = InkNote(
      id: now.microsecondsSinceEpoch.toString(),
      title: (cleanedTitle?.isEmpty ?? true) 
          ? InkNote.generateTitle(now) 
          : cleanedTitle!,
      updatedAt: now,
      pages: List<NotePage>.unmodifiable(pages),
      paperStyle: paperStyle,
    );

    _notes.insert(0, note);
    _safelyNotifyListeners();
    
    _syncIfPossible(note, changedPageIndices: const <int>{0});
    
    return note;
  }

  /// Startet die PDF-Textextraktion im Hintergrund für eine bereits erstellte Notiz.
  ///
  /// [noteId] ist die ID der Notiz, die aktualisiert werden soll.
  /// [pdfBytes] sind die Bytes der PDF-Datei.
  /// [pdfImportService] ist der Service für die Extraktion.
  ///
  /// Nach der Text-Extraktion werden die erkannten Aufgaben automatisch als
  /// separate Notizseiten angelegt. Während der Verarbeitung ist [isPdfProcessing]
  /// für diese Notiz `true`.
  Future<void> startPdfBackgroundProcessing({
    required String noteId,
    required Uint8List pdfBytes,
    required PdfImportService pdfImportService,
  }) async {
    if (kDebugMode) {
      debugPrint('[PDF] Starting background processing for note: $noteId');
      debugPrint('[PDF] PDF size: ${pdfBytes.length} bytes');
    }
    
    _pdfProcessingNoteIds.add(noteId);
    _safelyNotifyListeners();

    try {
      if (kDebugMode) {
        debugPrint('[PDF] Calling importPdf...');
      }
      final results = await pdfImportService.importPdf(
        pdfBytes: pdfBytes,
        onProgress: (progress) {
          if (kDebugMode) {
            debugPrint(
              '[PDF] Progress: page ${progress.currentPage}/${progress.totalPages}, stage: ${progress.stage}',
            );
          }
          _pdfProgressController.add(PdfProcessingUpdate(
            noteId: noteId,
            currentPage: progress.currentPage,
            totalPages: progress.totalPages,
            stage: progress.stage,
          ));
        },
      );

      if (kDebugMode) {
        debugPrint('[PDF] Import complete! Got ${results.length} pages');
      }

      // Kombiniere den extrahierten Text aller Seiten
      final String combinedText = results
          .map((r) => '--- Seite ${r.pageNumber} ---\n${r.extractedText}')
          .join('\n\n');
      
      if (kDebugMode) {
        debugPrint('[PDF] Combined text length: ${combinedText.length}');
      }

      // Signalisiere Aufgaben-Parsing-Phase
      _pdfProgressController.add(PdfProcessingUpdate(
        noteId: noteId,
        currentPage: results.length,
        totalPages: results.length,
        stage: PdfImportStage.parsingTasks,
      ));

      // Extrahiere Aufgaben aus dem kombinierten Text
      if (kDebugMode) {
        debugPrint('[PDF] Extracting tasks from combined text...');
      }
      final List<String> tasks = await pdfImportService.extractTasksFromText(combinedText);
      if (kDebugMode) {
        debugPrint('[PDF] Found ${tasks.length} tasks');
      }

      // Finde die Notiz
      final idx = _notes.indexWhere((n) => n.id == noteId);
      if (idx == -1) {
        if (kDebugMode) {
          debugPrint('[PDF] Note $noteId not found in list!');
        }
        return;
      }

      final InkNote currentNote = _notes[idx];
      final List<NotePage> updatedPages = <NotePage>[];
      final Set<int> changedPageIndices = <int>{};

      if (tasks.isEmpty) {
        // Keine Aufgaben erkannt - gesamten Text als eine Seite speichern
        if (kDebugMode) {
          debugPrint(
            '[PDF] No tasks found, creating single page with full text',
          );
        }
        updatedPages.add(NotePage(
          strokes: const <Stroke>[],
          importedPdfText: combinedText.trim().isEmpty ? null : combinedText.trim(),
        ));
        changedPageIndices.add(0);
      } else {
        // Für jede Aufgabe eine eigene Seite erstellen
        for (int i = 0; i < tasks.length; i++) {
          final String taskText = tasks[i].trim();
          if (kDebugMode) {
            debugPrint(
              '[PDF] Creating page ${i + 1} for task: ${taskText.substring(0, taskText.length.clamp(0, 50))}...',
            );
          }
          
          updatedPages.add(NotePage(
            strokes: const <Stroke>[],
            importedPdfText: taskText.isEmpty ? null : taskText,
          ));
          changedPageIndices.add(i);
        }
      }

      // Aktualisiere die Notiz mit den neuen Aufgaben-Seiten
      final updatedNote = currentNote.copyWith(
        pages: List<NotePage>.unmodifiable(updatedPages),
        updatedAt: DateTime.now(),
        lastOpenedPageIndex: 0,
      );
      
      if (kDebugMode) {
        debugPrint(
          '[PDF] Upserting note with ${updatedPages.length} task pages',
        );
      }
      upsert(updatedNote, changedPageIndices: changedPageIndices);

      // Sende finales Update mit den erkannten Aufgaben
      _pdfProgressController.add(PdfProcessingUpdate(
        noteId: noteId,
        currentPage: tasks.length,
        totalPages: tasks.length,
        stage: PdfImportStage.parsingTasks,
        parsedTasks: tasks,
      ));

      if (kDebugMode) {
        debugPrint(
          '[PDF] Processing complete! Created ${updatedPages.length} task pages',
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PDF] ERROR: $error');
        debugPrint('[PDF] Stack trace: $stackTrace');
      }
      _pdfProgressController.add(PdfProcessingUpdate(
        noteId: noteId,
        currentPage: 0,
        totalPages: 0,
        stage: PdfImportStage.extracting,
        error: error.toString(),
      ));
    } finally {
      _pdfProcessingNoteIds.remove(noteId);
      _safelyNotifyListeners();
    }
  }

  /// Fügt eine Notiz ein oder aktualisiert sie anhand der ID.
  void upsert(
    InkNote note, {
    bool fromRemote = false,
    Set<int>? changedPageIndices,
  }) {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx == -1) {
      _notes.add(note);
    } else {
      if (!_applyingRemoteUpdate &&
          _notes[idx].updatedAt.isAfter(note.updatedAt)) {
        return;
      }
      _notes[idx] = note;
    }
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _safelyNotifyListeners();
    if (!fromRemote) {
      // Sofort lokal persistieren, damit z. B. lastOpenedPageIndex direkt gesichert ist.
      unawaited(_repository.localStorage.saveNoteLocalOnly(note));
      _syncIfPossible(note, changedPageIndices: changedPageIndices);
    }
  }

  /// Löscht die Notiz mit passender [id].
  void delete(String id, {bool fromRemote = false}) {
    final int before = _notes.length;
    _notes.removeWhere((n) => n.id == id);
    if (_notes.length != before) {
      _pendingPageChanges.remove(id);
      _safelyNotifyListeners();
      if (!fromRemote) {
        _deleteIfPossible(id);
      }
    }
  }

  void _safelyNotifyListeners() {
    if (kDebugMode) {
      debugPrint('[InkNotesController] notifyListeners called');
    }
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  void _handleAuthChanged() {
    final auth = _auth;
    if (auth == null) {
      return;
    }
    if (!auth.isLoggedIn || auth.userId == null) {
      _activeUserId = null;
      unawaited(_realtimeSubscription?.cancel());
      _realtimeSubscription = null;
      return;
    }

    final String email = (auth.email ?? '').trim();
    if (email.isEmpty) {
      _activeUserId = null;
      unawaited(_realtimeSubscription?.cancel());
      _realtimeSubscription = null;
      return;
    }

    final String userId = auth.userId!;
    if (_activeUserId == userId) {
      return;
    }

    _activeUserId = userId;
    unawaited(_synchronizeWithRemote(userId));
  }

  /// Aktiviert einen periodischen Foreground-Sync für Plattformen ohne Workmanager.
  void startForegroundSync({Duration? interval}) {
    _foregroundSyncInterval = interval ?? const Duration(minutes: 5);
    _foregroundSyncTimer?.cancel();
    _foregroundSyncTimer = Timer.periodic(_foregroundSyncInterval, (_) {
      unawaited(_runForegroundSync());
    });
    unawaited(_runForegroundSync());
  }

  Future<void> _synchronizeWithRemote(String userId) async {
    // Initialize repository and try a full sync
    await _repository.init();

    // Load local notes
    final localBefore = await _repository.getLocalNotes();
    _notes
      ..clear()
      ..addAll(localBefore.where((n) => !_pendingDeletionIds.contains(n.id)))
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _safelyNotifyListeners();

    // Trigger repository sync which will attempt to upload pending items and merge
    await _repository.syncAll(userId: userId);

    // After sync, reload local notes
    final localAfter = await _repository.getLocalNotes();
    _notes
      ..clear()
      ..addAll(localAfter.where((n) => !_pendingDeletionIds.contains(n.id)))
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _safelyNotifyListeners();

    // If repository exposes underlying syncService, set up realtime if available
    final service = _repository.syncService;
    if (service != null) {
      await _realtimeSubscription?.cancel();
      _realtimeSubscription = service.observeUserNotes(
        userId: userId,
        onEvent: _handleRemoteEvent,
      );
    }
  }

  void _handleRemoteEvent(InkNotesRemoteEvent event) {
    _applyingRemoteUpdate = true;
    try {
      if (event is InkNotesRemoteUpsert) {
        final incoming = event.note;
        final idx = _notes.indexWhere((n) => n.id == incoming.id);
        if (idx != -1 &&
            _notes[idx].updatedAt.isAfter(incoming.updatedAt)) {
          return;
        }
        upsert(incoming, fromRemote: true);
      } else if (event is InkNotesRemoteDelete) {
        delete(event.noteId, fromRemote: true);
      }
    } finally {
      _applyingRemoteUpdate = false;
    }
  }

  Future<void> _runForegroundSync() async {
    final userId = _activeUserId;
    if (userId == null) return;
    try {
      await _repository.syncAll(userId: userId);
      await _repository.processQueueOnce(userId: userId);
      final local = await _repository.getLocalNotes();
      _notes
        ..clear()
        ..addAll(local.where((n) => !_pendingDeletionIds.contains(n.id)))
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _safelyNotifyListeners();
    } catch (_) {
      // swallow errors to keep foreground sync best-effort on desktop
    }
  }

  void _syncIfPossible(
    InkNote note, {
    Set<int>? changedPageIndices,
  }) {
    final userId = _activeUserId;
    if (userId == null) return;
    // Save locally and schedule repository sync via debounce
    final String id = note.id;
    if (changedPageIndices == null) {
      _pendingPageChanges[id] = null;
    } else {
      final bool hasEntry = _pendingPageChanges.containsKey(id);
      final Set<int>? existing = hasEntry ? _pendingPageChanges[id] : null;
      if (hasEntry && existing == null) {
        // Bereits für vollständigen Sync markiert – keine weiteren Seiten nötig.
      } else {
        final Set<int> merged = Set<int>.from(existing ?? const <int>{})
          ..addAll(changedPageIndices);
        _pendingPageChanges[id] = merged;
      }
    }
    _debounceTimers[id]?.cancel();
    _debounceTimers[id] = Timer(debounceDuration, () {
      _debounceTimers.remove(id);
      final bool hasEntry = _pendingPageChanges.containsKey(id);
      final Set<int>? pagesToSync = hasEntry
          ? _pendingPageChanges.remove(id)
          : changedPageIndices;
      unawaited(
        _repository.upsertNote(
          note,
          userId: userId,
          changedPageIndices: pagesToSync,
        ),
      );
    });
  }

  void _deleteIfPossible(String noteId) {
    final userId = _activeUserId;
    
    // Mark as pending deletion so it doesn't reappear on reload
    _pendingDeletionIds.add(noteId);

    // Debounce deletes as well. If a note is rapidly recreated/updated,
    // cancelling a pending delete avoids accidental data loss.
    _debounceTimers[noteId]?.cancel();
    _debounceTimers[noteId] = Timer(debounceDuration, () {
      _debounceTimers.remove(noteId);
      _pendingDeletionIds.remove(noteId);
      unawaited(_repository.deleteNote(noteId, userId: userId));
    });
  }

  @override
  void dispose() {
    _auth?.removeListener(_handleAuthChanged);
    unawaited(_realtimeSubscription?.cancel());
    unawaited(_connectivitySubscription?.cancel());
    unawaited(_connectivityService?.stopMonitoring());
    unawaited(_pdfProgressController.close());
    _foregroundSyncTimer?.cancel();
    _foregroundSyncTimer = null;
    // Cancel any pending debounce timers to avoid firing network requests
    // after the controller has been disposed.
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _pendingPageChanges.clear();
    _pendingDeletionIds.clear();
    _pdfProcessingNoteIds.clear();
    unawaited(_repository.localStorage.close());
    super.dispose();
  }

  Future<void> _loadLocalNotes() async {
    try {
      await _repository.init();
      final local = await _repository.getLocalNotes();
      _notes
        ..clear()
        ..addAll(local.where((n) => !_pendingDeletionIds.contains(n.id)))
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _safelyNotifyListeners();
    } catch (_) {
      // ignore
    }
  }
}

/// Inherited Scope für Zugriff auf [InkNotesController].
class InkNotesScope extends InheritedNotifier<InkNotesController> {
  /// Erstellt eine neue [InkNotesScope] mit dem gegebenen Controller.
  const InkNotesScope({super.key, required InkNotesController controller, required super.child})
      : super(notifier: controller);

  /// Liefert den [InkNotesController] aus dem Kontext.
  static InkNotesController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<InkNotesScope>();
    assert(scope != null, 'InkNotesScope nicht im Widget-Tree gefunden');
    return scope!.notifier!;
  }

  /// Liefert den [InkNotesController] oder `null`, falls er nicht gefunden wird.
  static InkNotesController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<InkNotesScope>();
    return scope?.notifier;
  }

  @override
  bool updateShouldNotify(covariant InkNotesScope oldWidget) => notifier != oldWidget.notifier;
}
