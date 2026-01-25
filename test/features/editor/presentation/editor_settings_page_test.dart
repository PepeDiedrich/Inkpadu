import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/editor/presentation/editor_settings_page.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await LocaleSettings.setLocale(AppLocale.en);
  });

  group('EditorSettingsPage', () {
    testWidgets('renders all settings controls', (tester) async {
      // Increase screen size to ensure everything fits
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = EditorSettings();

      await tester.pumpWidget(
        TranslationProvider(
          child: EditorSettingsScope(
            settings: settings,
            child: const MaterialApp(home: EditorSettingsPage()),
          ),
        ),
      );

      // Verify Headers
      expect(find.text('Editor settings'), findsOneWidget); // AppBar title
      expect(find.text('Assist panel'), findsOneWidget);
      expect(find.text('Drawing area'), findsOneWidget);

      // Verify Handedness SegmentedButton
      expect(find.text('Left · Right-handed'), findsOneWidget);
      expect(find.text('Right · Left-handed'), findsOneWidget);
      expect(find.byType(SegmentedButton<EditorSidebarSide>), findsOneWidget);

      // Verify Switches
      expect(find.text('Enable debug mode'), findsOneWidget);
      expect(find.text('Use line simplifier'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNWidgets(2));

      // Verify Sliders (visible by default since enabled=true)
      expect(find.byType(Slider), findsNWidgets(2));
    });

    testWidgets('updates handedness setting', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = EditorSettings(sidebarSide: EditorSidebarSide.right);

      await tester.pumpWidget(
        TranslationProvider(
          child: EditorSettingsScope(
            settings: settings,
            child: const MaterialApp(home: EditorSettingsPage()),
          ),
        ),
      );

      // Tap 'Left · Right-handed'
      await tester.tap(find.text('Left · Right-handed'));
      await tester.pump();

      expect(settings.sidebarSide, EditorSidebarSide.left);
    });

    testWidgets('updates debug mode setting', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = EditorSettings(debugModeEnabled: false);

      await tester.pumpWidget(
        TranslationProvider(
          child: EditorSettingsScope(
            settings: settings,
            child: const MaterialApp(home: EditorSettingsPage()),
          ),
        ),
      );

      // Tap Debug Mode switch
      await tester.tap(find.text('Enable debug mode'));
      await tester.pump();

      expect(settings.debugModeEnabled, isTrue);
    });

    testWidgets('toggling simplifier enables/disables sliders', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final settings = EditorSettings(lineSimplifierEnabled: true);

      await tester.pumpWidget(
        TranslationProvider(
          child: EditorSettingsScope(
            settings: settings,
            child: const MaterialApp(home: EditorSettingsPage()),
          ),
        ),
      );

      // Initially enabled
      // Find IgnorePointer that is a child of AnimatedOpacity
      final ignorePointerFinder = find.descendant(
        of: find.byType(AnimatedOpacity),
        matching: find.byType(IgnorePointer),
      );

      expect(ignorePointerFinder, findsOneWidget);
      final ignorePointer = tester.widget<IgnorePointer>(ignorePointerFinder);
      expect(ignorePointer.ignoring, isFalse);

      // Toggle off
      await tester.tap(find.text('Use line simplifier'));
      await tester.pumpAndSettle();

      expect(settings.lineSimplifierEnabled, isFalse);

      // Verify disabled state visually (opacity) and functionally (IgnorePointer)
      final ignorePointerDisabled = tester.widget<IgnorePointer>(ignorePointerFinder);
      expect(ignorePointerDisabled.ignoring, isTrue);

      final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, closeTo(0.4, 0.01));
    });

    testWidgets('updates simplifier strength slider', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Start with a known value
      final settings = EditorSettings(
        lineSimplifierEnabled: true,
        lineSimplifierStrength: 0.2,
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: EditorSettingsScope(
            settings: settings,
            child: const MaterialApp(home: EditorSettingsPage()),
          ),
        ),
      );

      // Find the first slider (Strength)
      final sliders = find.byType(Slider);

      // Drag slider
      await tester.drag(sliders.first, const Offset(100, 0));
      await tester.pump();

      expect(settings.lineSimplifierStrength, isNot(0.2));
    });

    testWidgets('updates simplifier tolerance slider', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Start with a known value
      final settings = EditorSettings(
        lineSimplifierEnabled: true,
        lineSimplifierMinTolerance: 0.5,
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: EditorSettingsScope(
            settings: settings,
            child: const MaterialApp(home: EditorSettingsPage()),
          ),
        ),
      );

      // Find the second slider (Tolerance)
      final sliders = find.byType(Slider);

      // Drag slider
      await tester.drag(sliders.at(1), const Offset(100, 0));
      await tester.pump();

      expect(settings.lineSimplifierMinTolerance, isNot(0.5));
    });
  });
}
