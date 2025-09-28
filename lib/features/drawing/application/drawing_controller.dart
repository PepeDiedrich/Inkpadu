import 'dart:async';
import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/application/stroke_simplifier_async.dart'
    as async_simpl;
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';

/// Verwaltet den Zustand der Zeichenfläche und stellt Undo/Redo-Funktionen bereit.
class DrawingController extends ChangeNotifier {
  /// Aktuell gezeichnete Striche.
  List<Stroke> _strokes = const [];

  /// Version der Strichliste. Erhöht sich bei jeder strukturellen Änderung
  /// (Undo, Redo, Clear, Abschluss eines Strichs). Dient für shouldRepaint.
  int _strokesVersion = 0;

  /// Der temporäre Strich, der gerade entsteht.
  Stroke? _currentStroke;

  /// Stack für Wiederherstellen-Operationen.
  final List<Stroke> _redoStack = [];

  double _simplifierStrength = 0.25;
  double _simplifierMinTolerance = 0.3;

  /// Liefert eine unveränderliche Sicht auf alle gespeicherten Striche.
  List<Stroke> get strokes => List.unmodifiable(_strokes);

  /// Liefert die aktuelle Versionsnummer der Strichliste.
  int get strokesVersion => _strokesVersion;

  /// Gibt den aktuell entstehenden Strich zurück.
  Stroke? get currentStroke => _currentStroke;

  /// `true`, wenn mindestens ein Strich rückgängig gemacht werden kann.
  bool get canUndo => _strokes.isNotEmpty;

  /// `true`, wenn ein rückgängig gemachter Strich wiederhergestellt werden kann.
  bool get canRedo => _redoStack.isNotEmpty;

  /// Übernimmt eine bestehende Liste von Strichen in den Controller.
  void initialize(List<Stroke> initialStrokes) {
    _strokes = List<Stroke>.of(initialStrokes);
    _strokesVersion++; // Initialisierung zählt als Änderung.
    _currentStroke = null;
    _redoStack.clear();
    notifyListeners();
  }

  /// Startet einen neuen Strich mit dem übergebenen [point].
  void startStroke(
    DrawingPoint point, {
    required Color color,
    required double baseWidth,
    bool isHighlighter = false,
  }) {
    _currentStroke = Stroke(
      points: [point],
      color: color,
      baseWidth: baseWidth,
      isHighlighter: isHighlighter,
    );
    _redoStack.clear();
    notifyListeners();
  }

  /// Fügt dem aktuellen Strich einen weiteren Punkt hinzu.
  void updateStroke(DrawingPoint point) {
    if (_currentStroke == null) return;
    _currentStroke = _currentStroke!.copyWith(
      points: List<DrawingPoint>.of(_currentStroke!.points)..add(point),
    );
    notifyListeners();
  }

  /// Entfernt Striche, deren Punkte innerhalb des gegebenen Radius liegen.
  bool eraseAt(Offset position, {required double radius}) {
    if (_strokes.isEmpty) {
      return false;
    }

    final double radiusSquared = radius * radius;
    final List<Stroke> retained = <Stroke>[];
    var removedAny = false;

    for (final stroke in _strokes) {
      final bool shouldRemove = stroke.points.any((point) {
        final double dx = point.position.dx - position.dx;
        final double dy = point.position.dy - position.dy;
        return (dx * dx + dy * dy) <= radiusSquared;
      });

      if (shouldRemove) {
        removedAny = true;
      } else {
        retained.add(stroke);
      }
    }

    if (!removedAny) {
      return false;
    }

    _strokes = List<Stroke>.of(retained);
    _redoStack.clear();
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  /// Aktualisiert die Parameter des Linien-Vereinfachers.
  ///
  /// [strength] steuert die relative Stärke der Vereinfachung und wird zwischen
  /// `0.05` und `0.8` geklemmt. [minTolerance] definiert die Mindesttoleranz und
  /// kann nicht unter `0.05` fallen.
  void updateSimplifierSettings({double? strength, double? minTolerance}) {
    if (strength != null) {
      final double clamped = strength.clamp(0.05, 0.8);
      _simplifierStrength = clamped;
    }
    if (minTolerance != null) {
      final double clamped = minTolerance.clamp(0.05, double.infinity);
      _simplifierMinTolerance = clamped;
    }
  }

  /// Beendet den aktuellen Strich und speichert ihn dauerhaft.
  /// Gibt `true` zurück, wenn der Strich übernommen wurde.
  Future<bool> endStroke({
    bool simplify = true,
    Stroke Function(Stroke stroke)? transform,
  }) async {
    if (_currentStroke == null) {
      return false;
    }

    final stroke = _currentStroke!;
    _currentStroke = null;

    if (stroke.points.length < 2) {
      notifyListeners();
      return false;
    }

    Stroke strokeToStore = stroke;

    if (simplify) {
      final Stroke simplified = await async_simpl.simplifyStrokeAsync(
        stroke,
        tolerance: _simplificationToleranceFor(stroke),
      );

      if (simplified.points.length < 2) {
        notifyListeners();
        return false;
      }
      strokeToStore = simplified;
    }

    if (transform != null) {
      strokeToStore = transform(strokeToStore);
      if (strokeToStore.points.length < 2) {
        notifyListeners();
        return false;
      }
    }

    _strokes = List<Stroke>.of(_strokes)..add(strokeToStore);
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  /// Macht den zuletzt gespeicherten Strich rückgängig.
  bool undo() {
    if (_strokes.isEmpty) return false;

    final updated = List<Stroke>.of(_strokes);
    final removed = updated.removeLast();
    _redoStack.add(removed);
    _strokes = updated;
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  /// Stellt den zuletzt rückgängig gemachten Strich wieder her.
  bool redo() {
    if (_redoStack.isEmpty) return false;

    final stroke = _redoStack.removeLast();
    _strokes = List<Stroke>.of(_strokes)..add(stroke);
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  /// Entfernt alle Striche und setzt den Controller zurück.
  bool clear() {
    if (_strokes.isEmpty && _currentStroke == null) {
      return false;
    }
    _strokes = const [];
    _currentStroke = null;
    _redoStack.clear();
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  /// Bricht den aktuell entstehenden Strich ab, ohne ihn zu speichern.
  void cancelCurrentStroke() {
    if (_currentStroke == null) return;
    _currentStroke = null;
    notifyListeners();
  }

  double _simplificationToleranceFor(Stroke stroke) {
    final effective = stroke.baseWidth * _simplifierStrength;
    final minTolerance = _simplifierMinTolerance;
    return math.max(effective, minTolerance);
  }
}
