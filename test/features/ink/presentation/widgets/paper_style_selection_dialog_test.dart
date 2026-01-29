import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/paper_style_selection_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await LocaleSettings.setLocale(AppLocale.en);
  });

  Widget createTestWidget(
    NotePaperStyle initialStyle, {
    void Function(NotePaperStyle)? onSelected,
  }) => TranslationProvider(
    child: MaterialApp(
      locale: LocaleSettings.currentLocale.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                final result = await showDialog<NotePaperStyle>(
                  context: context,
                  builder: (_) =>
                      PaperStyleSelectionDialog(initialStyle: initialStyle),
                );
                if (result != null && onSelected != null) {
                  onSelected(result);
                }
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('PaperStyleSelectionDialog renders correctly', (tester) async {
    await tester.pumpWidget(createTestWidget(NotePaperStyle.plain));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Verify title
    expect(find.text('Choose paper style'), findsOneWidget);

    // Verify NotePaperBackground is present
    expect(find.byType(NotePaperBackground), findsOneWidget);

    // Verify options are present
    expect(find.text('Plain'), findsOneWidget);
    expect(find.text('Lined'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('Dotted'), findsOneWidget);
  });

  testWidgets('PaperStyleSelectionDialog updates preview on selection', (
    tester,
  ) async {
    await tester.pumpWidget(createTestWidget(NotePaperStyle.plain));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Find NotePaperBackground and check initial style
    NotePaperBackground background = tester.widget(
      find.byType(NotePaperBackground),
    );
    expect(background.paperStyle, NotePaperStyle.plain);

    // Select 'Lined'
    await tester.tap(find.text('Lined'));
    await tester.pump(); // Rebuild

    // Check if background updated
    background = tester.widget(find.byType(NotePaperBackground));
    expect(background.paperStyle, NotePaperStyle.lined);
  });

  testWidgets('PaperStyleSelectionDialog returns selected style on apply', (
    tester,
  ) async {
    NotePaperStyle? selectedStyle;
    await tester.pumpWidget(
      createTestWidget(
        NotePaperStyle.plain,
        onSelected: (s) => selectedStyle = s,
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Select 'Grid'
    await tester.tap(find.text('Grid'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(selectedStyle, NotePaperStyle.grid);
  });

  testWidgets('PaperStyleSelectionDialog returns nothing on cancel', (
    tester,
  ) async {
    NotePaperStyle? selectedStyle;
    await tester.pumpWidget(
      createTestWidget(
        NotePaperStyle.plain,
        onSelected: (s) => selectedStyle = s,
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Select 'Grid' but then Cancel
    await tester.tap(find.text('Grid'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(selectedStyle, null);
  });
}
