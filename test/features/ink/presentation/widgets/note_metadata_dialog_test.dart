import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/note_metadata_dialog.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/paper_style_selection_dialog.dart';
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

    testWidgets('opens paper style selection dialog and updates style', (
      tester,
    ) async {
      // Set physical size to ensure dialogs fit nicely
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

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

      // Verify current style is displayed (Plain = Blanko)
      expect(find.text('Blanko'), findsOneWidget);

      // Tap the style list tile to open selection dialog
      await tester.tap(find.text('Blanko'));
      await tester.pumpAndSettle();

      // Verify selection dialog is open
      expect(find.byType(PaperStyleSelectionDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(PaperStyleSelectionDialog),
          matching: find.text('Hintergrund wählen'),
        ),
        findsOneWidget,
      );

      // Select 'Liniert' - Ensure we tap the ChoiceChip's label
      await tester.tap(
        find.descendant(
          of: find.byType(PaperStyleSelectionDialog),
          matching: find.text('Liniert'),
        ),
      );
      await tester.pump();

      // Save selection
      await tester.tap(
        find.descendant(
          of: find.byType(PaperStyleSelectionDialog),
          matching: find.text('Speichern'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dialog closed and main dialog updated
      expect(find.byType(PaperStyleSelectionDialog), findsNothing);
      expect(find.text('Liniert'), findsOneWidget);
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
