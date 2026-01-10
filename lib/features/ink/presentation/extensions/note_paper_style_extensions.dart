import 'package:flutter/material.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Erweiterungen für [NotePaperStyle] zur Darstellung in der UI.
extension NotePaperStyleX on NotePaperStyle {
  /// Gibt den lokalisierten Namen des Stils zurück.
  String localizedLabel(BuildContext context) {
    switch (this) {
      case NotePaperStyle.plain:
        return context.t.paper.plain;
      case NotePaperStyle.lined:
        return context.t.paper.lined;
      case NotePaperStyle.grid:
        return context.t.paper.grid;
      case NotePaperStyle.dotted:
        return context.t.paper.dotted;
    }
  }
}
