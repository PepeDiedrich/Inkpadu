import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_tool_preferences_repository.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/drawing/domain/webview_node.dart';
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

  late InkNote __note;
  List<NotePage>? _cachedPages;

  InkNote get _note => __note;
  set _note(InkNote value) {
    __note = value;
    _cachedPages = null;
  }

  late int _currentPageIndex;
  List<DrawingTool> _tools = const [];
  List<DrawingTool>? _cachedTools;
  late String _selectedToolId;
  bool _initialized = false;
  bool _toolsLoaded = false;
  List<bool> _pageContentHistory = <bool>[];

  Offset? _toolbarPosition;
  Axis _toolbarOrientation = Axis.horizontal;

  /// Gibt an, ob der Controller vollständig initialisiert wurde.
  bool get isInitialized => _initialized;

  /// Gibt an, ob die Werkzeuge aus dem Repository geladen wurden.
  bool get toolsLoaded => _toolsLoaded;

  /// Die aktuell bearbeitete Notiz.
  InkNote get note => _note;

  /// Alle Seiten der aktuellen Notiz.
  List<NotePage> get pages =>
      _cachedPages ??= List<NotePage>.unmodifiable(_note.pages);

  /// Index der aktuell aktiven Seite.
  int get currentPageIndex => _currentPageIndex;

  /// Gibt an, ob die aktuelle Seite Striche enthält oder Graphen hat.
  bool get currentPageHasContent =>
      _strokesHaveContent(drawingController.strokes) ||
      drawingController.webViewNodes.isNotEmpty;

  /// Die verfügbaren Werkzeuge als unveränderliche Liste.
  List<DrawingTool> get tools => _cachedTools ??= List.unmodifiable(_tools);

  /// ID des aktuell ausgewählten Werkzeugs.
  String get selectedToolId => _selectedToolId;

  /// Die aktuelle Position der Toolbar.
  Offset? get toolbarPosition => _toolbarPosition;

  /// Die aktuelle Ausrichtung der Toolbar.
  Axis get toolbarOrientation => _toolbarOrientation;

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

  /// Aktualisiert die interne Notiz-Kopie mit den neuesten Daten aus dem InkNotesController.
  ///
  /// Dies ist nützlich, wenn die Notiz extern aktualisiert wurde.
  /// Gibt `true` zurück, wenn die Notiz aktualisiert wurde.
  bool refreshFromSource() {
    final InkNote? sourceNote = _inkNotesController.notes
        .where((n) => n.id == noteId)
        .firstOrNull;

    if (sourceNote == null) {
      return false;
    }

    // Prüfe ob sich die Notiz tatsächlich geändert hat
    if (sourceNote.updatedAt == _note.updatedAt) {
      return false;
    }

    debugPrint('[DrawingNoteController] Refreshing note from source');
    debugPrint('[DrawingNoteController] Old updatedAt: ${_note.updatedAt}');
    debugPrint(
      '[DrawingNoteController] New updatedAt: ${sourceNote.updatedAt}',
    );

    // Aktualisiere die Notiz, aber behalte die aktuellen Striche der aktiven Seite
    final List<NotePage> mergedPages = <NotePage>[];
    for (int i = 0; i < sourceNote.pages.length; i++) {
      if (i == _currentPageIndex) {
        // Für die aktuelle Seite: Behalte die Striche aus dem DrawingController,
        // aber übernehme andere Felder aus der Quelle
        mergedPages.add(
          sourceNote.pages[i].copyWith(
            strokes: drawingController.strokes,
            webViewNodes: drawingController.webViewNodes,
          ),
        );
      } else {
        mergedPages.add(sourceNote.pages[i]);
      }
    }

    _note = sourceNote.copyWith(
      pages: List<NotePage>.unmodifiable(mergedPages),
    );

    _rebuildPageContentHistory(_note.pages);
    notifyListeners();

    debugPrint('[DrawingNoteController] Note refreshed successfully');
    return true;
  }

  /// Führt die asynchrone Initialisierung der Notiz- und Werkzeugdaten aus.
  Future<void> initialize() async {
    _note = _ensureNote();
    if (_note.pages.isEmpty) {
      _note = _note.copyWith(
        pages: List<NotePage>.unmodifiable(<NotePage>[
          NotePage(strokes: const <Stroke>[]),
        ]),
      );
    }
    _currentPageIndex = _normalizePageIndex(_note.lastOpenedPageIndex);
    drawingController.initialize(
      _note.pages[_currentPageIndex].strokes,
      _note.pages[_currentPageIndex].webViewNodes,
    );
    _rebuildPageContentHistory(_note.pages);
    _tools = List<DrawingTool>.of(_defaultTools);
    _cachedTools = null;
    _selectedToolId = _tools.first.id;
    _initialized = true;
    notifyListeners();

    final List<DrawingTool> persisted = await _toolPreferencesRepository.load(
      _defaultTools,
    );
    if (persisted.isNotEmpty) {
      _tools = persisted;
      _cachedTools = null;
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

    // Toolbar-Voreinstellungen laden
    final Offset? pos = await _toolPreferencesRepository.loadToolbarPosition();
    if (pos != null) {
      _toolbarPosition = pos;
    }
    _toolbarOrientation = await _toolPreferencesRepository
        .loadToolbarOrientation();

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
    _cachedTools = null;
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

  /// Aktualisiert die Toolbar-Position und persistiert sie.
  void updateToolbarPosition(Offset position) {
    if (_toolbarPosition == position) return;
    _toolbarPosition = position;
    notifyListeners();
    _toolPreferencesRepository.saveToolbarPosition(position);
  }

  /// Aktualisiert die Toolbar-Ausrichtung und persistiert sie.
  void updateToolbarOrientation(Axis orientation) {
    if (_toolbarOrientation == orientation) return;
    _toolbarOrientation = orientation;
    notifyListeners();
    _toolPreferencesRepository.saveToolbarOrientation(orientation);
  }

  /// Persistiert den aktuellen Zeichenstand in der Notizsammlung.
  void persistDrawing() {
    _persistCurrentPageStrokes();
    _note = _note.copyWith(
      lastOpenedPageIndex: _currentPageIndex,
      updatedAt: DateTime.now(),
    );
    _inkNotesController.upsert(_note, changedPageIndices: {_currentPageIndex});
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

    _inkNotesController.upsert(updatedNote, changedPageIndices: const <int>{});
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
        pages: List<NotePage>.unmodifiable(<NotePage>[
          NotePage(
            strokes: const <Stroke>[],
          ),
        ]),
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
    if (!_initialized || _note.pages.isEmpty) {
      return;
    }

    if (pageIndex == _currentPageIndex) {
      return;
    }

    _persistCurrentPageStrokes();

    final ({int targetIndex, bool removedPage}) result =
        _maybeRemoveCurrentPageIfEmpty(pageIndex);
    final int normalizedIndex = _normalizePageIndex(result.targetIndex);

    final bool targetUnchanged = normalizedIndex == _currentPageIndex;
    if (targetUnchanged && !result.removedPage) {
      return;
    }

    _currentPageIndex = normalizedIndex;
    drawingController.initialize(
      _note.pages[_currentPageIndex].strokes,
      _note.pages[_currentPageIndex].webViewNodes,
    );

    _note = _note.copyWith(
      lastOpenedPageIndex: _currentPageIndex,
      updatedAt: DateTime.now(),
    );
    _inkNotesController.upsert(
      _note,
      changedPageIndices: result.removedPage
          ? {_currentPageIndex}
          : const <int>{},
    );
    notifyListeners();
  }

  /// Fügt nach der aktuellen Seite eine neue leere Seite ein und aktiviert sie.
  /// Gibt den Index der neuen Seite zurück oder `null`, wenn keine Seite
  /// erstellt wurde (z. B. weil die aktuelle Seite leer ist).
  int? addPageAfterCurrent() {
    if (!_initialized) {
      return null;
    }

    _persistCurrentPageStrokes();

    if (!currentPageHasContent) {
      return null;
    }

    _syncPageContentHistory();

    final List<NotePage> updatedPages = List<NotePage>.of(_note.pages)
      ..insert(
        _currentPageIndex + 1,
        NotePage(
          strokes: const <Stroke>[],
        ),
      );
    _pageContentHistory.insert(_currentPageIndex + 1, false);

    _currentPageIndex = (_currentPageIndex + 1).clamp(
      0,
      updatedPages.length - 1,
    );
    drawingController.initialize(
      updatedPages[_currentPageIndex].strokes,
      updatedPages[_currentPageIndex].webViewNodes,
    );

    _note = _note.copyWith(
      pages: List<NotePage>.unmodifiable(updatedPages),
      lastOpenedPageIndex: _currentPageIndex,
      updatedAt: DateTime.now(),
    );
    _inkNotesController.upsert(_note, changedPageIndices: {_currentPageIndex});
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
    final List<WebViewNode> persistedWebViews = drawingController.webViewNodes;

    final bool hasContent =
        _strokesHaveContent(persistedStrokes) || persistedWebViews.isNotEmpty;

    if (_pageContentHistory.length != updatedPages.length) {
      _rebuildPageContentHistory(updatedPages);
    }
    if (_currentPageIndex < _pageContentHistory.length) {
      _pageContentHistory[_currentPageIndex] = hasContent;
    }
    final bool changed =
        !listEquals(currentPage.strokes, persistedStrokes) ||
        !listEquals(currentPage.webViewNodes, persistedWebViews);

    if (!changed) {
      return;
    }

    updatedPages[_currentPageIndex] = currentPage.copyWith(
      strokes: persistedStrokes,
      webViewNodes: persistedWebViews,
    );

    _note = _note.copyWith(pages: List<NotePage>.unmodifiable(updatedPages));
  }

  bool _strokesHaveContent(List<Stroke> strokes) =>
      strokes.any((Stroke stroke) => stroke.points.isNotEmpty);

  /// Prüft, ob eine Seite relevanten Inhalt hat (Striche oder WebViews).
  bool _pageHasContent(NotePage page) =>
      _strokesHaveContent(page.strokes) || page.webViewNodes.isNotEmpty;

  ({int targetIndex, bool removedPage}) _maybeRemoveCurrentPageIfEmpty(
    int targetIndex,
  ) {
    if (_note.pages.length <= 1) {
      return (targetIndex: targetIndex, removedPage: false);
    }

    // Never auto-remove pages from PDF-backed notes, since their content
    // comes from the PDF background, not from drawn strokes.
    if (_note.pdfBackgroundPath != null) {
      return (targetIndex: targetIndex, removedPage: false);
    }

    _syncPageContentHistory();

    final List<NotePage> pages = List<NotePage>.of(_note.pages);
    final NotePage currentPage = pages[_currentPageIndex];
    // Prüfe ob die Seite Striche enthält
    final bool hasContent = _pageHasContent(currentPage);
    final bool hadContentBefore =
        _currentPageIndex < _pageContentHistory.length &&
        _pageContentHistory[_currentPageIndex];
    if (hasContent || hadContentBefore) {
      return (targetIndex: targetIndex, removedPage: false);
    }

    pages.removeAt(_currentPageIndex);
    final List<NotePage> nextPages = List<NotePage>.unmodifiable(pages);
    if (_currentPageIndex < _pageContentHistory.length) {
      _pageContentHistory.removeAt(_currentPageIndex);
    }

    int nextTarget = targetIndex;
    if (targetIndex > _currentPageIndex) {
      nextTarget = math.max(0, targetIndex - 1);
    }

    _note = _note.copyWith(pages: nextPages, updatedAt: DateTime.now());

    if (_currentPageIndex >= nextPages.length) {
      _currentPageIndex = nextPages.length - 1;
    }

    return (targetIndex: nextTarget, removedPage: true);
  }

  void _rebuildPageContentHistory(List<NotePage> pages) {
    _pageContentHistory = pages
        .map((page) => _pageHasContent(page))
        .toList(growable: true);
  }

  void _syncPageContentHistory() {
    if (_pageContentHistory.length != _note.pages.length) {
      _rebuildPageContentHistory(_note.pages);
    }
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
