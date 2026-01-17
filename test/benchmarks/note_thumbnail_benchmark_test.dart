import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/note_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NoteThumbnail layout benchmark', (tester) async {
    // 1. Setup a heavy note page
    final int strokeCount = 1000;
    final int pointsPerStroke = 100;

    final List<Stroke> strokes = List.generate(strokeCount, (i) {
      return Stroke(
        points: List.generate(pointsPerStroke, (j) {
          return DrawingPoint(
            position: Offset(i * 10.0 + j, i * 10.0 + j),
            pressure: 0.5,
          );
        }),
      );
    });

    final page = NotePage(strokes: strokes);

    // 2. Measure build/layout time
    final stopwatch = Stopwatch()..start();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteThumbnail(
            page: page,
            paperStyle: NotePaperStyle.plain,
            size: 200,
          ),
        ),
      ),
    );

    stopwatch.stop();
    debugPrint('NoteThumbnail build time with ${strokeCount * pointsPerStroke} total points: ${stopwatch.elapsedMilliseconds}ms');

    // Warm-up run was above. Now run multiple times to average.
    int iterations = 10;
    int totalTime = 0;

    for (int i = 0; i < iterations; i++) {
        final sw = Stopwatch()..start();
        // Re-pump a new widget to force rebuild
         await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteThumbnail(
                page: page, // same page instance
                paperStyle: NotePaperStyle.plain,
                size: 200,
              ),
            ),
          ),
        );
        sw.stop();
        totalTime += sw.elapsedMilliseconds;
    }

    debugPrint('Average subsequent pump time: ${totalTime / iterations}ms');
  });
}
