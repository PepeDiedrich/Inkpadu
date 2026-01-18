import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_tool_editor_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const standardTool = DrawingTool(
    id: 'test_tool',
    label: 'Test Pen',
    icon: Icons.edit,
    color: Colors.black,
    baseWidth: 5.0,
  );

  const eraserTool = DrawingTool(
    id: 'eraser_tool',
    label: 'Test Eraser',
    icon: Icons.auto_fix_off,
    color: Colors.white,
    baseWidth: 20.0,
    isEraser: true,
  );

  Widget createSubject(DrawingTool tool) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await DrawingToolEditorSheet.show(
                    context,
                    tool: tool,
                  );
                  // Helper to capture result if needed
                },
                child: const Text('Open Sheet'),
              ),
            );
          },
        ),
      ),
    );
  }

  testWidgets('DrawingToolEditorSheet renders standard tool correctly', (tester) async {
    await tester.pumpWidget(createSubject(standardTool));
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Test Pen anpassen'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Test Pen'), findsOneWidget);

    // Color picker should be visible
    expect(find.text('Farbe'), findsOneWidget);
    expect(find.text('Farbkreis'), findsOneWidget);

    // Icon picker should be visible
    expect(find.text('Symbol'), findsOneWidget);

    // Sliders and toggles
    expect(find.text('Linienstärke'), findsOneWidget);
    expect(find.text('Marker-Modus (durchscheinend)'), findsOneWidget);
    expect(find.text('Druckerkennung'), findsOneWidget);
  });

  testWidgets('DrawingToolEditorSheet renders eraser tool correctly', (tester) async {
    await tester.pumpWidget(createSubject(eraserTool));
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Test Eraser anpassen'), findsOneWidget);

    // Color picker should NOT be visible
    expect(find.text('Farbe'), findsNothing);
    expect(find.text('Farbkreis'), findsNothing);

    // Icon picker should NOT be visible
    expect(find.text('Symbol'), findsNothing);

    // Sliders and toggles
    expect(find.text('Radierbreite'), findsOneWidget);

    // Marker toggle should NOT be visible
    expect(find.text('Marker-Modus (durchscheinend)'), findsNothing);

    // Pressure toggle should NOT be visible
    expect(find.text('Druckerkennung'), findsNothing);
  });

  testWidgets('DrawingToolEditorSheet updates name', (tester) async {
    await tester.pumpWidget(createSubject(standardTool));
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    final nameFinder = find.widgetWithText(TextField, 'Name');
    await tester.enterText(nameFinder, 'New Name');
    await tester.pump();

    expect(find.text('New Name anpassen'), findsOneWidget);
  });

  testWidgets('DrawingToolEditorSheet applies changes', (tester) async {
    // Increase screen size to ensure bottom sheet fits
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    DrawingTool? result;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await DrawingToolEditorSheet.show(
                    context,
                    tool: standardTool,
                  );
                },
                child: const Text('Open Sheet'),
              ),
            );
          },
        ),
      ),
    ));

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Change name
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Final Name');

    // Apply
    await tester.drag(
      find.byKey(const PageStorageKey('drawing_tool_editor_sheet_scroll')),
      const Offset(0, -1000), // Drag up to scroll down
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.label, 'Final Name');
  });

  testWidgets('DrawingToolEditorSheet cancels changes', (tester) async {
    DrawingTool? result;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await DrawingToolEditorSheet.show(
                    context,
                    tool: standardTool,
                  );
                },
                child: const Text('Open Sheet'),
              ),
            );
          },
        ),
      ),
    ));

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Change name
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Changed Name');

    // Cancel
    await tester.drag(
      find.byKey(const PageStorageKey('drawing_tool_editor_sheet_scroll')),
      const Offset(0, -1000), // Drag up to scroll down
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  testWidgets('DrawingToolEditorSheet updates width via slider', (tester) async {
    // Increase screen size to ensure bottom sheet fits
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    DrawingTool? result;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await DrawingToolEditorSheet.show(
                    context,
                    tool: standardTool,
                  );
                },
                child: const Text('Open Sheet'),
              ),
            );
          },
        ),
      ),
    ));

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    final sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);

    // Initial value is 5.0
    // Move slider
    await tester.drag(sliderFinder, const Offset(50, 0));
    await tester.pump();

    // Apply
    await tester.drag(
      find.byKey(const PageStorageKey('drawing_tool_editor_sheet_scroll')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.baseWidth, isNot(standardTool.baseWidth));
  });
}
