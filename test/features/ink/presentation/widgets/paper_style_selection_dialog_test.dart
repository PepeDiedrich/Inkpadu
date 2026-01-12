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
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TranslationProvider(
            child: const PaperStyleSelectionDialog(
              initialStyle: NotePaperStyle.plain,
            ),
          ),
        ),
      );

      expect(find.text('Choose paper style'), findsOneWidget);
      expect(find.byType(NotePaperBackground), findsOneWidget);
      expect(find.text('Plain'), findsOneWidget);
      expect(find.text('Lined'), findsOneWidget);
      expect(find.text('Grid'), findsOneWidget);
      expect(find.text('Dotted'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);
    });

    testWidgets('updates selection and preview when style is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TranslationProvider(
            child: const PaperStyleSelectionDialog(
              initialStyle: NotePaperStyle.plain,
            ),
          ),
        ),
      );

      // Verify initial state
      var background = tester.widget<NotePaperBackground>(
        find.byType(NotePaperBackground),
      );
      expect(background.paperStyle, NotePaperStyle.plain);

      // Tap on 'Lined'
      await tester.tap(find.text('Lined'));
      await tester.pump();

      // Verify state updated
      background = tester.widget<NotePaperBackground>(
        find.byType(NotePaperBackground),
      );
      expect(background.paperStyle, NotePaperStyle.lined);
    });

    testWidgets('returns selected style on Apply', (tester) async {
      NotePaperStyle? selectedStyle;

      await tester.pumpWidget(
        MaterialApp(
          home: TranslationProvider(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    selectedStyle = await showDialog<NotePaperStyle>(
                      context: context,
                      builder:
                          (context) => const PaperStyleSelectionDialog(
                            initialStyle: NotePaperStyle.plain,
                          ),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Select 'Grid'
      await tester.tap(find.text('Grid'));
      await tester.pump();

      // Click Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(selectedStyle, NotePaperStyle.grid);
    });

    testWidgets('returns null on Cancel', (tester) async {
      NotePaperStyle? selectedStyle;

      await tester.pumpWidget(
        MaterialApp(
          home: TranslationProvider(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    selectedStyle = await showDialog<NotePaperStyle>(
                      context: context,
                      builder:
                          (context) => const PaperStyleSelectionDialog(
                            initialStyle: NotePaperStyle.plain,
                          ),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Select 'Grid'
      await tester.tap(find.text('Grid'));
      await tester.pump();

      // Click Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(selectedStyle, null);
    });
  });
}
