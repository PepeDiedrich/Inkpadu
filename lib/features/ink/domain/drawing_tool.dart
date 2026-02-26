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
    this.usePressure = true,
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

  /// Ob Drucksensitivität verwendet wird.
  final bool usePressure;

  /// Gibt eine Kopie mit überschriebenen Eigenschaften zurück.
  DrawingTool copyWith({
    String? label,
    IconData? icon,
    Color? color,
    double? baseWidth,
    bool? isHighlighter,
    bool? isEraser,
    bool? usePressure,
  }) => DrawingTool(
    id: id,
    label: label ?? this.label,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    baseWidth: baseWidth ?? this.baseWidth,
    isHighlighter: isHighlighter ?? this.isHighlighter,
    isEraser: isEraser ?? this.isEraser,
    usePressure: usePressure ?? this.usePressure,
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
    'usePressure': usePressure,
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
    usePressure: json['usePressure'] as bool? ?? true,
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
      usePressure: false,
    ),
    DrawingTool(
      id: 'pen-neon',
      label: 'Neon',
      icon: Icons.highlight,
      color: Color(0xFF66BB6A),
      baseWidth: 8,
      isHighlighter: true,
      usePressure: false,
    ),
    DrawingTool(
      id: 'eraser',
      label: 'Radierer',
      icon: Icons.auto_fix_off,
      color: Colors.white,
      baseWidth: 18,
      isEraser: true,
      usePressure: false,
    ),
    DrawingTool(
      id: 'ai-lasso',
      label: 'aiLasso',
      icon: Icons.auto_awesome,
      color: Colors.deepPurple,
      baseWidth: 2,
      usePressure: false,
    ),
  ];

  /// ID des KI-Lasso-Tools.
  static const String aiLassoId = 'ai-lasso';
}
