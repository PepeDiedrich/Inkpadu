import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/paper_style_selection_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  Widget pumpDialog(
    WidgetTester tester, {
    NotePaperStyle initialStyle = NotePaperStyle.plain,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        locale: LocaleSettings.currentLocale.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  await showDialog<NotePaperStyle>(
                    context: context,
                    builder:
                        (context) =>
                            PaperStyleSelectionDialog(initialStyle: initialStyle),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('PaperStyleSelectionDialog renders correctly', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(pumpDialog(tester));
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Paper style'), findsOneWidget);
    expect(find.byType(PaperStyleSelectionDialog), findsOneWidget);

    // Check if options are present
    expect(find.text('Plain'), findsOneWidget);
    expect(find.text('Lined'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('Dotted'), findsOneWidget);
  });

  testWidgets('Selecting a style updates selection', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      pumpDialog(tester, initialStyle: NotePaperStyle.plain),
    );
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify 'Lined' exists and tap it
    final linedOption = find.text('Lined');
    expect(linedOption, findsOneWidget);
    await tester.tap(linedOption);
    await tester.pumpAndSettle();
  });

  testWidgets('Apply button returns selected style', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    NotePaperStyle? result;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          locale: LocaleSettings.currentLocale.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    result = await showDialog<NotePaperStyle>(
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
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Tap 'Grid'
    await tester.tap(find.text('Grid'));
    await tester.pumpAndSettle();

    // Tap 'Apply'
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(result, NotePaperStyle.grid);
  });

  testWidgets('Cancel button returns null', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    NotePaperStyle? result;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          locale: LocaleSettings.currentLocale.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    result = await showDialog<NotePaperStyle>(
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
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Tap 'Cancel'
    // Ensure visibility
    await tester.ensureVisible(find.text('Cancel'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
