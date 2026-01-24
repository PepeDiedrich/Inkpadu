import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/editor/presentation/editor_settings_page.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await LocaleSettings.setLocale(AppLocale.en);
  });

  Widget createWidgetUnderTest(EditorSettings settings) {
    return TranslationProvider(
      child: MaterialApp(
        home: EditorSettingsScope(
          settings: settings,
          child: const EditorSettingsPage(),
        ),
      ),
    );
  }

  group('EditorSettingsPage', () {
    testWidgets('renders all settings controls', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = EditorSettings();
      await tester.pumpWidget(createWidgetUnderTest(settings));
      await tester.pumpAndSettle();

      expect(find.text('Editor settings'), findsOneWidget);
      expect(find.text('Assist panel'), findsOneWidget);
      expect(find.text('Left · Right-handed'), findsOneWidget);
      expect(find.text('Right · Left-handed'), findsOneWidget);
      expect(find.text('Drawing area'), findsOneWidget);
      expect(find.text('Enable debug mode'), findsOneWidget);
      expect(find.text('Use line simplifier'), findsOneWidget);
    });

    testWidgets('changing sidebar side updates settings', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = EditorSettings(sidebarSide: EditorSidebarSide.right);
      await tester.pumpWidget(createWidgetUnderTest(settings));
      await tester.pumpAndSettle();

      // Tap Left
      await tester.tap(find.text('Left · Right-handed'));
      await tester.pumpAndSettle();

      expect(settings.sidebarSide, equals(EditorSidebarSide.left));

      // Tap Right
      await tester.tap(find.text('Right · Left-handed'));
      await tester.pumpAndSettle();

      expect(settings.sidebarSide, equals(EditorSidebarSide.right));
    });

    testWidgets('toggling debug mode updates settings', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = EditorSettings(debugModeEnabled: false);
      await tester.pumpWidget(createWidgetUnderTest(settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enable debug mode'));
      await tester.pumpAndSettle();

      expect(settings.debugModeEnabled, isTrue);
    });

    testWidgets('toggling line simplifier updates settings and UI', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = EditorSettings(lineSimplifierEnabled: true);
      await tester.pumpWidget(createWidgetUnderTest(settings));
      await tester.pumpAndSettle();

      // Verify sliders are visible/enabled (implied by not being ignored, but IgnorePointer is hard to test directly via finders without custom predicates)
      // We can check Opacity widget.
      final opacityFinder = find.byType(AnimatedOpacity);
      expect(opacityFinder, findsOneWidget);
      expect(tester.widget<AnimatedOpacity>(opacityFinder).opacity, equals(1.0));

      // Toggle off
      await tester.tap(find.text('Use line simplifier'));
      await tester.pumpAndSettle();

      expect(settings.lineSimplifierEnabled, isFalse);
      expect(tester.widget<AnimatedOpacity>(opacityFinder).opacity, equals(0.4));
    });

    testWidgets('adjusting sliders updates settings', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = EditorSettings(
        lineSimplifierEnabled: true,
        lineSimplifierStrength: 0.2,
        lineSimplifierMinTolerance: 0.5,
      );
      await tester.pumpWidget(createWidgetUnderTest(settings));
      await tester.pumpAndSettle();

      // Find Sliders. There are two.
      final sliders = find.byType(Slider);
      expect(sliders, findsNWidgets(2));

      // First slider: Strength
      await tester.drag(sliders.first, const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(settings.lineSimplifierStrength, greaterThan(0.2));

      // Second slider: Tolerance
      await tester.drag(sliders.last, const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(settings.lineSimplifierMinTolerance, greaterThan(0.5));
    });
  });
}
