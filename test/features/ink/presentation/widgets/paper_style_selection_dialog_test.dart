import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/paper_style_selection_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  Widget createSubject({
    required NotePaperStyle initialStyle,
    void Function(NotePaperStyle?)? onPop,
  }) => TranslationProvider(
    child: MaterialApp(
      home: Builder(
        builder:
            (context) => Scaffold(
              body: Center(
                child: Builder(
                  builder:
                      (context) => ElevatedButton(
                        onPressed: () async {
                          final result = await showDialog<NotePaperStyle>(
                            context: context,
                            builder:
                                (context) => PaperStyleSelectionDialog(
                                  initialStyle: initialStyle,
                                ),
                          );
                          if (onPop != null) onPop(result);
                        },
                        child: const Text('Open Dialog'),
                      ),
                ),
              ),
            ),
      ),
    ),
  );

  testWidgets('renders dialog with initial style', (tester) async {
    await tester.pumpWidget(createSubject(initialStyle: NotePaperStyle.plain));
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.byType(PaperStyleSelectionDialog), findsOneWidget);
    expect(find.text('Choose background'), findsOneWidget);

    // Check initial selection (plain)
    final plainChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Plain'),
    );
    expect(plainChip.selected, isTrue);

    // Check others are not selected
    final linedChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Lined'),
    );
    expect(linedChip.selected, isFalse);

    // Check preview uses initial style
    final preview = tester.widget<NotePaperBackground>(
      find.descendant(
        of: find.byType(AspectRatio),
        matching: find.byType(NotePaperBackground),
      ),
    );
    expect(preview.paperStyle, NotePaperStyle.plain);
  });

  testWidgets('updates preview when style selected', (tester) async {
    await tester.pumpWidget(createSubject(initialStyle: NotePaperStyle.plain));
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Select Lined
    await tester.tap(find.text('Lined'));
    await tester.pump();

    // Check preview updated
    final preview = tester.widget<NotePaperBackground>(
      find.descendant(
        of: find.byType(AspectRatio),
        matching: find.byType(NotePaperBackground),
      ),
    );
    expect(preview.paperStyle, NotePaperStyle.lined);
  });

  testWidgets('returns selected style on confirm', (tester) async {
    NotePaperStyle? result;
    await tester.pumpWidget(
      createSubject(
        initialStyle: NotePaperStyle.plain,
        onPop: (val) => result = val,
      ),
    );
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Select Grid
    await tester.tap(find.text('Grid'));
    await tester.pump();

    // Confirm
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(result, NotePaperStyle.grid);
  });

  testWidgets('returns null on cancel', (tester) async {
    NotePaperStyle? result;
    await tester.pumpWidget(
      createSubject(
        initialStyle: NotePaperStyle.plain,
        onPop: (val) => result = val,
      ),
    );
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Select Grid but then cancel
    await tester.tap(find.text('Grid'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
