import 'package:flutter/material.dart';

/// Beschreibt verfügbare Papier- bzw. Hintergrundstile für eine Notizseite.
enum NotePaperStyle {
  /// Neutrales, einfarbiges Papier.
  plain,

  /// Papier mit horizontalen Linien.
  lined,

  /// Kariertes Papier mit horizontalen und vertikalen Linien.
  grid,

  /// Gepunktetes Papier.
  dotted;

  /// Symbol, das den Stil in der UI repräsentiert.
  IconData get icon => switch (this) {
    NotePaperStyle.plain => Icons.crop_square,
    NotePaperStyle.lined => Icons.horizontal_rule,
    NotePaperStyle.grid => Icons.grid_3x3,
    NotePaperStyle.dotted => Icons.blur_on,
  };
}
