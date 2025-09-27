import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_handwriting_app/features/home/presentation/home_page.dart';

void main() {
  testWidgets('bearbeitete Notiz aktualisiert die Übersicht', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('Meeting-Notizen'), findsOneWidget);

    await tester.tap(find.text('Meeting-Notizen'));
    await tester.pumpAndSettle();

    expect(find.text('Notiz bearbeiten'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).last,
      'Überarbeitete Inhalte',
    );

    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    expect(find.text('Überarbeitete Inhalte'), findsOneWidget);
  });

  testWidgets('neue Notiz wird angelegt und angezeigt', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    await tester.tap(find.byIcon(Icons.create));
    await tester.pumpAndSettle();

    await tester.enterText(find.bySemanticsLabel('Titel'), 'Neue Idee');
    await tester.enterText(find.byType(TextField).last, 'Das ist neu');

    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    expect(find.text('Neue Idee'), findsOneWidget);
    expect(find.text('Das ist neu'), findsOneWidget);
  });
}
