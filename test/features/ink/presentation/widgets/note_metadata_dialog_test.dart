import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/note_metadata_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.de);
  });

  group('NoteMetadataResult', () {
    test('stores title and paper style', () {
      const result = NoteMetadataResult(
        title: 'My Note',
        paperStyle: NotePaperStyle.grid,
      );
      expect(result.title, 'My Note');
      expect(result.paperStyle, NotePaperStyle.grid);
    });
  });

  group('showNoteMetadataDialog', () {
    testWidgets('shows dialog with initial values', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            locale: LocaleSettings.currentLocale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showNoteMetadataDialog(
                  context,
                  initialTitle: 'Initial Title',
                  initialPaperStyle: NotePaperStyle.lined,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Dialog should be shown
      expect(find.text('Neue Notiz'), findsOneWidget);
      // Initial title should be in text field
      expect(find.text('Initial Title'), findsOneWidget);
    });

    testWidgets('shows editing title when isEditing is true', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            locale: LocaleSettings.currentLocale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showNoteMetadataDialog(
                  context,
                  initialTitle: 'Existing',
                  initialPaperStyle: NotePaperStyle.plain,
                  isEditing: true,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Titel & Papier anpassen'), findsOneWidget);
      expect(find.text('Speichern'), findsNWidgets(2)); // AppBar and bottom
    });

    testWidgets('can close dialog with cancel button', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            locale: LocaleSettings.currentLocale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showNoteMetadataDialog(
                  context,
                  initialTitle: '',
                  initialPaperStyle: NotePaperStyle.plain,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Neue Notiz'), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.text('Abbrechen').first);
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Neue Notiz'), findsNothing);
    });

    testWidgets('can close dialog with close icon', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            locale: LocaleSettings.currentLocale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showNoteMetadataDialog(
                  context,
                  initialTitle: '',
                  initialPaperStyle: NotePaperStyle.plain,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap close icon in AppBar
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Neue Notiz'), findsNothing);
    });

    testWidgets('shows selected paper style and can open selection dialog',
        (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            locale: LocaleSettings.currentLocale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showNoteMetadataDialog(
                  context,
                  initialTitle: '',
                  initialPaperStyle: NotePaperStyle.plain,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Selected style should be visible
      expect(find.text('Blanko'), findsOneWidget);

      // Other styles should NOT be visible initially
      expect(find.text('Liniert'), findsNothing);

      // Tap on the style selector (ListTile with text 'Blanko')
      await tester.tap(find.text('Blanko'));
      await tester.pumpAndSettle();

      // Now selection dialog should be open
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Hintergrund wählen'), findsAtLeastNWidgets(1));
      expect(find.text('Liniert'), findsOneWidget);
      expect(find.text('Kariert'), findsOneWidget);
      expect(find.text('Punktiert'), findsOneWidget);
    });

    testWidgets('can enter title text', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            locale: LocaleSettings.currentLocale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showNoteMetadataDialog(
                  context,
                  initialTitle: '',
                  initialPaperStyle: NotePaperStyle.plain,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter text in text field
      await tester.enterText(find.byType(TextField), 'New Note Title');
      await tester.pump();

      expect(find.text('New Note Title'), findsOneWidget);
    });
  });
}
