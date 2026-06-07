// ignore_for_file: public_member_api_docs

import 'package:inkpadu/features/editor/application/editor_settings_scope.dart';

class AiPromptUtil {
  static List<AiPrompt> defaultAiShortcuts() => [
    const AiPrompt(
      id: 'ai-shortcut-1',
      title: 'Graph & Visuell',
      prompt:
          'Bitte analysiere den ausgewählten Bereich und generiere einen JavaScript und HTML basierten Graph. Antworte mit reinem HTML/JS.',
    ),
    const AiPrompt(
      id: 'ai-shortcut-2',
      title: 'Fehler markieren',
      prompt:
          'Bitte analysiere diese Notizen. Markiere Fehler mit roten Bounding Boxes.',
    ),
    const AiPrompt(
      id: 'ai-shortcut-3',
      title: 'Sokratischer Tutor',
      prompt: 'Hilf mir, diesen Inhalt sokratisch zu verstehen.',
    ),
  ];

  static List<AiPrompt> resolveAiShortcuts(List<AiPrompt> source) {
    final defaults = defaultAiShortcuts();
    final List<AiPrompt> result = [];
    for (var i = 0; i < 3; i++) {
      final fallback = defaults[i];
      final existing = i < source.length ? source[i] : fallback;
      result.add(
        AiPrompt(
          id: fallback.id,
          title: existing.title.isEmpty ? fallback.title : existing.title,
          prompt: existing.prompt.isEmpty ? fallback.prompt : existing.prompt,
        ),
      );
    }
    return result;
  }
}
