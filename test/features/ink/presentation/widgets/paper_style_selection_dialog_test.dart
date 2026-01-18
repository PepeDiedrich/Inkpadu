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

  group('PaperStyleSelectionDialog', () {
    testWidgets('renders correctly with initial style', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: const MaterialApp(
            home: PaperStyleSelectionDialog(
              initialStyle: NotePaperStyle.lined,
            ),
          ),
        ),
      );

      // Verify title
      expect(find.text('Select Background'), findsOneWidget);

      // Verify buttons rendered (plain, lined, grid, dotted)
      expect(find.text('Plain'), findsOneWidget);
      expect(find.text('Lined'), findsOneWidget);
      expect(find.text('Grid'), findsOneWidget);
      expect(find.text('Dotted'), findsOneWidget);

      // Verify initial preview style (NotePaperBackground uses CustomPaint)
      final backgroundFinder = find.byType(NotePaperBackground);
      expect(backgroundFinder, findsOneWidget);
      final background = tester.widget<NotePaperBackground>(backgroundFinder);
      expect(background.paperStyle, NotePaperStyle.lined);
    });

    testWidgets('updates preview when new style is selected', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: const MaterialApp(
            home: PaperStyleSelectionDialog(
              initialStyle: NotePaperStyle.lined,
            ),
          ),
        ),
      );

      // Tap on 'Grid'
      await tester.tap(find.text('Grid'));
      await tester.pumpAndSettle();

      // Verify preview updated
      final backgroundFinder = find.byType(NotePaperBackground);
      final background = tester.widget<NotePaperBackground>(backgroundFinder);
      expect(background.paperStyle, NotePaperStyle.grid);
    });

    testWidgets('returns selected style on save', (tester) async {
      NotePaperStyle? selectedStyle;

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    selectedStyle = await showDialog<NotePaperStyle>(
                      context: context,
                      builder: (context) => const PaperStyleSelectionDialog(
                        initialStyle: NotePaperStyle.plain,
                      ),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Select Dotted
      await tester.tap(find.text('Dotted'));
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(selectedStyle, NotePaperStyle.dotted);
    });

    testWidgets('returns nothing on cancel', (tester) async {
      NotePaperStyle? selectedStyle;

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    selectedStyle = await showDialog<NotePaperStyle>(
                      context: context,
                      builder: (context) => const PaperStyleSelectionDialog(
                        initialStyle: NotePaperStyle.plain,
                      ),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Select Grid but Cancel
      await tester.tap(find.text('Grid'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(selectedStyle, isNull);
    });
  });
}
