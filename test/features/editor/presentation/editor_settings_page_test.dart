import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/editor/presentation/editor_settings_page.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditorSettingsPage', () {
    late EditorSettings settings;

    setUpAll(() {
      LocaleSettings.setLocale(AppLocale.de);
    });

    setUp(() {
      settings = EditorSettings(
        sidebarSide: EditorSidebarSide.right,
        debugModeEnabled: false,
        lineSimplifierEnabled: true,
        lineSimplifierStrength: 0.25,
        lineSimplifierMinTolerance: 0.3,
      );
    });

    Future<void> pumpPage(WidgetTester tester) async {
      // Set a larger surface size to prevent overflow in tests
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            locale: AppLocale.de.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: EditorSettingsScope(
              settings: settings,
              child: const EditorSettingsPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders correctly with default settings', (tester) async {
      await pumpPage(tester);

      expect(find.text('Editor-Einstellungen'), findsOneWidget);
      expect(find.text('Assistenz-Panel'), findsOneWidget);
      expect(find.text('Links · Rechtshänder'), findsOneWidget);
      expect(find.text('Rechts · Linkshänder'), findsOneWidget);

      // Check default sidebar selection (Right)
      final segmentButton = tester.widget<SegmentedButton<EditorSidebarSide>>(
        find.byType(SegmentedButton<EditorSidebarSide>),
      );
      expect(segmentButton.selected, {EditorSidebarSide.right});

      expect(find.text('Zeichenfläche'), findsOneWidget);
      expect(find.text('Debug-Modus aktivieren'), findsOneWidget);
      expect(find.text('Linien-Simplifier verwenden'), findsOneWidget);

      // Check switches
      final debugSwitch = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Debug-Modus aktivieren'),
      );
      expect(debugSwitch.value, isFalse);

      final simplifierSwitch = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Linien-Simplifier verwenden'),
      );
      expect(simplifierSwitch.value, isTrue);
    });

    testWidgets('updates sidebar side on selection', (tester) async {
      await pumpPage(tester);

      // Tap on 'Left'
      await tester.tap(find.text('Links · Rechtshänder'));
      await tester.pumpAndSettle();

      expect(settings.sidebarSide, EditorSidebarSide.left);
    });

    testWidgets('updates debug mode on toggle', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('Debug-Modus aktivieren'));
      await tester.pumpAndSettle();

      expect(settings.debugModeEnabled, isTrue);
    });

    testWidgets('updates line simplifier on toggle', (tester) async {
      await pumpPage(tester);

      // Toggle off
      await tester.tap(find.text('Linien-Simplifier verwenden'));
      await tester.pumpAndSettle();

      expect(settings.lineSimplifierEnabled, isFalse);

      // Verify slider area is ignored/faded (by checking IgnorePointer)
      // Note: We can't easily check visual opacity in unit tests without golden tests,
      // but we can check the IgnorePointer widget state.
      final ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(AnimatedOpacity),
          matching: find.byType(IgnorePointer),
        ),
      );
      expect(ignorePointer.ignoring, isTrue);
    });

    testWidgets('updates simplifier strength on slider change', (tester) async {
      await pumpPage(tester);

      // Find the first slider (Strength)
      final sliders = find.byType(Slider);
      expect(sliders, findsNWidgets(2));

      // Scroll to the slider to ensure it's visible
      await tester.scrollUntilVisible(sliders.first, 500.0);

      await tester.drag(sliders.first, const Offset(50, 0));
      await tester.pumpAndSettle();

      expect(settings.lineSimplifierStrength, isNot(0.25));
    });

    testWidgets('updates simplifier tolerance on slider change', (
      tester,
    ) async {
      await pumpPage(tester);

      // Find the second slider (Tolerance)
      final sliders = find.byType(Slider);
      expect(sliders, findsNWidgets(2));

      // Scroll to the slider to ensure it's visible
      await tester.scrollUntilVisible(sliders.last, 500.0);

      await tester.drag(sliders.last, const Offset(50, 0));
      await tester.pumpAndSettle();

      expect(settings.lineSimplifierMinTolerance, isNot(0.3));
    });
  });
}
