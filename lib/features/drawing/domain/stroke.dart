import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

  /// Gecachte Bounding Box für schnelle Hit-Tests.
  Rect? _cachedBoundingBox;

  /// Gecachter Path für schnelles Rendering (lazy berechnet).
  /// Wird nur verwendet, wenn der Strich für Fast-Path-Rendering geeignet ist.
  /// Dies ist eine mutable Eigenschaft, die zur Laufzeit (UI-Thread) gesetzt wird.
  /// Sie wird nicht persistiert und nicht über Isolates transportiert.
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

  /// Erstellt eine neue Instanz eines Strichs.
  Stroke({
    required this.points,
    this.color = Colors.black,
    this.baseWidth = 4.0,
    this.isHighlighter = false,
    String? id,
  }) : id = id ?? const Uuid().v4();

  /// Gibt eine Kopie des Strichs mit optional geänderten Werten zurück.
  Stroke copyWith({
    List<DrawingPoint>? points,
    Color? color,
    double? baseWidth,
    bool? isHighlighter,
    String? id,
  }) => Stroke(
    id: id ?? this.id,
    points: points ?? this.points,
    color: color ?? this.color,
    baseWidth: baseWidth ?? this.baseWidth,
    isHighlighter: isHighlighter ?? this.isHighlighter,
  );

  /// Wandelt den Strich in eine JSON-Map um.
  Map<String, dynamic> toJson() => {
    'id': id,
    'points': points.map((p) => p.toJson()).toList(),
    'color': color.toARGB32(),
    'width': baseWidth,
    'isHighlighter': isHighlighter,
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

    return Stroke(
      id: json['id'] as String?,
      points: rawPoints
          .whereType<Map<String, dynamic>>()
          .map(DrawingPoint.fromJson)
          .toList(growable: false),
      color: resolvedColor,
      baseWidth: resolvedWidth,
      isHighlighter: resolvedHighlighter,
    );
  }
}
