import 'package:inkpadu/features/drawing/domain/drawing_point.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Art des Stifts, der den Strich erzeugt hat.
enum PenType {
  /// Dünner, gleichmäßiger Strich.
  fineliner,

  /// Tintenroller – gleichmäßig, etwas breiter als Fineliner.
  ink,

  /// Füller – leicht kalligrafischer Charakter.
  fountain,

  /// Pinsel – breitester Strich, weicher Charakter.
  brush,

  /// Marker – flache Kappen, halbtransparent.
  marker,
}

/// Beschreibt einen einzelnen Strich innerhalb einer handschriftlichen Notiz.
class Stroke {
  /// Einzigartige ID, um den Strich zweifelsfrei zu identifizieren.
  final String id;

  /// Die Liste der Punkte, aus denen der Strich besteht.
  final List<DrawingPoint> points;

  /// Farbe des Strichs.
  final Color color;

  /// Basis-Linienbreite, die zusammen mit dem Druck einen finalen Wert ergibt.
  final double baseWidth;

  /// Kennzeichnet, ob es sich um einen Textmarker-Strich handelt.
  final bool isHighlighter;

  /// Die Art des Stifts, die diesen Strich erzeugt hat.
  final PenType penType;

  /// Kennzeichnet, ob der Strich eine perfekte geometrische Form ist,
  /// die ohne Glättung (Smoothing) gezeichnet werden soll.
  final bool isPerfectShape;

  /// Gecachte Bounding Box für schnelle Hit-Tests.
  Rect? _cachedBoundingBox;

  /// Vorberechneter Pfad für effizientes Zeichnen.
  Path? cachedPath;

  /// Liefert die Bounding Box aller Punkte des Strichs (lazy berechnet).
  Rect get boundingBox {
    if (_cachedBoundingBox != null) return _cachedBoundingBox!;
    if (points.isEmpty) {
      _cachedBoundingBox = Rect.zero;
      return _cachedBoundingBox!;
    }
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    for (final point in points) {
      final dx = point.position.dx;
      final dy = point.position.dy;
      if (dx < minX) minX = dx;
      if (dx > maxX) maxX = dx;
      if (dy < minY) minY = dy;
      if (dy > maxY) maxY = dy;
    }
    _cachedBoundingBox = Rect.fromLTRB(minX, minY, maxX, maxY);
    return _cachedBoundingBox!;
  }

  /// Generiert den zu zeichnenden Pfad für diesen Strich.
  Path? generatePath() {
    if (points.length < 2) return null;

    final path = Path();
    path.moveTo(points[0].position.dx, points[0].position.dy);

    if (isPerfectShape) {
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].position.dx, points[i].position.dy);
      }
    } else {
      for (var i = 0; i < points.length - 1; i++) {
        final p1 = points[i].position;
        final p2 = points[i + 1].position;
        final midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
        path.quadraticBezierTo(p1.dx, p1.dy, midPoint.dx, midPoint.dy);
      }
      path.lineTo(points.last.position.dx, points.last.position.dy);
    }
    return path;
  }

  /// Erstellt eine neue Instanz eines Strichs.
  Stroke({
    required this.points,
    this.color = Colors.black,
    this.baseWidth = 4.0,
    this.isHighlighter = false,
    this.isPerfectShape = false,
    this.penType = PenType.fineliner,
    String? id,
  }) : id = id ?? const Uuid().v4();

  /// Gibt eine Kopie des Strichs mit optional geänderten Werten zurück.
  Stroke copyWith({
    List<DrawingPoint>? points,
    Color? color,
    double? baseWidth,
    bool? isHighlighter,
    bool? isPerfectShape,
    PenType? penType,
    String? id,
  }) => Stroke(
    id: id ?? this.id,
    points: points ?? this.points,
    color: color ?? this.color,
    baseWidth: baseWidth ?? this.baseWidth,
    isHighlighter: isHighlighter ?? this.isHighlighter,
    isPerfectShape: isPerfectShape ?? this.isPerfectShape,
    penType: penType ?? this.penType,
  );

  /// Wandelt den Strich in eine JSON-Map um.
  Map<String, dynamic> toJson() => {
    'id': id,
    'points': points.map((p) => p.toJson()).toList(),
    'color': color.toARGB32(),
    'width': baseWidth,
    'isHighlighter': isHighlighter,
    'isPerfectShape': isPerfectShape,
    'penType': penType.name,
  };

  /// Erstellt einen Strich aus einer JSON-Map.
  factory Stroke.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawPoints = (json['points'] as List?) ?? const [];
    final Color resolvedColor = Color(
      (json['color'] as int?) ?? Colors.black.toARGB32(),
    );
    final double resolvedWidth = (json['width'] is num)
        ? (json['width'] as num).toDouble()
        : 4.0;
    final bool resolvedHighlighter = json['isHighlighter'] as bool? ?? false;
    final bool resolvedPerfectShape = json['isPerfectShape'] as bool? ?? false;

    PenType resolvedPenType = PenType.fineliner;
    final String? rawPenType = json['penType'] as String?;
    if (rawPenType != null) {
      resolvedPenType = PenType.values.firstWhere(
        (e) => e.name == rawPenType,
        orElse: () => PenType.fineliner,
      );
    } else if (resolvedHighlighter) {
      resolvedPenType = PenType.marker;
    }

    return Stroke(
      id: json['id'] as String?,
      points: rawPoints
          .whereType<Map<String, dynamic>>()
          .map(DrawingPoint.fromJson)
          .toList(growable: false),
      color: resolvedColor,
      baseWidth: resolvedWidth,
      isHighlighter: resolvedHighlighter,
      isPerfectShape: resolvedPerfectShape,
      penType: resolvedPenType,
    );
  }
}
