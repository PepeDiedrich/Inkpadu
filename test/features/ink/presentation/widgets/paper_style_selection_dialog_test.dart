import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/paper_style_selection_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.de);
  });

  Widget createSubject({
    required NotePaperStyle initialStyle,
    NavigatorObserver? navigatorObserver,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        locale: LocaleSettings.currentLocale.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await showDialog<NotePaperStyle>(
                  context: context,
                  builder: (context) => PaperStyleSelectionDialog(
                    initialPaperStyle: initialStyle,
                  ),
                );
                if (context.mounted && result != null) {
                  // Display result for verification
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Result: ${result.name}')),
                  );
                }
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows dialog with initial values', (tester) async {
    await tester.pumpWidget(createSubject(initialStyle: NotePaperStyle.lined));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Check if dialog title is shown
    expect(find.text('Hintergrund wählen'), findsOneWidget);

    // Check if "Liniert" is displayed in the preview (upper part)
    // There are 2 "Liniert": one in preview, one in grid.
    expect(find.text('Liniert'), findsAtLeastNWidgets(2));
  });

  testWidgets('shows all style options', (tester) async {
    await tester.pumpWidget(createSubject(initialStyle: NotePaperStyle.plain));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Blanko'), findsAtLeastNWidgets(1));
    expect(find.text('Liniert'), findsAtLeastNWidgets(1));
    expect(find.text('Kariert'), findsAtLeastNWidgets(1));
    expect(find.text('Punktiert'), findsAtLeastNWidgets(1));
  });

  testWidgets('cancel button closes dialog without result', (tester) async {
    await tester.pumpWidget(createSubject(initialStyle: NotePaperStyle.plain));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(find.text('Hintergrund wählen'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('apply button returns selected style', (tester) async {
    await tester.pumpWidget(createSubject(initialStyle: NotePaperStyle.plain));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Select "Kariert"
    await tester.tap(find.text('Kariert'));
    await tester.pumpAndSettle();

    // Tap Apply ("Übernehmen")
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();

    // Verify result via SnackBar
    expect(find.text('Result: grid'), findsOneWidget);
  });

  testWidgets('selecting option updates preview text', (tester) async {
     await tester.pumpWidget(createSubject(initialStyle: NotePaperStyle.plain));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Initial preview text (Blanko)
    // We expect 2 "Blanko" (preview + grid item)
    expect(find.text('Blanko'), findsAtLeastNWidgets(2));

    // Select "Kariert"
    await tester.tap(find.text('Kariert'));
    await tester.pumpAndSettle();

    // Now preview should be "Kariert"
    // We expect 2 "Kariert" (preview + grid item)
    expect(find.text('Kariert'), findsAtLeastNWidgets(2));
  });
}
