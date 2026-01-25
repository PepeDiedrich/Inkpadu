import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/editor/presentation/assistant_persona_settings_page.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_persona.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await LocaleSettings.setLocale(AppLocale.en);
  });

  group('AssistantPersonaSettingsPage', () {
    testWidgets('renders all persona options', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = EditorSettings();

      await tester.pumpWidget(
        TranslationProvider(
          child: EditorSettingsScope(
            settings: settings,
            child: const MaterialApp(home: AssistantPersonaSettingsPage()),
          ),
        ),
      );

      // Verify Headers
      expect(find.text('AI Assistant Persona'), findsOneWidget); // AppBar title
      expect(find.text("Choose your AI assistant's style"), findsOneWidget);

      // Verify Options
      expect(find.text('Strict trainer'), findsOneWidget);
      expect(find.text('Encouraging mentor'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);

      // Verify Current Style box
      expect(find.text('Current style'), findsOneWidget);
    });

    testWidgets('updates persona setting when option selected', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = EditorSettings(
        assistantPersonaType: AssistantPersonaType.praising,
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: EditorSettingsScope(
            settings: settings,
            child: const MaterialApp(home: AssistantPersonaSettingsPage()),
          ),
        ),
      );

      // Initial state
      expect(settings.assistantPersonaType, AssistantPersonaType.praising);

      // Select 'Strict trainer'
      await tester.tap(find.text('Strict trainer'));
      await tester.pump();

      expect(settings.assistantPersonaType, AssistantPersonaType.critical);
    });

    testWidgets('selecting Custom shows text input', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = EditorSettings(
        assistantPersonaType: AssistantPersonaType.praising,
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: EditorSettingsScope(
            settings: settings,
            child: const MaterialApp(home: AssistantPersonaSettingsPage()),
          ),
        ),
      );

      // Initially text field should not be hit testable (it might be in tree but invisible)
      expect(find.byType(TextField).hitTestable(), findsNothing);

      // Select 'Custom'
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle(); // Wait for animation

      expect(settings.assistantPersonaType, AssistantPersonaType.custom);

      // Now it should be visible and interactive
      expect(find.text('Your system prompt'), findsOneWidget);
      expect(find.byType(TextField).hitTestable(), findsOneWidget);
    });

    testWidgets('updates custom prompt text', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = EditorSettings(
        assistantPersonaType: AssistantPersonaType.custom,
        customAssistantPrompt: 'Old prompt',
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: EditorSettingsScope(
            settings: settings,
            child: const MaterialApp(home: AssistantPersonaSettingsPage()),
          ),
        ),
      );

      // Verify initial text
      expect(find.text('Old prompt'), findsOneWidget);

      // Enter new text
      await tester.enterText(find.byType(TextField), 'New prompt content');
      await tester.pump();

      expect(settings.customAssistantPrompt, 'New prompt content');
    });
  });
}
