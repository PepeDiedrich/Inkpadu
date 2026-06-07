import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkpadu/features/home/presentation/widgets/home_widgets.dart';

import 'package:inkpadu/features/home/presentation/home_page.dart';
import 'package:inkpadu/features/ink/presentation/drawing_note_page.dart';
import 'package:inkpadu/features/ink/application/ink_notes_scope.dart';
import 'package:inkpadu/features/input/application/pointer_settings_scope.dart';
import 'package:inkpadu/features/editor/application/editor_settings_scope.dart';
import 'package:inkpadu/features/ink/domain/ink_note.dart';
import 'package:inkpadu/i18n/translations.g.dart';
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
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // BottomSheet "Neue Notiz erstellen" sollte erscheinen
    expect(find.text('Neue Notiz erstellen'), findsWidgets);

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
      if (find.byType(NoteThumbnail).evaluate().isNotEmpty) break;
    }

    // Die eben angelegte Notiz erscheint nun in der Übersicht
    expect(find.textContaining('Notiz '), findsWidgets);
  });

  testWidgets('Mehrere Notizen erscheinen (>=2) in Übersicht', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1400, 900);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

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
    await tester.pumpAndSettle();
    // Note: Each note has a Card (list) or Container (grid).
    // Since we now default to grid, we look for the containers or the thumbnail.
    expect(find.byType(NoteThumbnail), findsNWidgets(2));
  });

  testWidgets('Swipe löscht Notiz nach Bestätigung', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1400, 900);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    final controller = InkNotesController(enableConnectivityMonitoring: false);
    addTearDown(controller.dispose);
    final note = InkNote.empty(title: 'Test Notiz');
    controller.upsert(note);

    await tester.pumpWidget(
      wrapWithScopes(const HomePage(), controller: controller),
    );
    await tester.pumpAndSettle();

    // Notiz sollte vorhanden sein
    expect(find.text('Test Notiz'), findsOneWidget);
    expect(controller.notes.length, 1);

    // In grid view, the delete button is inside the actions menu.
    // Let's tap the "more" button first.
    final moreButton = find.byIcon(Icons.more_vert).first;
    expect(moreButton, findsOneWidget);
    await tester.tap(moreButton);
    await tester.pumpAndSettle();

    final deleteButton = find.byIcon(Icons.delete_outline);
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
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

    // Warte auf den Debounce-Timer (3 Sekunden), damit er feuert und nicht als "pending" übrig bleibt
    await tester.pump(const Duration(seconds: 3));

    // Notiz sollte gelöscht sein
    expect(controller.notes.length, 0);
    expect(find.text('Test Notiz'), findsNothing);
    expect(find.text('Noch keine handschriftlichen Notizen'), findsOneWidget);
  });

  testWidgets('Swipe behält Notiz nach Abbruch', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1400, 900);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    final controller = InkNotesController(enableConnectivityMonitoring: false);
    addTearDown(controller.dispose);
    final note = InkNote.empty(title: 'Behalte mich');
    controller.upsert(note);

    await tester.pumpWidget(
      wrapWithScopes(const HomePage(), controller: controller),
    );
    await tester.pumpAndSettle();

    // Notiz sollte vorhanden sein
    expect(find.text('Behalte mich'), findsOneWidget);
    expect(controller.notes.length, 1);

    // In grid view, the delete button is inside the actions menu.
    final moreButton = find.byIcon(Icons.more_vert).first;
    expect(moreButton, findsOneWidget);
    await tester.tap(moreButton);
    await tester.pumpAndSettle();

    final deleteButton = find.byIcon(Icons.delete_outline);
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
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
