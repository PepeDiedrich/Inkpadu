import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/paper_style_selection_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await LocaleSettings.setLocale(AppLocale.en);
  });

  Future<void> openDialog(
    WidgetTester tester, {
    NotePaperStyle initialStyle = NotePaperStyle.plain,
  }) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await showDialog<NotePaperStyle>(
                      context: context,
                      builder: (context) => PaperStyleSelectionDialog(
                        initialStyle: initialStyle,
                      ),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders correctly with initial style', (tester) async {
    await openDialog(tester, initialStyle: NotePaperStyle.plain);

    expect(find.text('Choose paper style'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(NotePaperStyle.values.length));

    // Verify 'Plain' is selected
    final plainChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Plain'),
    );
    expect(plainChip.selected, isTrue);

    // Verify 'Lined' is not selected
    final linedChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Lined'),
    );
    expect(linedChip.selected, isFalse);
  });

  testWidgets('selects a different style', (tester) async {
    await openDialog(tester, initialStyle: NotePaperStyle.plain);

    // Tap 'Grid'
    await tester.tap(find.text('Grid'));
    await tester.pump();

    final gridChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Grid'),
    );
    expect(gridChip.selected, isTrue);

    final plainChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Plain'),
    );
    expect(plainChip.selected, isFalse);
  });

  testWidgets('Cancel button closes dialog', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(PaperStyleSelectionDialog), findsNothing);
  });

  testWidgets('Confirm button closes dialog', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.byType(PaperStyleSelectionDialog), findsNothing);
  });
}
