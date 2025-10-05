import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
    _connectivityService = ConnectivityService(repository: _repository);
    _connectivityService!.startMonitoring();
    _connectivitySubscription = _connectivityService!.isOnline.listen((online) async {
      if (online && _activeUserId != null) {
        await _repository.syncAll(userId: _activeUserId!);
        await _repository.processQueueOnce(userId: _activeUserId!);
        // reload local notes after sync
        _notes
          ..clear()
          ..addAll(await _repository.getLocalNotes())
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        _safelyNotifyListeners();
      }
    });
  }

  final List<InkNote> _notes = [];
  final InkNotesRepository _repository;
  final InkNotesAuth? _auth;
  // Debounce timers to avoid spamming the backend on rapid consecutive edits.
  // Keyed by note id for upserts and by note id for deletes as well.
  final Map<String, Timer> _debounceTimers = {};
  /// Verzögerung für Debounce-Operationen beim Synchronisieren von Notizen.
  /// Standardmäßig 3 Sekunden; wird nach jeder Änderung für dieselbe Notiz-ID zurückgesetzt.
  final Duration debounceDuration;

  InkNotesRealtimeSubscription? _realtimeSubscription;
  String? _activeUserId;
  bool _applyingRemoteUpdate = false;
  ConnectivityService? _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;

  /// Unveränderliche Sicht auf alle Notizen.
  List<InkNote> get notes => List.unmodifiable(_notes);

  /// Legt eine neue leere Notiz an und gibt sie zurück.
  InkNote createEmpty({
    String? title,
    NotePaperStyle paperStyle = NotePaperStyle.plain,
  }) {
    final String? cleanedTitle = title?.trim();
    final note = InkNote.empty(
      title: (cleanedTitle?.isEmpty ?? true) ? null : cleanedTitle,
      paperStyle: paperStyle,
    );
    _notes.insert(0, note);
    _safelyNotifyListeners();
    _syncIfPossible(note);
    return note;
  }

  /// Fügt eine Notiz ein oder aktualisiert sie anhand der ID.
  void upsert(InkNote note, {bool fromRemote = false}) {
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
      _syncIfPossible(note);
    }
  }

  /// Löscht die Notiz mit passender [id].
  void delete(String id, {bool fromRemote = false}) {
    final int before = _notes.length;
    _notes.removeWhere((n) => n.id == id);
    if (_notes.length != before) {
      _safelyNotifyListeners();
      if (!fromRemote) {
        _deleteIfPossible(id);
      }
    }
  }

  void _safelyNotifyListeners() {
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

  Future<void> _synchronizeWithRemote(String userId) async {
    // Initialize repository and try a full sync
    await _repository.init();

    // Load local notes
    _notes
      ..clear()
      ..addAll(await _repository.getLocalNotes())
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _safelyNotifyListeners();

    // Trigger repository sync which will attempt to upload pending items and merge
    await _repository.syncAll(userId: userId);

    // After sync, reload local notes
    _notes
      ..clear()
      ..addAll(await _repository.getLocalNotes())
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

  void _syncIfPossible(InkNote note) {
    final userId = _activeUserId;
    if (userId == null) return;
    // Save locally and schedule repository sync via debounce
    final String id = note.id;
    _debounceTimers[id]?.cancel();
    _debounceTimers[id] = Timer(debounceDuration, () {
      _debounceTimers.remove(id);
      unawaited(_repository.upsertNote(note, userId: userId));
    });
  }

  void _deleteIfPossible(String noteId) {
    final userId = _activeUserId;
    if (userId == null) return;
    // Debounce deletes as well. If a note is rapidly recreated/updated,
    // cancelling a pending delete avoids accidental data loss.
    _debounceTimers[noteId]?.cancel();
    _debounceTimers[noteId] = Timer(debounceDuration, () {
      _debounceTimers.remove(noteId);
      unawaited(_repository.deleteNote(noteId, userId: userId));
    });
  }

  @override
  void dispose() {
    _auth?.removeListener(_handleAuthChanged);
    unawaited(_realtimeSubscription?.cancel());
    unawaited(_connectivitySubscription?.cancel());
    unawaited(_connectivityService?.stopMonitoring());
    // Cancel any pending debounce timers to avoid firing network requests
    // after the controller has been disposed.
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    super.dispose();
  }

  Future<void> _loadLocalNotes() async {
    try {
      await _repository.init();
      _notes
        ..clear()
        ..addAll(await _repository.getLocalNotes())
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
