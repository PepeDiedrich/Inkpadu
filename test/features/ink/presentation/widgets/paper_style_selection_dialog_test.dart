import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/paper_style_selection_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  Widget createTestWidget(NotePaperStyle initialStyle) => TranslationProvider(
    child: MaterialApp(
      locale: AppLocale.en.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(
        body: PaperStyleSelectionDialog(initialStyle: initialStyle),
      ),
    ),
  );

  testWidgets('renders correctly with initial style', (tester) async {
    await tester.pumpWidget(createTestWidget(NotePaperStyle.plain));
    await tester.pumpAndSettle();

    expect(find.text('Select background'), findsOneWidget);
    expect(find.byType(NotePaperBackground), findsOneWidget);
    expect(find.text('Plain'), findsOneWidget);
    expect(find.text('Lined'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('Dotted'), findsOneWidget);

    final plainChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Plain'),
    );
    expect(plainChip.selected, isTrue);

    final linedChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Lined'),
    );
    expect(linedChip.selected, isFalse);
  });

  testWidgets('updates selection and preview when option is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(createTestWidget(NotePaperStyle.plain));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lined'));
    await tester.pump();

    // Verify preview updated
    final background = tester.widget<NotePaperBackground>(
      find.byType(NotePaperBackground),
    );
    expect(background.paperStyle, NotePaperStyle.lined);

    // Verify selection updated
    final linedChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Lined'),
    );
    expect(linedChip.selected, isTrue);

    final plainChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Plain'),
    );
    expect(plainChip.selected, isFalse);
  });

  testWidgets('returns selected style on confirm', (tester) async {
    NotePaperStyle? result;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          locale: AppLocale.en.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<NotePaperStyle>(
                  context: context,
                  builder: (_) => const PaperStyleSelectionDialog(
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
    await tester.pump();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(result, NotePaperStyle.grid);
  });

  testWidgets('returns null on cancel', (tester) async {
    NotePaperStyle? result;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          locale: AppLocale.en.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<NotePaperStyle>(
                  context: context,
                  builder: (_) => const PaperStyleSelectionDialog(
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

    await tester.tap(find.text('Grid')); // Select grid but then cancel
    await tester.pump();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
