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
    testWidgets('renders correctly and allows selection', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    await showPaperStyleSelectionDialog(
                      context,
                      initialStyle: NotePaperStyle.plain,
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

      // Verify title
      expect(find.text('Select Background'), findsOneWidget); // "Select Background" from EN translation

      // Verify preview exists
      expect(find.byType(NotePaperBackground), findsOneWidget);

      // Verify initial selection (Plain should be selected)
      // NotePaperStyle.plain icon is crop_square.
      // ChoiceChip uses avatars for icons.
      final plainChip = find.widgetWithIcon(ChoiceChip, NotePaperStyle.plain.icon);
      expect(plainChip, findsOneWidget);
      expect(
        tester.widget<ChoiceChip>(plainChip).selected,
        isTrue,
        reason: 'Plain style should be selected initially',
      );

      // Select another style (Lined)
      final linedChip = find.widgetWithIcon(ChoiceChip, NotePaperStyle.lined.icon);
      expect(linedChip, findsOneWidget);
      await tester.tap(linedChip);
      await tester.pumpAndSettle();

      expect(
        tester.widget<ChoiceChip>(linedChip).selected,
        isTrue,
        reason: 'Lined style should be selected after tap',
      );

      // Verify NotePaperBackground updated
      final background = tester.widget<NotePaperBackground>(
        find.byType(NotePaperBackground),
      );
      expect(background.paperStyle, NotePaperStyle.lined);

      // Close dialog (Apply)
      await tester.tap(find.text('Apply')); // "Apply" from common
      await tester.pumpAndSettle();

      // Dialog closed
      expect(find.byType(PaperStyleSelectionDialog), findsNothing);
    });

    testWidgets('cancel closes dialog without result', (tester) async {
      NotePaperStyle? result;

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    result = await showPaperStyleSelectionDialog(
                      context,
                      initialStyle: NotePaperStyle.plain,
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Select Lined
      final linedChip = find.widgetWithIcon(ChoiceChip, NotePaperStyle.lined.icon);
      await tester.tap(linedChip);
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}
