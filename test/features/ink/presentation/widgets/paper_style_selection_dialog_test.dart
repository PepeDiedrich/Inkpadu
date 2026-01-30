import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/paper_style_selection_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.de);
  });

  group('PaperStyleSelectionDialog', () {
    testWidgets('renders correctly with initial style', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            locale: LocaleSettings.currentLocale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showPaperStyleSelectionDialog(
                  context,
                  initialStyle: NotePaperStyle.plain,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify header (using the key we decided on: context.t.editor.adjustTitlePaper)
      // Note: adjustTitlePaper is "Titel & Papier anpassen" in DE.
      expect(find.text('Titel & Papier anpassen'), findsOneWidget);

      // Verify NotePaperBackground is present
      final backgroundFinder = find.byType(NotePaperBackground);
      expect(backgroundFinder, findsOneWidget);
      final background = tester.widget<NotePaperBackground>(backgroundFinder);
      expect(background.paperStyle, NotePaperStyle.plain);

      // Verify all options are present (using DE translations)
      expect(find.text('Blanko'), findsOneWidget);
      expect(find.text('Liniert'), findsOneWidget);
      expect(find.text('Kariert'), findsOneWidget);
      expect(find.text('Punktiert'), findsOneWidget);
    });

    testWidgets('updates preview when selecting a style', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            locale: LocaleSettings.currentLocale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showPaperStyleSelectionDialog(
                  context,
                  initialStyle: NotePaperStyle.plain,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Initial check
      expect(
        tester.widget<NotePaperBackground>(find.byType(NotePaperBackground)).paperStyle,
        NotePaperStyle.plain,
      );

      // Tap 'Liniert'
      await tester.tap(find.text('Liniert'));
      await tester.pumpAndSettle();

      // Check preview updated
      expect(
        tester.widget<NotePaperBackground>(find.byType(NotePaperBackground)).paperStyle,
        NotePaperStyle.lined,
      );
    });

    testWidgets('returns selected style on submit', (tester) async {
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
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showPaperStyleSelectionDialog(
                    context,
                    initialStyle: NotePaperStyle.plain,
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

      // Select 'Kariert'
      await tester.tap(find.text('Kariert'));
      await tester.pumpAndSettle();

      // Tap Apply (Übernehmen)
      await tester.tap(find.text('Übernehmen'));
      await tester.pumpAndSettle();

      expect(result, NotePaperStyle.grid);
    });

    testWidgets('returns null on cancel', (tester) async {
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
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showPaperStyleSelectionDialog(
                    context,
                    initialStyle: NotePaperStyle.plain,
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

      // Select 'Kariert' (just to change state)
      await tester.tap(find.text('Kariert'));
      await tester.pumpAndSettle();

      // Tap Cancel (Abbrechen)
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      expect(result, null);
    });
  });
}
