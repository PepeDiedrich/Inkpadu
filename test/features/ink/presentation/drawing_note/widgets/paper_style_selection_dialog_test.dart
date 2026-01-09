import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/paper_style_selection_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  testWidgets('PaperStyleSelectionDialog renders all styles and preview', (
    tester,
  ) async {
    NotePaperStyle? selectedStyle;

    // Set surface size to ensure dialog fits
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: TranslationProvider(
          child: PaperStyleSelectionDialog(
            initialStyle: NotePaperStyle.plain,
            onStyleSelected: (style) {
              selectedStyle = style;
            },
          ),
        ),
      ),
    );

    // Check title
    expect(find.text('Select background'), findsOneWidget);

    // Check all style options are present
    expect(find.text('Plain'), findsOneWidget);
    expect(find.text('Lined'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('Dotted'), findsOneWidget);

    // Check preview exists
    expect(find.byType(CustomPaint), findsWidgets);

    // Tap on Lined
    await tester.tap(find.text('Lined'));
    await tester.pump();

    // Verify Apply button works
    await tester.ensureVisible(find.text('Apply'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(selectedStyle, NotePaperStyle.lined);
  });

  testWidgets('PaperStyleSelectionDialog cancel button works', (tester) async {
    NotePaperStyle? selectedStyle;

    // Set surface size to ensure dialog fits
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: TranslationProvider(
          child: PaperStyleSelectionDialog(
            initialStyle: NotePaperStyle.plain,
            onStyleSelected: (style) {
              selectedStyle = style;
            },
          ),
        ),
      ),
    );

    // Tap on Lined but then Cancel
    await tester.tap(find.text('Lined'));
    await tester.pump();

    await tester.ensureVisible(find.text('Cancel'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(selectedStyle, isNull);
  });
}
