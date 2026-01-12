import 'dart:ui';

import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart'; // We need to access the private class via the public widget or by making it visible for testing?
// Since _NotePaperPainter is private, we can't test it directly unless we modify the file or test the widget.
// Testing the widget requires pumpWidget.
// Let's modify the file to make _NotePaperPainter visible for testing, or just test the widget.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NotePaperBackground paints without error and is fast', (tester) async {
    const Size canvasSize = Size(1000, 10000); // Large canvas
    final stopwatch = Stopwatch();

    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: SizedBox(
            height: canvasSize.height,
            width: canvasSize.width,
            child: NotePaperBackground(
              paperStyle: NotePaperStyle.dotted,
              child: Container(),
            ),
          ),
        ),
      ),
    );

    // Force a frame
    stopwatch.start();
    await tester.pump();
    stopwatch.stop();

    print('First pump (Dotted, Large): ${stopwatch.elapsedMicroseconds}us');
    stopwatch.reset();

    // Verify Lined
    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: SizedBox(
            height: canvasSize.height,
            width: canvasSize.width,
            child: NotePaperBackground(
              paperStyle: NotePaperStyle.lined,
              child: Container(),
            ),
          ),
        ),
      ),
    );
    stopwatch.start();
    await tester.pump();
    stopwatch.stop();
    print('Pump (Lined, Large): ${stopwatch.elapsedMicroseconds}us');
    stopwatch.reset();

    // Verify Grid
    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: SizedBox(
            height: canvasSize.height,
            width: canvasSize.width,
            child: NotePaperBackground(
              paperStyle: NotePaperStyle.grid,
              child: Container(),
            ),
          ),
        ),
      ),
    );
    stopwatch.start();
    await tester.pump();
    stopwatch.stop();
    print('Pump (Grid, Large): ${stopwatch.elapsedMicroseconds}us');
  });
}
