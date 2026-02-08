import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/paper_style_selection_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  Widget createSubject({required NotePaperStyle initialStyle}) =>
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: PaperStyleSelectionDialog(initialStyle: initialStyle),
          ),
        ),
      );

  testWidgets('PaperStyleSelectionDialog renders correctly with initial style',
      (tester) async {
    await tester.pumpWidget(createSubject(initialStyle: NotePaperStyle.plain));

    expect(find.text('Select Background'), findsOneWidget);
    expect(find.text('Plain'), findsOneWidget);
    expect(find.text('Lined'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('Dotted'), findsOneWidget);

    // Initial selection check
    final plainChip =
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Plain'));
    expect(plainChip.selected, isTrue);

    final linedChip =
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Lined'));
    expect(linedChip.selected, isFalse);
  });

  testWidgets('Selecting a style updates the selection', (tester) async {
    await tester.pumpWidget(createSubject(initialStyle: NotePaperStyle.plain));

    await tester.tap(find.text('Lined'));
    await tester.pumpAndSettle();

    final linedChip =
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Lined'));
    expect(linedChip.selected, isTrue);

    final plainChip =
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Plain'));
    expect(plainChip.selected, isFalse);
  });

  testWidgets('Confirm button returns selected style', (tester) async {
    NotePaperStyle? result;
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<NotePaperStyle>(
                  context: context,
                  builder: (context) => const PaperStyleSelectionDialog(
                    initialStyle: NotePaperStyle.plain,
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grid'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(result, NotePaperStyle.grid);
  });

  testWidgets('Cancel button returns null', (tester) async {
    NotePaperStyle? result;
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<NotePaperStyle>(
                  context: context,
                  builder: (context) => const PaperStyleSelectionDialog(
                    initialStyle: NotePaperStyle.plain,
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grid')); // Select something else
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
