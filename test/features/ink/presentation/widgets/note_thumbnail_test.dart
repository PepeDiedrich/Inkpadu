import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/note_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NoteThumbnail renders correctly with strokes', (tester) async {
    // Create a page with strokes
    final stroke = Stroke(
      points: [
        DrawingPoint(
            position: const Offset(10, 10)),
        DrawingPoint(
            position: const Offset(20, 20)),
      ],
    );
    final page = NotePage(strokes: [stroke]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteThumbnail(
            page: page,
            paperStyle: NotePaperStyle.plain,
            size: 100,
          ),
        ),
      ),
    );

    expect(find.byType(NoteThumbnail), findsOneWidget);
    // Find CustomPaint specifically inside NoteThumbnail
    expect(
      find.descendant(
        of: find.byType(NoteThumbnail),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  testWidgets('NoteThumbnail uses cached bounding box indirectly', (tester) async {
    // This test implicitly verifies that the optimization doesn't break rendering

    // Create a complex stroke
    final List<DrawingPoint> points = [];
    for (int i = 0; i < 100; i++) {
      points.add(DrawingPoint(
        position: Offset(i.toDouble(), i.toDouble()),
      ));
    }
    final stroke = Stroke(points: points);
    final page = NotePage(strokes: [stroke]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteThumbnail(
            page: page,
            paperStyle: NotePaperStyle.plain,
            size: 100,
          ),
        ),
      ),
    );

    // Verify it rendered
    expect(
      find.descendant(
        of: find.byType(NoteThumbnail),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });
}
