import 'package:inkpadu/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';

/// Repräsentiert ein konfigurierbares Zeichenwerkzeug.
class DrawingTool {
  /// Erstellt ein Werkzeug mit den angegebenen Eigenschaften.
  const DrawingTool({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.baseWidth,
    this.isHighlighter = false,
    this.isEraser = false,
  });

  /// Stabile ID des Werkzeugs.
  final String id;

  /// Sichtbarer Name in der UI.
  final String label;

  /// Angezeigtes Icon.
  final IconData icon;

  /// Linienfarbe des Werkzeugs.
  final Color color;

  /// Basisstrichbreite ohne Druckmodulation.
  final double baseWidth;

  /// Kennzeichnet das Werkzeug als Textmarker.
  final bool isHighlighter;

  /// Kennzeichnet das Werkzeug als Radierer.
  final bool isEraser;

  /// Leitet den Stifttyp aus der ID ab.
  PenType get penType {
    if (isHighlighter) return PenType.marker;
    if (id.contains('fountain')) return PenType.fountain;
    if (id.contains('ink')) return PenType.ink;
    if (id.contains('marker')) return PenType.marker;
    if (id.contains('brush') || id.contains('neon')) return PenType.brush;
    return PenType.fineliner;
  }

  /// Gibt eine Kopie mit überschriebenen Eigenschaften zurück.
  DrawingTool copyWith({
    String? label,
    IconData? icon,
    Color? color,
    double? baseWidth,
    bool? isHighlighter,
    bool? isEraser,
  }) => DrawingTool(
    id: id,
    label: label ?? this.label,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    baseWidth: baseWidth ?? this.baseWidth,
    isHighlighter: isHighlighter ?? this.isHighlighter,
    isEraser: isEraser ?? this.isEraser,
  );

  /// Serialisiert das Werkzeug nach JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'icon': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'iconFontPackage': icon.fontPackage,
    'iconMatchTextDirection': icon.matchTextDirection,
    'color': color.toARGB32(),
    'baseWidth': baseWidth,
    'isHighlighter': isHighlighter,
    'isEraser': isEraser,
  };

  /// Erstellt ein Werkzeug aus einer JSON-Repräsentation.
  factory DrawingTool.fromJson(Map<String, dynamic> json) => DrawingTool(
    id: json['id'] as String,
    label: json['label'] as String,
    icon: IconData(
      json['icon'] as int,
      fontFamily: json['iconFontFamily'] as String?,
      fontPackage: json['iconFontPackage'] as String?,
      matchTextDirection: json['iconMatchTextDirection'] as bool? ?? false,
    ),
    color: Color((json['color'] as int?) ?? Colors.black.toARGB32()),
    baseWidth: (json['baseWidth'] as num?)?.toDouble() ?? 4.0,
    isHighlighter: json['isHighlighter'] as bool? ?? false,
    isEraser: json['isEraser'] as bool? ?? false,
  );
}

/// Standardpalette für neue Notizen.
class DrawingToolDefaults {
  /// Vordefinierte Werkzeuge, die beim ersten Öffnen verwendet werden.
  static const List<DrawingTool> palette = <DrawingTool>[
    DrawingTool(
      id: 'pen-fineliner',
      label: 'Fineliner',
      icon: Icons.edit,
      color: Colors.black,
      baseWidth: 3.5,
    ),
    DrawingTool(
      id: 'pen-ink',
      label: 'Tintenroller',
      icon: Icons.create,
      color: Color(0xFF1E88E5),
      baseWidth: 4.5,
    ),
    DrawingTool(
      id: 'pen-fountain',
      label: 'Füller',
      icon: Icons.draw,
      color: Color(0xFFD32F2F),
      baseWidth: 5.5,
    ),
    DrawingTool(
      id: 'pen-marker',
      label: 'Marker',
      icon: Icons.brush,
      color: Color(0xFFFFC107),
      baseWidth: 11,
      isHighlighter: true,
    ),
    DrawingTool(
      id: 'pen-neon',
      label: 'Neon',
      icon: Icons.highlight,
      color: Color(0xFF66BB6A),
      baseWidth: 8,
      isHighlighter: true,
    ),
    DrawingTool(
      id: 'eraser',
      label: 'Radierer',
      icon: Icons.auto_fix_off,
      color: Colors.white,
      baseWidth: 18,
      isEraser: true,
    ),
    DrawingTool(
      id: 'ai-lasso',
      label: 'aiLasso',
      icon: Icons.auto_awesome,
      color: Colors.deepPurple,
      baseWidth: 2,
    ),
    DrawingTool(
      id: 'selection-lasso',
      label: 'Auswahl',
      icon: Icons.highlight_alt,
      color: Colors.blueGrey,
      baseWidth: 2,
    ),
  ];

  /// ID des KI-Lasso-Tools.
  static const String aiLassoId = 'ai-lasso';

  /// ID des Standard-Auswahl-Lassos.
  static const String selectionLassoId = 'selection-lasso';
}
