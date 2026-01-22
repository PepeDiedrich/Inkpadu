import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_canvas.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DrawingController controller;
  late DrawingTool penTool;
  late DrawingTool eraserTool;
  late DrawingTool Function(String? id) resolveTool;
  late double Function(DrawingTool tool) eraserRadiusFor;

  setUp(() {
    controller = DrawingController();
    penTool = const DrawingTool(
      id: 'pen',
      label: 'Stift',
      icon: Icons.edit,
      color: Colors.black,
      baseWidth: 2.0,
    );
    eraserTool = const DrawingTool(
      id: 'eraser',
      label: 'Radierer',
      icon: Icons.clear,
      color: Colors.white,
      baseWidth: 10.0,
      isEraser: true,
      usePressure: false,
    );
    resolveTool = (String? id) {
      if (id == 'eraser') return eraserTool;
      return penTool;
    };
    eraserRadiusFor = (DrawingTool tool) => tool.baseWidth;
  });

  tearDown(() {
    controller.dispose();
  });

  Widget createTestWidget({
    required DrawingController controller,
    required DrawingTool currentTool,
    required DrawingTool Function(String? id) resolveTool,
    required double Function(DrawingTool tool) eraserRadiusFor,
    required VoidCallback onPersistDrawing,
    required VoidCallback onTwoFingerUndo,
    required VoidCallback onThreeFingerRedo,
    NotePaperStyle paperStyle = NotePaperStyle.plain,
    double initialCanvasHeight = 1600,
    double canvasBottomPadding = 600,
    String? importedPdfText,
  }) => MaterialApp(
    home: Scaffold(
      body: PointerSettingsScope(
        settings: PointerSettings(),
        child: EditorSettingsScope(
          settings: EditorSettings(),
          child: DrawingCanvas(
            drawingController: controller,
            currentTool: currentTool,
            resolveTool: resolveTool,
            eraserRadiusFor: eraserRadiusFor,
            onPersistDrawing: onPersistDrawing,
            onTwoFingerUndo: onTwoFingerUndo,
            onThreeFingerRedo: onThreeFingerRedo,
            paperStyle: paperStyle,
            initialCanvasHeight: initialCanvasHeight,
            canvasBottomPadding: canvasBottomPadding,
            importedPdfText: importedPdfText,
          ),
        ),
      ),
    ),
  );

  group('DrawingCanvas', () {
    testWidgets('rendert korrekt mit Standardparametern', (
      WidgetTester tester,
    ) async {
      bool persistCalled = false;
      bool undoCalled = false;
      bool redoCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          controller: controller,
          currentTool: penTool,
          resolveTool: resolveTool,
          eraserRadiusFor: eraserRadiusFor,
          onPersistDrawing: () => persistCalled = true,
          onTwoFingerUndo: () => undoCalled = true,
          onThreeFingerRedo: () => redoCalled = true,
        ),
      );

      expect(find.byType(DrawingCanvas), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byType(NotePaperBackground), findsOneWidget);
      expect(persistCalled, false);
      expect(undoCalled, false);
      expect(redoCalled, false);
    });

    testWidgets('zeichnet Strich bei Touch-Eingabe', (
      WidgetTester tester,
    ) async {
      bool persistCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          controller: controller,
          currentTool: penTool,
          resolveTool: resolveTool,
          eraserRadiusFor: eraserRadiusFor,
          onPersistDrawing: () => persistCalled = true,
          onTwoFingerUndo: () {},
          onThreeFingerRedo: () {},
        ),
      );

      // Simuliere Touch-Start
      final center = tester.getCenter(find.byType(DrawingCanvas));
      final gesture = await tester.startGesture(center);
      await tester.pump();

      expect(controller.currentStroke, isNotNull);
      expect(controller.currentStroke!.points.length, 1);

      // Simuliere Touch-Move
      await gesture.moveBy(const Offset(50, 50));
      await tester.pump();

      expect(controller.currentStroke!.points.length, 2);

      // Simuliere Touch-End
      await gesture.up();
      await tester.pump();

      expect(controller.currentStroke, isNull);
      expect(persistCalled, true);
    });

    testWidgets('handhabt Zwei-Finger-Tap für Undo', (
      WidgetTester tester,
    ) async {
      bool undoCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          controller: controller,
          currentTool: penTool,
          resolveTool: resolveTool,
          eraserRadiusFor: eraserRadiusFor,
          onPersistDrawing: () {},
          onTwoFingerUndo: () => undoCalled = true,
          onThreeFingerRedo: () {},
        ),
      );

      final center = tester.getCenter(find.byType(DrawingCanvas));

      // Simuliere Zwei-Finger-Tap
      final gesture1 = await tester.startGesture(center);
      final gesture2 = await tester.startGesture(center + const Offset(10, 10));

      await tester.pump(const Duration(milliseconds: 200));

      await gesture1.up();
      await gesture2.up();
      await tester.pump();

      expect(undoCalled, true);
    });

    testWidgets('handhabt Drei-Finger-Tap für Redo', (
      WidgetTester tester,
    ) async {
      bool redoCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          controller: controller,
          currentTool: penTool,
          resolveTool: resolveTool,
          eraserRadiusFor: eraserRadiusFor,
          onPersistDrawing: () {},
          onTwoFingerUndo: () {},
          onThreeFingerRedo: () => redoCalled = true,
        ),
      );

      final center = tester.getCenter(find.byType(DrawingCanvas));

      final gesture1 = await tester.startGesture(center + const Offset(-12, 0));
      final gesture2 = await tester.startGesture(center + const Offset(0, 0));
      final gesture3 = await tester.startGesture(center + const Offset(12, 0));

      await tester.pump(const Duration(milliseconds: 140));

      await gesture1.up();
      await tester.pump(const Duration(milliseconds: 30));
      await gesture2.up();
      await tester.pump(const Duration(milliseconds: 30));
      await gesture3.up();
      await tester.pump();

      expect(redoCalled, true);
    });

    testWidgets('konfiguriert InteractiveViewer ohne Zoom', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          controller: controller,
          currentTool: penTool,
          resolveTool: resolveTool,
          eraserRadiusFor: eraserRadiusFor,
          onPersistDrawing: () {},
          onTwoFingerUndo: () {},
          onThreeFingerRedo: () {},
        ),
      );

      final interactiveViewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(interactiveViewer.scaleEnabled, isFalse);
      expect(interactiveViewer.panEnabled, isFalse);
      expect(
        interactiveViewer.boundaryMargin,
        const EdgeInsets.symmetric(horizontal: 120, vertical: 120),
      );
      expect(interactiveViewer.alignment, Alignment.topCenter);
    });

    testWidgets('scrollt automatisch bei tiefen Inhalten', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          controller: controller,
          currentTool: penTool,
          resolveTool: resolveTool,
          eraserRadiusFor: eraserRadiusFor,
          onPersistDrawing: () {},
          onTwoFingerUndo: () {},
          onThreeFingerRedo: () {},
          initialCanvasHeight: 1000,
        ),
      );

      // Erstelle tiefe Striche
      final deepStrokes = List.generate(
        10,
        (i) => Stroke(
          points: [
            DrawingPoint(position: Offset(100, 2000 + i * 100), pressure: 1.0),
          ],
          baseWidth: 2.0,
        ),
      );

      controller.initialize(deepStrokes);
      await tester.pump();

      // Scroll sollte funktionieren
      final scrollable = find.byType(SingleChildScrollView);
      expect(scrollable, findsOneWidget);

      // Simuliere Scroll
      await tester.drag(scrollable, const Offset(0, -200));
      await tester.pump();
    });
  });
}
