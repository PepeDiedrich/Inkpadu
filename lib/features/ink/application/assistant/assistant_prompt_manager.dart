import 'package:ai_handwriting_app/features/drawing/application/drawing_snapshot_service.dart';
import 'package:ai_handwriting_app/features/drawing/domain/assistant_message.dart';

import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_request_type.dart';

/// Verwaltet Prompts, Nachrichtenzusammenfassungen und Token-Schätzungen.
/// 
/// Diese Klasse bietet Funktionen zur Verwaltung von Assistenten-Prompts,
/// einschließlich Prompt-Vorlagen für verschiedene Anfragety­pen, Erstellung
/// von Benutzerinhalten für Chat-Vorlagen, Token-Schätzung und
/// Nachrichtenzusammenfassung.
class AssistantPromptManager {
  /// Erstellt eine neue Instanz des Prompt-Managers.
  const AssistantPromptManager();

  /// Liefert den passenden Prompt-Text für den gewünschten Anfrage-Typ.
  String promptTemplateFor(AssistantRequestType type) {
    switch (type) {
      case AssistantRequestType.tip:
        return 'Gib einen kurzen Tipp zur Aufgabe in der Notiz, ohne die vollständige Lösung zu verraten. Nutze für Formeln LaTeX (\$…\$ bzw. \$\$…\$\$) und lasse übrige Texte mit korrekten Leerzeichen.';
      case AssistantRequestType.help:
        return 'Erkläre ausführlich, wie man die Aufgabe in der Notiz lösen kann und gib eine strukturierte Hilfestellung. Mathematische Ausdrücke sollen immer in LaTeX notiert sein (\$…\$ oder \$\$…\$\$).';
      case AssistantRequestType.review:
        return 'Überprüfe die dargestellte Lösung in der Notiz. Bestätige kurz, ob sie korrekt ist, oder beschreibe kompakt die wichtigsten Fehler. Verwende LaTeX-Notation (\$…\$ bzw. \$\$…\$\$) für Formeln.';
      case AssistantRequestType.pdfExtract:
        return 'Extrahiere den gesamten sichtbaren Text aus dem Bild. Behalte die Struktur bei. Mathematische Formeln in LaTeX (\$…\$ bzw. \$\$…\$\$). Füge keine Interpretationen hinzu.';
    }
  }

  /// Baut die Nutzlast für den `user`-Teil der Chat-Vorgabe zusammen.
  /// 
  /// Der [importedPdfText] wird NICHT mehr hier eingefügt, sondern separat
  /// als System-Nachricht gesendet, damit er immer vollständig im Kontext bleibt.
  List<Map<String, dynamic>> buildUserContent({
    required String prompt,
    required CombinedSnapshot? combinedSnapshot,
    required int totalClusters,
    required String? historySummary,
  }) {
    final List<Map<String, dynamic>> content = <Map<String, dynamic>>[
      {
        'type': 'text',
        'text':
            'Beantworte die Frage zur handschriftlichen Notiz präzise und markiere Unsicherheiten ausdrücklich.',
      },
    ];

    if (historySummary != null && historySummary.isNotEmpty) {
      content.add({
        'type': 'text',
        'text': 'Bisherige Unterhaltung:\n$historySummary',
      });
    }

    if (combinedSnapshot != null) {
      content.add({
        'type': 'image_url',
        'image_url': {
          'url': 'data:image/png;base64,${combinedSnapshot.base64Data}',
          'detail': 'auto',
        },
      });
    } else if (totalClusters > 0) {
      content.add({
        'type': 'text',
        'text':
            'Hinweis: Es standen $totalClusters Cluster zur Verfügung, es konnte aber kein Bild erzeugt werden.',
      });
    }

    content.add({
      'type': 'text',
      'text': 'Frage: $prompt',
    });

    return content;
  }

  /// Schätzt die zu erwartenden Tokens für Text- und Bildanteile.
  /// 
  /// Der [pdfContextTokens] wird separat berechnet und hier nicht einbezogen,
  /// da der PDF-Kontext nicht zum max_completion_tokens Limit zählt.
  int estimateTokenUsage({
    required String systemPrompt,
    required String prompt,
    CombinedSnapshot? combinedSnapshot,
    String? historySummary,
  }) {
    var total = _approxTokens(systemPrompt) + _approxTokens(prompt) + 32;
    if (historySummary != null) {
      total += _approxTokens(historySummary);
    }
    if (combinedSnapshot != null) {
      final double kiloBytes = combinedSnapshot.pngBytes.lengthInBytes / 1024;
      final int imageTokens = (80 + kiloBytes * 1.6).ceil();
      total += imageTokens;
    }
    return total;
  }

  /// Schätzt die Tokens für den PDF-Kontext.
  /// 
  /// Diese werden separat ausgewiesen, da der PDF-Kontext immer vollständig
  /// mitgesendet wird und nicht zum max_completion_tokens Limit zählt.
  int estimatePdfContextTokens(String? pdfText) {
    if (pdfText == null || pdfText.isEmpty) {
      return 0;
    }
    // Zusätzliche ~50 Tokens für den System-Nachricht-Wrapper
    return _approxTokens(pdfText) + 50;
  }

  /// Wählt bis zu fünf der jüngsten Dialognachrichten aus.
  List<AssistantMessage> selectRecentHistory(List<AssistantMessage> history) {
    if (history.length <= 5) {
      return history;
    }
    return history.sublist(history.length - 5);
  }

  /// Fasst die übergebenen Nachrichten in einem Textblock zusammen.
  String? summarizeHistory(List<AssistantMessage> history) {
    if (history.isEmpty) {
      return null;
    }
    final StringBuffer buffer = StringBuffer();
    for (var i = 0; i < history.length; i++) {
      final AssistantMessage message = history[i];
      if (buffer.isNotEmpty) {
        buffer.writeln('---');
      }
      buffer
        ..writeln('Frage: ${_condenseForPrompt(message.question)}')
        ..writeln('Antwort: ${_condenseForPrompt(message.answer)}');
    }
    final String result = buffer.toString().trim();
    return result.isEmpty ? null : result;
  }

  String _condenseForPrompt(String value, {int maxLength = 420}) {
    final String trimmed = value.trim();
    if (trimmed.length <= maxLength) {
      return trimmed;
    }
    return '${trimmed.substring(0, maxLength - 1)}…';
  }

  int _approxTokens(String text) {
    if (text.isEmpty) {
      return 0;
    }
    return (text.length / 4).ceil();
  }
}
