import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/paper_style_selection_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await LocaleSettings.setLocale(AppLocale.en);
  });

  testWidgets('PaperStyleSelectionDialog shows all styles and allows selection', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => const PaperStyleSelectionDialog(
                      initialStyle: NotePaperStyle.plain,
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.byType(PaperStyleSelectionDialog), findsOneWidget);
    expect(find.byType(NotePaperBackground), findsOneWidget);

    // Verify all style options are present
    for (final style in NotePaperStyle.values) {
       expect(find.byIcon(style.icon), findsOneWidget);
    }

    // Verify localized text exists
    expect(find.text('Lined'), findsOneWidget);
    expect(find.text('Plain'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('Dotted'), findsOneWidget);

    // Verify initial selection (Plain)
    final initialPlainChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Plain'));
    expect(initialPlainChip.selected, isTrue);

    // Select 'Lined'
    await tester.tap(find.text('Lined'));
    await tester.pump(); // Rebuild for setState

    // Verify selection update
    final linedChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Lined'));
    expect(linedChip.selected, isTrue);

    final plainChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Plain'));
    expect(plainChip.selected, isFalse);

    // Tap Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    // Dialog should be closed
    expect(find.byType(PaperStyleSelectionDialog), findsNothing);
  });

  testWidgets('PaperStyleSelectionDialog returns correct style', (tester) async {
    NotePaperStyle? result;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showDialog<NotePaperStyle>(
                    context: context,
                    builder: (context) => const PaperStyleSelectionDialog(
                      initialStyle: NotePaperStyle.plain,
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Select 'Grid'
    await tester.tap(find.text('Grid'));
    await tester.pump();

    // Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(result, NotePaperStyle.grid);
  });

   testWidgets('PaperStyleSelectionDialog cancels correctly', (tester) async {
    NotePaperStyle? result;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showDialog<NotePaperStyle>(
                    context: context,
                    builder: (context) => const PaperStyleSelectionDialog(
                      initialStyle: NotePaperStyle.plain,
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Select 'Grid' but then Cancel
    await tester.tap(find.text('Grid'));
    await tester.pump();

    // Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Result should be null (or whatever showDialog returns on cancel, usually null)
    expect(result, isNull);
  });
}
