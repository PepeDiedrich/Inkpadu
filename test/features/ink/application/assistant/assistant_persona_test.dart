import 'package:flutter_test/flutter_test.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_persona.dart';

void main() {
  group('AssistantPersonaType', () {
    test('hat drei Werte', () {
      expect(AssistantPersonaType.values.length, 3);
      expect(
        AssistantPersonaType.values,
        containsAll([
          AssistantPersonaType.critical,
          AssistantPersonaType.praising,
          AssistantPersonaType.custom,
        ]),
      );
    });
  });

  group('AssistantPersonaConfig', () {
    test('liefert kritischen Prompt für critical Typ', () {
      const config = AssistantPersonaConfig(
        type: AssistantPersonaType.critical,
      );
      expect(config.systemPrompt, contains('streng'));
      expect(config.systemPrompt, contains('Trainer'));
    });

    test('liefert lobenden Prompt für praising Typ', () {
      const config = AssistantPersonaConfig(
        type: AssistantPersonaType.praising,
      );
      expect(config.systemPrompt, contains('warmherzig'));
      expect(config.systemPrompt, contains('ermutigend'));
    });

    test('liefert benutzerdefinierten Prompt für custom Typ', () {
      const customPrompt = 'Du bist ein freundlicher Roboter.';
      const config = AssistantPersonaConfig(
        type: AssistantPersonaType.custom,
        customPrompt: customPrompt,
      );
      expect(config.systemPrompt, customPrompt);
    });

    test('liefert Fallback-Prompt wenn custom ohne Prompt', () {
      const config = AssistantPersonaConfig(type: AssistantPersonaType.custom);
      expect(config.systemPrompt, isNotEmpty);
      expect(config.systemPrompt, contains('hilfreicher Assistent'));
    });

    test('liefert Fallback-Prompt wenn custom mit leerem Prompt', () {
      const config = AssistantPersonaConfig(
        type: AssistantPersonaType.custom,
        customPrompt: '',
      );
      expect(config.systemPrompt, isNotEmpty);
      expect(config.systemPrompt, contains('hilfreicher Assistent'));
    });

    test('copyWith erstellt Kopie mit geänderten Werten', () {
      const original = AssistantPersonaConfig(
        type: AssistantPersonaType.critical,
      );
      final copied = original.copyWith(type: AssistantPersonaType.praising);

      expect(original.type, AssistantPersonaType.critical);
      expect(copied.type, AssistantPersonaType.praising);
    });

    test('copyWith behält Werte wenn nicht übergeben', () {
      const original = AssistantPersonaConfig(
        type: AssistantPersonaType.custom,
        customPrompt: 'Test Prompt',
      );
      final copied = original.copyWith(type: AssistantPersonaType.critical);

      expect(copied.customPrompt, 'Test Prompt');
    });

    test('equality prüft type und customPrompt', () {
      const a = AssistantPersonaConfig(
        type: AssistantPersonaType.custom,
        customPrompt: 'Test',
      );
      const b = AssistantPersonaConfig(
        type: AssistantPersonaType.custom,
        customPrompt: 'Test',
      );
      const c = AssistantPersonaConfig(
        type: AssistantPersonaType.custom,
        customPrompt: 'Andere',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode ist konsistent mit equality', () {
      const a = AssistantPersonaConfig(type: AssistantPersonaType.praising);
      const b = AssistantPersonaConfig(type: AssistantPersonaType.praising);

      expect(a.hashCode, equals(b.hashCode));
    });

    test('alle Prompts enthalten LaTeX-Hinweis', () {
      for (final type in AssistantPersonaType.values) {
        final config = AssistantPersonaConfig(
          type: type,
          customPrompt: type == AssistantPersonaType.custom
              ? 'Custom mit LaTeX (\$…\$)'
              : null,
        );
        final prompt = config.systemPrompt;

        if (type != AssistantPersonaType.custom) {
          expect(
            prompt.contains('LaTeX') || prompt.contains(r'$'),
            isTrue,
            reason: 'Prompt für $type sollte LaTeX-Hinweis enthalten',
          );
        }
      }
    });
  });
}
