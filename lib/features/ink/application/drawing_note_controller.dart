import 'dart:async';
import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/domain/assistant_message.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_tool_preferences_repository.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/foundation.dart';

/// Verwaltet den Zustand einer geöffneten Zeichennotiz, inklusive Werkzeuge,
/// Persistenz und Delegation an den `DrawingController`.
class DrawingNoteController extends ChangeNotifier {
  /// Erstellt einen neuen [DrawingNoteController] für die Notiz mit [noteId].
  DrawingNoteController({
    required this.noteId,
    required InkNotesController inkNotesController,
    DrawingController? drawingController,
    DrawingToolPreferencesRepository? toolPreferencesRepository,
    List<DrawingTool>? defaultTools,
  }) : _inkNotesController = inkNotesController,
       drawingController = drawingController ?? DrawingController(),
       _toolPreferencesRepository =
           toolPreferencesRepository ?? DrawingToolPreferencesRepository(),
       _defaultTools = defaultTools ?? DrawingToolDefaults.palette;

  /// ID der verwalteten Notiz.
  final String noteId;

  /// Zugriff auf die übergeordnete Notizverwaltung.
  final InkNotesController _inkNotesController;

  /// Repository zum Persistieren von Werkzeugkonfigurationen.
  final DrawingToolPreferencesRepository _toolPreferencesRepository;

  /// Standardwerkzeuge, falls keine gespeicherten vorhanden sind.
  final List<DrawingTool> _defaultTools;

  /// Controller für die Zeichenfläche.
  final DrawingController drawingController;

  late InkNote _note;
  late int _currentPageIndex;
  List<DrawingTool> _tools = const [];
  late String _selectedToolId;
  bool _initialized = false;
  bool _toolsLoaded = false;

  /// Gibt an, ob der Controller vollständig initialisiert wurde.
  bool get isInitialized => _initialized;
  /// Gibt an, ob die Werkzeuge aus dem Repository geladen wurden.
  bool get toolsLoaded => _toolsLoaded;

  /// Die aktuell bearbeitete Notiz.
  InkNote get note => _note;

  /// Alle Seiten der aktuellen Notiz.
  List<NotePage> get pages => List<NotePage>.unmodifiable(_note.pages);

  /// Historie des Assistenten auf der aktuellen Seite.
  List<AssistantMessage> get currentAssistantHistory {
    if (_note.pages.isEmpty) {
      return const <AssistantMessage>[];
    }
    return _note.pages[_currentPageIndex].assistantHistory;
  }

  /// Index der aktuell aktiven Seite.
  int get currentPageIndex => _currentPageIndex;

  /// Die verfügbaren Werkzeuge als unveränderliche Liste.
  List<DrawingTool> get tools => List.unmodifiable(_tools);

  /// ID des aktuell ausgewählten Werkzeugs.
  String get selectedToolId => _selectedToolId;

  /// Liefert das aktuell verwendete Werkzeug.
  DrawingTool get currentTool => resolveTool(_selectedToolId);

  /// Liefert das Werkzeug mit der angegebenen [toolId] oder einen Fallback.
  DrawingTool resolveTool(String? toolId) {
    if (_tools.isEmpty) {
      return _defaultTools.first;
    }
    if (toolId == null) {
      return _tools.first;
    }
    final int index = _tools.indexWhere((tool) => tool.id == toolId);
    if (index == -1) {
      return _tools.first;
    }
    return _tools[index];
  }

  /// Berechnet den Radierer-Radius basierend auf der Werkzeugbreite.
  double eraserRadiusFor(DrawingTool tool) => math.max(tool.baseWidth * 0.6, 8);

  /// Führt die asynchrone Initialisierung der Notiz- und Werkzeugdaten aus.
  Future<void> initialize() async {
    _note = _ensureNote();
    if (_note.pages.isEmpty) {
      _note = _note.copyWith(
        pages: List<NotePage>.unmodifiable(
          <NotePage>[NotePage(strokes: const <Stroke>[])],
        ),
      );
    }
    _currentPageIndex = _normalizePageIndex(_note.lastOpenedPageIndex);
    drawingController.initialize(_note.pages[_currentPageIndex].strokes);
    _tools = List<DrawingTool>.of(_defaultTools);
    _selectedToolId = _tools.first.id;
    _initialized = true;
    notifyListeners();

    final List<DrawingTool> persisted = await _toolPreferencesRepository.load(
      _defaultTools,
    );
    if (persisted.isNotEmpty) {
      _tools = persisted;
    }

    final String? persistedSelection = await _toolPreferencesRepository
        .loadSelectedToolId();
    if (persistedSelection != null &&
        _tools.any((tool) => tool.id == persistedSelection)) {
      _selectedToolId = persistedSelection;
    } else if (!_tools.any((tool) => tool.id == _selectedToolId)) {
      _selectedToolId = _tools.first.id;
    }
    _toolsLoaded = true;
    notifyListeners();
  }

  /// Wählt das Werkzeug mit der angegebenen [toolId] aus.
  void selectTool(String toolId) {
    if (_selectedToolId == toolId) {
      return;
    }
    if (!_tools.any((tool) => tool.id == toolId)) {
      return;
    }
    _selectedToolId = toolId;
    notifyListeners();
    unawaited(
      _toolPreferencesRepository.saveSelectedToolId(
        toolId,
        currentTools: _tools,
      ),
    );
  }

  /// Aktualisiert ein Werkzeug und speichert die Konfiguration.
  Future<void> updateTool(DrawingTool updatedTool) async {
    _tools = _tools
        .map((tool) => tool.id == updatedTool.id ? updatedTool : tool)
        .toList(growable: false);
    if (!_tools.any((tool) => tool.id == _selectedToolId)) {
      _selectedToolId = _tools.first.id;
      unawaited(
        _toolPreferencesRepository.saveSelectedToolId(
          _selectedToolId,
          currentTools: _tools,
        ),
      );
    }
    notifyListeners();
    await _toolPreferencesRepository.save(
      _tools,
      selectedToolId: _selectedToolId,
    );
  }

  /// Persistiert die aktuelle Werkzeugliste im Repository.
  Future<void> saveTools() =>
      _toolPreferencesRepository.save(_tools, selectedToolId: _selectedToolId);

  /// Persistiert den aktuellen Zeichenstand in der Notizsammlung.
  void persistDrawing() {
    _persistCurrentPageStrokes();
    _note = _note.copyWith(
      lastOpenedPageIndex: _currentPageIndex,
      updatedAt: DateTime.now(),
    );
    _inkNotesController.upsert(
      _note,
      changedPageIndices: {_currentPageIndex},
    );
    notifyListeners();
  }

  /// Fügt eine neue Assistenten-Nachricht hinzu und persistiert die Änderung.
  void appendAssistantMessage(
    AssistantMessage message, {
    String? visionSignature,
  }) {
    if (!_initialized || _note.pages.isEmpty) {
      return;
    }

    final int normalizedIndex = _normalizePageIndex(_currentPageIndex);
    final List<NotePage> updatedPages = List<NotePage>.of(_note.pages);
    final NotePage current = updatedPages[normalizedIndex];
    final List<AssistantMessage> history = List<AssistantMessage>.of(
      current.assistantHistory,
    )
      ..add(message);

  final String? trimmedDescription =
    message.visionDescription?.trim().isNotEmpty == true
      ? message.visionDescription!.trim()
      : null;

  final String? nextCachedDescription = trimmedDescription;
  final String? nextCachedSignature = trimmedDescription != null
    ? visionSignature
    : null;

    updatedPages[normalizedIndex] = current.copyWith(
      assistantHistory: List<AssistantMessage>.unmodifiable(history),
      cachedVisionDescription: nextCachedDescription,
      cachedVisionSignature: nextCachedSignature,
    );

    _note = _note.copyWith(
      pages: List<NotePage>.unmodifiable(updatedPages),
      updatedAt: DateTime.now(),
    );

    _inkNotesController.upsert(
      _note,
      changedPageIndices: {normalizedIndex},
    );
    notifyListeners();
  }

  /// Aktualisiert Metadaten der Notiz wie Titel und Papierstil.
  void updateMetadata({
    required String title,
    required NotePaperStyle paperStyle,
  }) {
    final String trimmedTitle = title.trim();
    final String nextTitle = trimmedTitle.isEmpty
        ? InkNote.generateTitle()
        : trimmedTitle;

    if (nextTitle == _note.title && paperStyle == _note.paperStyle) {
      return;
    }

    final updatedNote = _note.copyWith(
      title: nextTitle,
      paperStyle: paperStyle,
      updatedAt: DateTime.now(),
    );

    _inkNotesController.upsert(
      updatedNote,
      changedPageIndices: const <int>{},
    );
    _note = updatedNote;
    notifyListeners();
  }

  /// Stellt sicher, dass eine Notiz für die [noteId] vorhanden ist.
  InkNote _ensureNote() {
    final idx = _inkNotesController.notes.indexWhere(
      (note) => note.id == noteId,
    );
    if (idx == -1) {
      final placeholder = InkNote(
        id: noteId,
        title: 'Fehlende Notiz',
        updatedAt: DateTime.now(),
        pages: List<NotePage>.unmodifiable(
          <NotePage>[NotePage(strokes: const <Stroke>[])],
        ),
        paperStyle: NotePaperStyle.plain,
      );
      _inkNotesController.upsert(
        placeholder,
        changedPageIndices: const <int>{0},
      );
      return placeholder;
    }
    return _inkNotesController.notes[idx];
  }

  /// Wechselt auf die Seite mit [pageIndex] und lädt deren Striche.
  void setCurrentPage(int pageIndex) {
    if (!_initialized) {
      return;
    }

    final int normalizedIndex = _normalizePageIndex(pageIndex);
    if (normalizedIndex == _currentPageIndex) {
      return;
    }

    _persistCurrentPageStrokes();
    _currentPageIndex = normalizedIndex;
    drawingController.initialize(_note.pages[_currentPageIndex].strokes);
    _note = _note.copyWith(
      lastOpenedPageIndex: _currentPageIndex,
      updatedAt: DateTime.now(),
    );
    _inkNotesController.upsert(
      _note,
      changedPageIndices: const <int>{},
    );
    notifyListeners();
  }

  /// Fügt nach der aktuellen Seite eine neue leere Seite ein und aktiviert sie.
  int addPageAfterCurrent() {
    _persistCurrentPageStrokes();

    final List<NotePage> updatedPages = List<NotePage>.of(_note.pages)
      ..insert(_currentPageIndex + 1, NotePage(strokes: const <Stroke>[]));

    _currentPageIndex = (_currentPageIndex + 1).clamp(0, updatedPages.length - 1);
    drawingController.initialize(updatedPages[_currentPageIndex].strokes);

    _note = _note.copyWith(
      pages: List<NotePage>.unmodifiable(updatedPages),
      lastOpenedPageIndex: _currentPageIndex,
      updatedAt: DateTime.now(),
    );
    _inkNotesController.upsert(
      _note,
      changedPageIndices: {_currentPageIndex},
    );
    notifyListeners();
    return _currentPageIndex;
  }

  void _persistCurrentPageStrokes() {
    if (!_initialized || _note.pages.isEmpty) {
      return;
    }
    final List<NotePage> updatedPages = List<NotePage>.of(_note.pages);
    final NotePage currentPage = updatedPages[_currentPageIndex];
    final List<Stroke> persistedStrokes = drawingController.strokes;

    final bool hasContent = persistedStrokes.any(
      (Stroke stroke) => stroke.points.isNotEmpty,
    );

    final String? nextDescription =
        hasContent ? currentPage.cachedVisionDescription : null;
    final String? nextSignature =
        hasContent ? currentPage.cachedVisionSignature : null;

    final bool strokesChanged =
        !listEquals(currentPage.strokes, persistedStrokes);
    final bool descriptionChanged =
        currentPage.cachedVisionDescription != nextDescription;
    final bool signatureChanged =
        currentPage.cachedVisionSignature != nextSignature;

    if (!strokesChanged && !descriptionChanged && !signatureChanged) {
      return;
    }

    updatedPages[_currentPageIndex] = currentPage.copyWith(
      strokes: persistedStrokes,
      cachedVisionDescription: nextDescription,
      cachedVisionSignature: nextSignature,
    );

    _note = _note.copyWith(
      pages: List<NotePage>.unmodifiable(updatedPages),
    );
  }

  int _normalizePageIndex(int index) {
    if (_note.pages.isEmpty) {
      return 0;
    }
    if (index < 0) {
      return 0;
    }
    if (index >= _note.pages.length) {
      return _note.pages.length - 1;
    }
    return index;
  }

  @override
  void dispose() {
    drawingController.dispose();
    super.dispose();
  }
}
