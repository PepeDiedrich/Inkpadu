import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_handwriting_app/features/home/presentation/home_page.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note_page.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../helpers/sqflite_test_util.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ensureTestDatabaseFactory();
    LocaleSettings.setLocale(AppLocale.de);
  });

  setUp(() async {
    await resetTestDatabase();
  });

  tearDownAll(() async {
    await disposeTestDatabase();
  });

  Widget wrapWithScopes(Widget child, {InkNotesController? controller}) {
    final notes =
        controller ?? InkNotesController(enableConnectivityMonitoring: false);
    final pointer = PointerSettings();
    final editorSettings = EditorSettings();
    return InkNotesScope(
      controller: notes,
      child: PointerSettingsScope(
        settings: pointer,
        child: EditorSettingsScope(
          settings: editorSettings,
          child: TranslationProvider(
            child: MaterialApp(
              locale: LocaleSettings.currentLocale.flutterLocale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              home: child,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Liste zeigt neu erstellte Notiz per FAB', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1400, 900);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    final controller = InkNotesController(enableConnectivityMonitoring: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapWithScopes(const HomePage(), controller: controller),
    );

    // Leerer Zustand Text prüfen
    expect(find.text('Noch keine handschriftlichen Notizen'), findsOneWidget);

    // Neue Notiz via FAB
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // BottomSheet "Neue Notiz erstellen" sollte erscheinen
    expect(find.text('Neue Notiz erstellen'), findsOneWidget);

    // Auf "Leere Notiz" tippen
    await tester.tap(find.text('Leere Notiz'));
    await tester.pumpAndSettle();

    // Dialog sollte erscheinen
    expect(find.byType(Dialog), findsOneWidget);

    // Dialog ohne Anpassungen bestätigen (leerer Titel führt zu Auto-Titel)
    await tester.tap(find.widgetWithText(FilledButton, 'Weiter'));
    await tester.pumpAndSettle();

    // Wir sind jetzt auf der Zeichen-Seite, DrawingNotePage sollte da sein
    expect(find.byType(DrawingNotePage), findsOneWidget);

    // Zurück zur Liste
    // Zurück zur Liste über Navigator.pop (stabiler in Tests als pageBack bei MaterialApp ohne NavigatorBar)
    Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
    for (int i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 30));
      if (find.byType(ListTile).evaluate().isNotEmpty) break;
    }

    // Die eben angelegte Notiz erscheint nun in der Übersicht
    expect(find.textContaining('Notiz '), findsWidgets);
  });

  testWidgets('Mehrere Notizen erscheinen (>=2) in Übersicht', (tester) async {
    final controller = InkNotesController(enableConnectivityMonitoring: false);
    addTearDown(controller.dispose);
    // Zwei vorhandene Notizen anlegen (verschiedene IDs & Timestamps)
    // Erzeuge zwei Notizen ohne künstliche Delays (IDs durch Microseconds bereits unterschiedlich)
    controller.upsert(InkNote.empty());
    controller.upsert(InkNote.empty());

    await tester.pumpWidget(
      wrapWithScopes(const HomePage(), controller: controller),
    );

    // Kurzes Pump für Rebuild
    await tester.pump();
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('Löschen-Button löscht Notiz nach Bestätigung', (tester) async {
    final controller = InkNotesController(enableConnectivityMonitoring: false);
    addTearDown(controller.dispose);
    final note = InkNote.empty(title: 'Test Notiz');
    controller.upsert(note);

    await tester.pumpWidget(
      wrapWithScopes(const HomePage(), controller: controller),
    );
    await tester.pump();

    // Notiz sollte vorhanden sein
    expect(find.text('Test Notiz'), findsOneWidget);
    expect(controller.notes.length, 1);

    // Löschen-Button finden und drücken
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // Bestätigungsdialog sollte erscheinen
    expect(find.text('Notiz löschen'), findsOneWidget);
    expect(
      find.text('Möchten Sie "Test Notiz" wirklich löschen?'),
      findsOneWidget,
    );

    // Bestätigen
    await tester.tap(find.widgetWithText(FilledButton, 'Löschen'));
    await tester.pumpAndSettle();

    // Notiz sollte gelöscht sein
    expect(controller.notes.length, 0);
    expect(find.text('Test Notiz'), findsNothing);
    expect(find.text('Noch keine handschriftlichen Notizen'), findsOneWidget);
  });

  testWidgets('Löschen-Button behält Notiz nach Abbruch', (tester) async {
    final controller = InkNotesController(enableConnectivityMonitoring: false);
    addTearDown(controller.dispose);
    final note = InkNote.empty(title: 'Behalte mich');
    controller.upsert(note);

    await tester.pumpWidget(
      wrapWithScopes(const HomePage(), controller: controller),
    );
    await tester.pump();

    // Notiz sollte vorhanden sein
    expect(find.text('Behalte mich'), findsOneWidget);
    expect(controller.notes.length, 1);

    // Löschen-Button drücken
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // Bestätigungsdialog erscheint
    expect(find.text('Notiz löschen'), findsOneWidget);

    // Abbrechen
    await tester.tap(find.widgetWithText(TextButton, 'Abbrechen'));
    await tester.pumpAndSettle();

    // Notiz sollte noch vorhanden sein
    expect(controller.notes.length, 1);
    expect(find.text('Behalte mich'), findsOneWidget);
  });
}
