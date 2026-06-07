import 'package:inkpadu/features/ink/domain/note_paper_style.dart';
import 'package:inkpadu/features/ink/presentation/widgets/paper_style_selection_dialog.dart';
import 'package:inkpadu/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  Widget pumpDialog(NotePaperStyle initialStyle) => TranslationProvider(
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder:
              (context) => TextButton(
                onPressed:
                    () async => showDialog<NotePaperStyle>(
                      context: context,
                      builder:
                          (context) => PaperStyleSelectionDialog(
                            initialStyle: initialStyle,
                          ),
                    ),
                child: const Text('Show Dialog'),
              ),
        ),
      ),
    ),
  );

  testWidgets('PaperStyleSelectionDialog renders correctly', (tester) async {
    await tester.pumpWidget(pumpDialog(NotePaperStyle.plain));
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.byType(PaperStyleSelectionDialog), findsOneWidget);
    expect(find.text('Select background'), findsOneWidget);
    expect(find.text('Plain'), findsOneWidget);
    expect(find.text('Lined'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('Dotted'), findsOneWidget);
  });

  testWidgets('Save button returns selected style', (tester) async {
    NotePaperStyle? result;

    await tester.pumpWidget(TranslationProvider(
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
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grid'));
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, NotePaperStyle.grid);
  });

  testWidgets('Cancel button returns null', (tester) async {
    NotePaperStyle? result;

    await tester.pumpWidget(TranslationProvider(
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
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, null);
  });
}
