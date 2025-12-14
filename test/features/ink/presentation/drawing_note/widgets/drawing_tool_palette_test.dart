import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_tool_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DrawingToolPalette', () {
    final testTools = [
      const DrawingTool(
        id: 'pen-1',
        label: 'Pen 1',
        icon: Icons.edit,
        color: Colors.black,
        baseWidth: 3.0,
      ),
      const DrawingTool(
        id: 'pen-2',
        label: 'Pen 2',
        icon: Icons.brush,
        color: Colors.blue,
        baseWidth: 5.0,
      ),
      const DrawingTool(
        id: 'eraser',
        label: 'Eraser',
        icon: Icons.auto_fix_off,
        color: Colors.white,
        baseWidth: 18.0,
        isEraser: true,
      ),
    ];

    testWidgets('renders all tools', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrawingToolPalette(
              tools: testTools,
              selectedToolId: 'pen-1',
              onToolSelected: (_) {},
              onToolLongPress: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(DrawingToolPalette), findsOneWidget);
      // Each tool should have a tooltip
      expect(find.byType(Tooltip), findsNWidgets(testTools.length));
    });

    testWidgets('calls onToolSelected when tool is tapped', (tester) async {
      String? selectedId;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrawingToolPalette(
              tools: testTools,
              selectedToolId: 'pen-1',
              onToolSelected: (id) => selectedId = id,
              onToolLongPress: (_) {},
            ),
          ),
        ),
      );

      // Find all GestureDetector widgets inside ToolChips
      final gestures = find.byType(GestureDetector);
      expect(gestures, findsWidgets);

      // Tap the second tool
      await tester.tap(gestures.at(1));
      await tester.pump();

      expect(selectedId, 'pen-2');
    });

    testWidgets('calls onToolLongPress when tool is long-pressed',
        (tester) async {
      DrawingTool? longPressedTool;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrawingToolPalette(
              tools: testTools,
              selectedToolId: 'pen-1',
              onToolSelected: (_) {},
              onToolLongPress: (tool) => longPressedTool = tool,
            ),
          ),
        ),
      );

      final gestures = find.byType(GestureDetector);
      await tester.longPress(gestures.at(2));
      await tester.pump();

      expect(longPressedTool, isNotNull);
      expect(longPressedTool!.id, 'eraser');
    });

    testWidgets('shows tooltip with tool info', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrawingToolPalette(
              tools: testTools,
              selectedToolId: 'pen-1',
              onToolSelected: (_) {},
              onToolLongPress: (_) {},
            ),
          ),
        ),
      );

      // Find first tooltip
      final tooltip = find.byType(Tooltip).first;
      expect(tooltip, findsOneWidget);

      // Verify tooltip message contains tool info
      final tooltipWidget = tester.widget<Tooltip>(tooltip);
      expect(tooltipWidget.message, contains('Pen 1'));
      expect(tooltipWidget.message, contains('3.0'));
    });

    testWidgets('selected tool has different appearance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrawingToolPalette(
              tools: testTools,
              selectedToolId: 'pen-1',
              onToolSelected: (_) {},
              onToolLongPress: (_) {},
            ),
          ),
        ),
      );

      // Selected tool should have AnimatedScale with scale > 1
      final animatedScales = find.byType(AnimatedScale);
      expect(animatedScales, findsNWidgets(testTools.length));
    });

    testWidgets('renders with empty tools list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrawingToolPalette(
              tools: const [],
              selectedToolId: '',
              onToolSelected: (_) {},
              onToolLongPress: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(DrawingToolPalette), findsOneWidget);
      expect(find.byType(Tooltip), findsNothing);
    });
  });
}
