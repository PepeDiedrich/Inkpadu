import 'dart:async';
import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/application/shape_recognizer.dart';
import 'package:ai_handwriting_app/features/drawing/application/stroke_simplifier_async.dart'
    as async_simpl;
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/drawing/domain/webview_node.dart';
import 'package:flutter/material.dart';

/// Verwaltet den Zustand der Zeichenfläche und stellt Undo/Redo-Funktionen bereit.
class DrawingController extends ChangeNotifier {
  /// Aktuell gezeichnete Striche.
  List<Stroke> _strokes = const [];

  /// Zwischengespeicherte, unveränderliche Ansicht der Striche.
  List<Stroke>? _cachedStrokes;

  /// Aktuelle WebView-Knoten auf dem Canvas.
  List<WebViewNode> _webViewNodes = const [];

  /// Version der Strichliste. Erhöht sich bei jeder strukturellen Änderung
  /// (Undo, Redo, Clear, Abschluss eines Strichs). Dient für shouldRepaint.
  int _strokesVersion = 0;

  /// Der temporäre Strich, der gerade entsteht.
  Stroke? _currentStroke;

  /// Indicates if the current stroke is locked to a specific shape (e.g. line).
  bool _isLockedToShape = false;
  ShapeType? _lockedShapeType;

  /// Stores the vertices defining the locked shape.
  /// For Line: [start, end]
  /// For Triangle: [v1, v2, v3]
  /// For Rect/Ellipse: [fixedCorner, movingCorner] (defining the diagonal)
  List<Offset> _lockedVertices = [];

  /// The index of the vertex in [_lockedVertices] that is currently being dragged.
  int _activeVertexIndex = -1;

  /// Stack für Wiederherstellen-Operationen.
  final List<Stroke> _redoStack = [];

  double _simplifierStrength = 0.25;
  double _simplifierMinTolerance = 0.3;

  /// Liefert eine unveränderliche Sicht auf alle gespeicherten Striche.
  List<Stroke> get strokes => _cachedStrokes ??= List.unmodifiable(_strokes);

  /// Liefert eine unveränderliche Sicht auf alle WebView-Knoten.
  List<WebViewNode> get webViewNodes => List.unmodifiable(_webViewNodes);

  /// Liefert die aktuelle Versionsnummer der Strichliste.
  int get strokesVersion => _strokesVersion;

  /// Gibt den aktuell entstehenden Strich zurück.
  Stroke? get currentStroke => _currentStroke;

  /// Returns true if the current stroke is locked to a shape.
  bool get isLockedToShape => _isLockedToShape;

  /// `true`, wenn mindestens ein Strich rückgängig gemacht werden kann.
  bool get canUndo => _strokes.isNotEmpty;

  /// `true`, wenn ein rückgängig gemachter Strich wiederhergestellt werden kann.
  bool get canRedo => _redoStack.isNotEmpty;

  /// Übernimmt eine bestehende Liste von Strichen in den Controller.
  void initialize(
    List<Stroke> initialStrokes, [
    List<WebViewNode>? initialWebViews,
  ]) {
    _strokes = List<Stroke>.of(initialStrokes);
    _webViewNodes = initialWebViews != null
        ? List<WebViewNode>.of(initialWebViews)
        : const [];
    _cachedStrokes = null;
    _strokesVersion++; // Initialisierung zählt als Änderung.
    _currentStroke = null;
    _redoStack.clear();
    _precalculatePaths();
    notifyListeners();
  }

  /// Berechnet im Hintergrund schrittweise die Pfade aller neu geladenen Striche.
  Future<void> _precalculatePaths() async {
    for (int i = 0; i < _strokes.length; i++) {
      if (_strokes[i].cachedPath == null) {
        _strokes[i].cachedPath = _strokes[i].generatePath();
      }
      if (i % 100 == 0 && i > 0) {
        // Yield to event loop to avoid freezing the UI on load.
        await Future<void>.delayed(Duration.zero);
      }
    }
    // Update paint layer after all are cached.
    _strokesVersion++;
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
    _isLockedToShape = false;
    _lockedShapeType = null;
    _lockedVertices = [];
    _activeVertexIndex = -1;
    _redoStack.clear();
    notifyListeners();
  }

  /// Fügt dem aktuellen Strich einen weiteren Punkt hinzu.
  void updateStroke(DrawingPoint point) {
    if (_currentStroke == null) return;

    if (_isLockedToShape && _lockedShapeType != null) {
      // Wenn gesperrt, aktualisieren wir nur den aktiven Vertex und generieren die Form neu.
      if (_activeVertexIndex >= 0 &&
          _activeVertexIndex < _lockedVertices.length) {
        _lockedVertices[_activeVertexIndex] = point.position;

        List<DrawingPoint> newPoints = [];
        final pressure = _currentStroke!.points.first.pressure;

        switch (_lockedShapeType!) {
          case ShapeType.line:
            // Line: defined by 2 points.
            newPoints = [
              DrawingPoint(position: _lockedVertices[0], pressure: pressure),
              DrawingPoint(position: _lockedVertices[1], pressure: pressure),
            ];
            break;

          case ShapeType.triangle:
            // Triangle: defined by 3 points. generatePolygonPoints handles it.
            newPoints = ShapeRecognizer.generatePolygonPoints(
              _lockedVertices,
              pressure,
            );
            break;

          case ShapeType.rectangle:
            // Rect: defined by diagonal (2 points in _lockedVertices).
            final rect = Rect.fromPoints(
              _lockedVertices[0],
              _lockedVertices[1],
            );
            newPoints = ShapeRecognizer.generateRectPoints(rect, pressure);
            break;

          case ShapeType.ellipse:
            // Ellipse: defined by diagonal (2 points in _lockedVertices).
            final rect = Rect.fromPoints(
              _lockedVertices[0],
              _lockedVertices[1],
            );
            newPoints = ShapeRecognizer.generateEllipsePoints(rect, pressure);
            break;
        }

        _currentStroke = _currentStroke!.copyWith(points: newPoints);
        notifyListeners();
      }
      return;
    }

    _currentStroke = _currentStroke!.copyWith(
      points: List<DrawingPoint>.of(_currentStroke!.points)..add(point),
    );
    notifyListeners();
  }

  /// Attempts to recognize a shape from the current stroke and snap to it.
  bool trySnapToShape({double tolerance = 10.0}) {
    if (_currentStroke == null || _isLockedToShape) {
      return false;
    }

    // Save the last point of the original stroke to determine user intent/position.
    final originalLastPoint = _currentStroke!.points.isNotEmpty
        ? _currentStroke!.points.last.position
        : Offset.zero;

    final match = ShapeRecognizer.recognizeShape(
      _currentStroke!.points,
      tolerance,
    );

    if (match != null) {
      _currentStroke = _currentStroke!.copyWith(
        points: match.correctedPoints,
        isPerfectShape: true,
      );
      _isLockedToShape = true;
      _lockedShapeType = match.type;

      // Initialize locking state for resizing
      switch (match.type) {
        case ShapeType.line:
          if (match is LineMatch) {
            // For line, [start, end].
            _lockedVertices = [
              match.correctedPoints.first.position,
              match.correctedPoints.last.position,
            ];
            // Find closest vertex to user's finger (originalLastPoint)
            final dStart =
                (_lockedVertices[0] - originalLastPoint).distanceSquared;
            final dEnd =
                (_lockedVertices[1] - originalLastPoint).distanceSquared;
            _activeVertexIndex = dStart < dEnd ? 0 : 1;
          }
          break;

        case ShapeType.triangle:
          if (match is TriangleMatch) {
            _lockedVertices = List.of(match.vertices);

            // Find vertex closest to user's position.
            int bestIndex = 0;
            double minD = double.infinity;
            for (int i = 0; i < _lockedVertices.length; i++) {
              final d =
                  (_lockedVertices[i] - originalLastPoint).distanceSquared;
              if (d < minD) {
                minD = d;
                bestIndex = i;
              }
            }
            _activeVertexIndex = bestIndex;
          }
          break;

        case ShapeType.rectangle:
          if (match is RectangleMatch) {
            final rect = match.rect;
            // Define 4 corners
            final corners = [
              rect.topLeft,
              rect.topRight,
              rect.bottomRight,
              rect.bottomLeft,
            ];

            // Find the corner closest to the user's finger.
            int bestIndex = 0;
            double minD = double.infinity;
            for (int i = 0; i < 4; i++) {
              final d = (corners[i] - originalLastPoint).distanceSquared;
              if (d < minD) {
                minD = d;
                bestIndex = i;
              }
            }

            // The closest corner is the "moving" one.
            // The "fixed" corner is the opposite one (index + 2 % 4).
            final movingCorner = corners[bestIndex];
            final fixedCorner = corners[(bestIndex + 2) % 4];

            // Store as [fixed, moving] so index 1 is always the moving one logic for rect/ellipse in updateStroke
            _lockedVertices = [fixedCorner, movingCorner];
            _activeVertexIndex = 1;
          }
          break;

        case ShapeType.ellipse:
          if (match is EllipseMatch) {
            final rect = match.boundingBox;
            final corners = [
              rect.topLeft,
              rect.topRight,
              rect.bottomRight,
              rect.bottomLeft,
            ];

            int bestIndex = 0;
            double minD = double.infinity;
            for (int i = 0; i < 4; i++) {
              final d = (corners[i] - originalLastPoint).distanceSquared;
              if (d < minD) {
                minD = d;
                bestIndex = i;
              }
            }

            final movingCorner = corners[bestIndex];
            final fixedCorner = corners[(bestIndex + 2) % 4];

            _lockedVertices = [fixedCorner, movingCorner];
            _activeVertexIndex = 1;
          }
          break;
      }

      notifyListeners();
      return true;
    }

    return false;
  }

  /// Entfernt Striche, deren Punkte innerhalb des gegebenen Radius liegen.
  ///
  /// Nutzt Bounding-Box-Vorfilterung für bessere Performance bei vielen Strichen.
  bool eraseAt(Offset position, {required double radius}) {
    if (_strokes.isEmpty && _webViewNodes.isEmpty) {
      return false;
    }

    final double radiusSquared = radius * radius;
    final List<Stroke> retainedStrokes = <Stroke>[];
    final List<WebViewNode> retainedWebViews = <WebViewNode>[];
    var removedAny = false;

    // Eraser-Kreis als Rect für schnellen Bounding-Box-Test
    final Rect eraserRect = Rect.fromCircle(center: position, radius: radius);

    for (final node in _webViewNodes) {
      if (eraserRect.overlaps(node.rect)) {
        removedAny = true;
      } else {
        retainedWebViews.add(node);
      }
    }

    for (final stroke in _strokes) {
      // Schneller Bounding-Box-Check: Überschneidet sich überhaupt?
      final Rect strokeBounds = stroke.boundingBox;
      if (!eraserRect.overlaps(strokeBounds)) {
        // Keine Überschneidung -> Strich bleibt sicher erhalten
        retainedStrokes.add(stroke);
        continue;
      }

      // Detaillierter Check: Segmente prüfen
      bool shouldRemove = false;
      if (stroke.points.length == 1) {
        final point = stroke.points.first;
        final double dx = point.position.dx - position.dx;
        final double dy = point.position.dy - position.dy;
        shouldRemove = (dx * dx + dy * dy) <= radiusSquared;
      } else {
        for (int i = 0; i < stroke.points.length - 1; i++) {
          final p1 = stroke.points[i].position;
          final p2 = stroke.points[i + 1].position;
          if (_distanceToSegmentSquared(position, p1, p2) <= radiusSquared) {
            shouldRemove = true;
            break;
          }
        }
      }

      if (shouldRemove) {
        removedAny = true;
      } else {
        retainedStrokes.add(stroke);
      }
    }

    if (!removedAny) {
      return false;
    }

    _strokes = List<Stroke>.of(retainedStrokes);
    _webViewNodes = List<WebViewNode>.of(retainedWebViews);
    _cachedStrokes = null;
    _redoStack.clear();
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  double _distanceToSegmentSquared(Offset p, Offset p1, Offset p2) {
    final double l2 = (p1 - p2).distanceSquared;
    if (l2 == 0) return (p - p1).distanceSquared;

    final double t =
        ((p.dx - p1.dx) * (p2.dx - p1.dx) + (p.dy - p1.dy) * (p2.dy - p1.dy)) /
        l2;

    if (t < 0) return (p - p1).distanceSquared;
    if (t > 1) return (p - p2).distanceSquared;

    final Offset projection = Offset(
      p1.dx + t * (p2.dx - p1.dx),
      p1.dy + t * (p2.dy - p1.dy),
    );
    return (p - projection).distanceSquared;
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
    final wasLocked = _isLockedToShape;
    _isLockedToShape = false;
    _lockedShapeType = null;
    _lockedVertices = [];
    _activeVertexIndex = -1;

    if (stroke.points.length < 2) {
      notifyListeners();
      return false;
    }

    Stroke strokeToStore = stroke;
    final bool isPerfect = wasLocked || stroke.isPerfectShape;

    // Only simplify if it wasn't already a locked shape (which is already "perfect")
    if (simplify && !isPerfect) {
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

    if (isPerfect) {
      strokeToStore = strokeToStore.copyWith(isPerfectShape: true);
    }

    if (transform != null) {
      strokeToStore = transform(strokeToStore);
      if (strokeToStore.points.length < 2) {
        notifyListeners();
        return false;
      }
    }

    strokeToStore.cachedPath = strokeToStore.generatePath();

    _strokes = List<Stroke>.of(_strokes)..add(strokeToStore);
    _cachedStrokes = null;
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
    _cachedStrokes = null;
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  /// Stellt den zuletzt rückgängig gemachten Strich wieder her.
  bool redo() {
    if (_redoStack.isEmpty) return false;

    final stroke = _redoStack.removeLast();
    _strokes = List<Stroke>.of(_strokes)..add(stroke);
    _cachedStrokes = null;
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  /// Entfernt alle Striche und setzt den Controller zurück.
  bool clear() {
    if (_strokes.isEmpty && _currentStroke == null && _webViewNodes.isEmpty) {
      return false;
    }
    _strokes = const [];
    _webViewNodes = const [];
    _cachedStrokes = null;
    _currentStroke = null;
    _redoStack.clear();
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  /// Adds multiple strokes directly to the canvas (e.g., AI highlights).
  void addStrokes(List<Stroke> newStrokes) {
    if (newStrokes.isEmpty) return;
    _strokes = List<Stroke>.of(_strokes)..addAll(newStrokes);
    _cachedStrokes = null;
    _strokesVersion++;
    notifyListeners();
  }

  /// Fügt einen WebView-Knoten hinzu.
  void addWebViewNode(WebViewNode node) {
    _webViewNodes = List<WebViewNode>.of(_webViewNodes)..add(node);
    notifyListeners();
  }

  /// Aktualisiert das Rechteck (Position/Größe) eines WebView-Knotens.
  void updateWebViewNodeRect(String id, Rect newRect) {
    final index = _webViewNodes.indexWhere((node) => node.id == id);
    if (index != -1) {
      final updatedNode = _webViewNodes[index].copyWith(rect: newRect);
      _webViewNodes = List<WebViewNode>.of(_webViewNodes)
        ..[index] = updatedNode;
      notifyListeners();
    }
  }

  /// Entfernt einen WebView-Knoten anhand seiner ID.
  void removeWebViewNode(String id) {
    _webViewNodes = List<WebViewNode>.of(_webViewNodes)
      ..removeWhere((node) => node.id == id);
    notifyListeners();
  }

  /// Verschiebt ausgewählte Striche und WebViews um [delta].
  void translateSelection(
    Offset delta,
    Set<int> strokeIndices,
    Set<String> webViewIds,
  ) {
    bool changed = false;

    if (strokeIndices.isNotEmpty) {
      final updatedStrokes = List<Stroke>.of(_strokes);
      for (final index in strokeIndices) {
        if (index >= 0 && index < updatedStrokes.length) {
          final stroke = updatedStrokes[index];
          final newPoints = stroke.points
              .map(
                (point) => DrawingPoint(
                  position: point.position + delta,
                  pressure: point.pressure,
                ),
              )
              .toList();
          // Invalidiere Cached Paths und Bounds durch ein neues Objekt
          updatedStrokes[index] = stroke.copyWith(points: newPoints);
          changed = true;
        }
      }
      if (changed) {
        _strokes = updatedStrokes;
        _cachedStrokes = null;
        _strokesVersion++;
      }
    }

    if (webViewIds.isNotEmpty) {
      final updatedNodes = List<WebViewNode>.of(_webViewNodes);
      for (var i = 0; i < updatedNodes.length; i++) {
        if (webViewIds.contains(updatedNodes[i].id)) {
          final node = updatedNodes[i];
          updatedNodes[i] = node.copyWith(rect: node.rect.shift(delta));
          changed = true;
        }
      }
      if (changed) {
        _webViewNodes = updatedNodes;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  /// Bricht den aktuell entstehenden Strich ab, ohne ihn zu speichern.
  void cancelCurrentStroke() {
    if (_currentStroke == null) return;
    _currentStroke = null;
    _isLockedToShape = false;
    _lockedShapeType = null;
    _lockedVertices = [];
    _activeVertexIndex = -1;
    notifyListeners();
  }

  double _simplificationToleranceFor(Stroke stroke) {
    final effective = stroke.baseWidth * _simplifierStrength;
    final minTolerance = _simplifierMinTolerance;
    return math.max(effective, minTolerance);
  }
}
