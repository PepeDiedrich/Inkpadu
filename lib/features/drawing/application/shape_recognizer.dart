import 'dart:math' as math;

import 'package:inkpadu/features/drawing/domain/drawing_point.dart';
import 'package:inkpadu/features/drawing/application/stroke_simplifier.dart';
import 'package:flutter/material.dart';

/// Die verschiedenen Arten von geometrischen Formen, die erkannt werden können.
enum ShapeType {
  /// Eine gerade Linie.
  line,

  /// Ein Dreieck.
  triangle,

  /// Ein Rechteck (inkl. Quadrat).
  rectangle,

  /// Ein Kreis oder eine Ellipse.
  ellipse,
}

/// Repräsentiert das Ergebnis einer Formerkennung.
class ShapeMatch {
  /// Der Typ der erkannten Form.
  final ShapeType type;

  /// Die korrigierten Punkte, die die ideale Form beschreiben.
  final List<DrawingPoint> correctedPoints;

  /// Erstellt eine neue [ShapeMatch]-Instanz.
  ShapeMatch({required this.type, required this.correctedPoints});
}

/// Ein erkanntes Linien-Element.
class LineMatch extends ShapeMatch {
  /// Erstellt ein [LineMatch].
  LineMatch({required List<DrawingPoint> points})
    : super(type: ShapeType.line, correctedPoints: points);
}

/// Ein erkanntes Dreieck.
class TriangleMatch extends ShapeMatch {
  /// Die Eckpunkte des Dreiecks.
  final List<Offset> vertices;

  /// Erstellt ein [TriangleMatch].
  TriangleMatch({required this.vertices, required super.correctedPoints})
    : super(type: ShapeType.triangle);
}

/// Ein erkanntes Rechteck.
class RectangleMatch extends ShapeMatch {
  /// Das zugrundeliegende Rechteck.
  final Rect rect;

  /// Der Rotationswinkel (Standard: 0.0).
  final double angle;

  /// Erstellt ein [RectangleMatch].
  RectangleMatch({
    required this.rect,
    this.angle = 0.0,
    required super.correctedPoints,
  }) : super(type: ShapeType.rectangle);
}

/// Ein erkannter Kreis oder Ellipse.
class EllipseMatch extends ShapeMatch {
  /// Die Bounding-Box der Ellipse.
  final Rect boundingBox;

  /// Erstellt ein [EllipseMatch].
  EllipseMatch({required this.boundingBox, required super.correctedPoints})
    : super(type: ShapeType.ellipse);
}

/// Eine Hilfsklasse zur Erkennung von geometrischen Formen aus einer Liste von Punkten.
class ShapeRecognizer {
  /// Versucht, aus den gegebenen Punkten eine geometrische Form zu erkennen.
  ///
  /// [tolerance] gibt den maximal erlaubten durchschnittlichen oder absoluten Abstand
  /// der Punkte zur idealen Form an.
  static ShapeMatch? recognizeShape(
    List<DrawingPoint> points,
    double tolerance,
  ) {
    if (points.length < 3) {
      if (points.length == 2) {
        // Maybe a line?
        if (_isLine(points, tolerance)) {
          return LineMatch(points: [points.first, points.last]);
        }
      }
      return null;
    }

    // 1. Check for Line
    if (_isLine(points, tolerance)) {
      final start = points.first;
      final end = points.last;
      return LineMatch(points: [start, end]);
    }

    final bool isClosed =
        (points.first.position - points.last.position).distance < tolerance * 4;

    // Vereinfachen der Punkte, um Ecken zu finden.
    // Wir nutzen hier eine etwas aggressive Toleranz für die Eckenerkennung.
    final simplified = simplifyStrokePoints(
      points,
      tolerance: tolerance * 1.25,
    );
    final int corners = isClosed
        ? (simplified.length > 2 ? simplified.length - 1 : simplified.length)
        : simplified.length;

    // 2. Check for Triangle (3 corners + closed)
    if (isClosed && corners == 3) {
      // Es sind 3 Punkte + der schließende Punkt (oder 3 Punkte wenn close-check im simplifier passierte)
      // Wir nehmen die simplified points als vertices.
      // Falls der letzte Punkt == erster Punkt, nehmen wir nur die ersten 3.
      final vertices = <Offset>[];
      for (int i = 0; i < 3; i++) {
        vertices.add(simplified[i].position);
      }

      return TriangleMatch(
        vertices: vertices,
        correctedPoints: generatePolygonPoints(vertices),
      );
    }

    // 3. Check for Rectangle (4 corners + closed)
    // Wir erlauben auch 5 Punkte, falls RDP einen kleinen Punkt extra lässt, aber 4 ist ideal.
    if (isClosed && (corners == 4 || corners == 5)) {
      // Prüfen, ob es ein Rechteck ist (Winkel ~90 Grad).
      // Für jetzt nehmen wir an, wenn es 4 Ecken hat und geschlossen ist, ist es ein Viereck.
      // Wir snappen es zu einem axis-aligned Rechteck (Bounding Box) oder einem rotierten Rechteck.
      // User wünscht "Rechtecke". Einfacher Start: Axis Aligned Bounding Box der originalen Punkte?
      // Oder Bounding Box der simplified points?

      // Berechne Bounding Box der originalen Punkte
      double minX = double.infinity, maxX = -double.infinity;
      double minY = double.infinity, maxY = -double.infinity;
      for (final p in points) {
        if (p.position.dx < minX) minX = p.position.dx;
        if (p.position.dx > maxX) maxX = p.position.dx;
        if (p.position.dy < minY) minY = p.position.dy;
        if (p.position.dy > maxY) maxY = p.position.dy;
      }

      final rect = Rect.fromLTRB(minX, minY, maxX, maxY);
      // Optional: Check if the drawn points fill the rect somewhat well?
      // For now, accept as Rectangle.

      // "Best Fit": If aspect ratio is close to 1, make it a Square?
      // But implementation of resizing will allow free dragging anyway.
      // So we just return the Rect.

      return RectangleMatch(
        rect: rect,
        correctedPoints: generateRectPoints(rect),
      );
    }

    // 4. Check for Ellipse (Closed, few "sharp" corners or many points evenly distributed)
    // Wenn es geschlossen ist, aber RDP viele Punkte übrig lässt (rund), oder RDP sehr aggressiv war?
    // Einfacher Check: Passt es in eine Ellipse?
    if (isClosed) {
      // Wenn wir bereits viele Ecken gefunden haben (simplified points), ist es vermutlich kein Kreis
      // außer die Punkte sind sehr nah an der Ellipse.

      // Berechne Bounding Box
      double minX = double.infinity, maxX = -double.infinity;
      double minY = double.infinity, maxY = -double.infinity;
      for (final p in points) {
        if (p.position.dx < minX) minX = p.position.dx;
        if (p.position.dx > maxX) maxX = p.position.dx;
        if (p.position.dy < minY) minY = p.position.dy;
        if (p.position.dy > maxY) maxY = p.position.dy;
      }
      final rect = Rect.fromLTRB(minX, minY, maxX, maxY);

      // Don't recognize tiny shapes as ellipses
      if (rect.width < tolerance * 2 || rect.height < tolerance * 2) {
        return null;
      }

      final center = rect.center;
      final a = rect.width / 2;
      final b = rect.height / 2;

      // Check variance of distance from center (normalized by radii)
      // (x-cx)^2 / a^2 + (y-cy)^2 / b^2 = 1
      double totalError = 0.0;
      for (final p in points) {
        final dx = p.position.dx - center.dx;
        final dy = p.position.dy - center.dy;
        final val = (dx * dx) / (a * a) + (dy * dy) / (b * b);
        totalError += (val - 1.0).abs();
      }
      final avgError = totalError / points.length;

      // Wenn der Fehler klein genug ist -> Ellipse
      // Wir senken die Toleranz von 0.2 auf 0.15, um Polygons weniger oft fälschlich zu erkennen.
      if (avgError < 0.15) {
        return EllipseMatch(
          boundingBox: rect,
          correctedPoints: generateEllipsePoints(rect),
        );
      }
    }

    return null;
  }

  static bool _isLine(List<DrawingPoint> points, double tolerance) {
    if (points.length < 2) return false;
    final start = points.first.position;
    final end = points.last.position;

    if ((start - end).distanceSquared < 1.0) {
      return false;
    }

    double maxDistance = 0.0;

    for (final point in points) {
      final double distance = _distanceToLineSegment(
        point.position,
        start,
        end,
      );
      if (distance > maxDistance) {
        maxDistance = distance;
      }
    }

    return maxDistance <= tolerance;
  }

  static double _distanceToLineSegment(Offset p, Offset a, Offset b) {
    final double l2 = (b - a).distanceSquared;
    if (l2 == 0) return (p - a).distance;

    final double t =
        ((p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy)) / l2;
    final double tClamped = t.clamp(0.0, 1.0);

    final double projectionX = a.dx + tClamped * (b.dx - a.dx);
    final double projectionY = a.dy + tClamped * (b.dy - a.dy);

    final double dx = p.dx - projectionX;
    final double dy = p.dy - projectionY;

    return math.sqrt(dx * dx + dy * dy);
  }

  /// Erzeugt eine Liste von [DrawingPoint]s aus den angegebenen [vertices].
  static List<DrawingPoint> generatePolygonPoints(List<Offset> vertices) {
    if (vertices.isEmpty) return [];
    final points = <DrawingPoint>[];
    for (int i = 0; i < vertices.length; i++) {
      points.add(DrawingPoint(position: vertices[i]));
    }
    // Close the loop
    points.add(DrawingPoint(position: vertices.first));
    return points;
  }

  /// Generiert Punkte für ein Rechteck [rect].
  static List<DrawingPoint> generateRectPoints(Rect rect) => [
    DrawingPoint(position: rect.topLeft),
    DrawingPoint(position: rect.topRight),
    DrawingPoint(position: rect.bottomRight),
    DrawingPoint(position: rect.bottomLeft),
    DrawingPoint(position: rect.topLeft),
  ];

  /// Generiert Punkte für eine Ellipse in [rect].
  static List<DrawingPoint> generateEllipsePoints(Rect rect) {
    final points = <DrawingPoint>[];
    final center = rect.center;
    final a = rect.width / 2;
    final b = rect.height / 2;
    const int steps = 40; // Genügend Punkte für glatte Darstellung

    for (int i = 0; i <= steps; i++) {
      final double t = (i / steps) * 2 * math.pi;
      final double dx = a * math.cos(t);
      final double dy = b * math.sin(t);
      points.add(
        DrawingPoint(position: Offset(center.dx + dx, center.dy + dy)),
      );
    }
    return points;
  }
}
