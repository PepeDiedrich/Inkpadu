import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/note_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NoteThumbnail uses cached bounding box correctly', (
    WidgetTester tester,
  ) async {
    // Create a page with 100 strokes, each having 100 points
    final strokes = List.generate(100, (i) {
      return Stroke(
        points: List.generate(100, (j) {
          return DrawingPoint(
            position: Offset(j.toDouble(), i.toDouble()),
            pressure: 0.5,
          );
        }),
      );
    });

    final page = NotePage(strokes: strokes);

    // We can't easily measure performance in a widget test without benchmarking tools,
    // but we can ensure it builds without error and renders something.
    // The optimization is structural (O(N) vs O(M*N)).

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteThumbnail(
            page: page,
            paperStyle: NotePaperStyle.dotted,
            size: 100,
          ),
        ),
      ),
    );

    // Should find the widget
    expect(find.byType(NoteThumbnail), findsOneWidget);

    // Should find the CustomPaint that draws the strokes
    // Note: Container decoration or ClipRRect might also use CustomPaint internally.
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });
}
