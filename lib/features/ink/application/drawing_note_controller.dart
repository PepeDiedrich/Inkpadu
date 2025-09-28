import 'dart:async';
import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_tool_preferences_repository.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
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
           toolPreferencesRepository ??
           const DrawingToolPreferencesRepository(),
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
  List<DrawingTool> _tools = const [];
  late String _selectedToolId;
  bool _initialized = false;
  bool _toolsLoaded = false;

  /// Gibt an, ob der Controller vollständig initialisiert wurde.
  bool get isInitialized => _initialized;

  /// Gibt an, ob Werkzeugdaten aus dem Repository geladen wurden.
  bool get toolsLoaded => _toolsLoaded;

  /// Die aktuell bearbeitete Notiz.
  InkNote get note => _note;

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
    drawingController.initialize(_note.page.strokes);
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
    unawaited(_toolPreferencesRepository.saveSelectedToolId(toolId));
  }

  /// Aktualisiert ein Werkzeug und speichert die Konfiguration.
  Future<void> updateTool(DrawingTool updatedTool) async {
    _tools = _tools
        .map((tool) => tool.id == updatedTool.id ? updatedTool : tool)
        .toList(growable: false);
    if (!_tools.any((tool) => tool.id == _selectedToolId)) {
      _selectedToolId = _tools.first.id;
      unawaited(_toolPreferencesRepository.saveSelectedToolId(_selectedToolId));
    }
    notifyListeners();
    await _toolPreferencesRepository.save(_tools);
  }

  /// Persistiert die aktuelle Werkzeugliste im Repository.
  Future<void> saveTools() => _toolPreferencesRepository.save(_tools);

  /// Persistiert den aktuellen Zeichenstand in der Notizsammlung.
  void persistDrawing() {
    final updatedPage = _note.page.copyWith(strokes: drawingController.strokes);

    final updatedNote = _note.copyWith(
      page: updatedPage,
      updatedAt: DateTime.now(),
    );

    _inkNotesController.upsert(updatedNote);
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
        page: NotePage(strokes: const <Stroke>[]),
      );
      _inkNotesController.upsert(placeholder);
      return placeholder;
    }
    return _inkNotesController.notes[idx];
  }

  @override
  void dispose() {
    drawingController.dispose();
    super.dispose();
  }
}
