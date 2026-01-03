import 'package:flutter_test/flutter_test.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/note_thumbnail.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('NoteThumbnail renders correctly with strokes', (WidgetTester tester) async {
    // Create a dummy stroke
    final stroke = Stroke(
      points: [
        DrawingPoint(position: const Offset(10, 10), pressure: 0.5),
        DrawingPoint(position: const Offset(20, 20), pressure: 0.5),
        DrawingPoint(position: const Offset(30, 10), pressure: 0.5),
      ],
      color: Colors.black,
      baseWidth: 5.0,
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
    // Use descendant finding to ensure we are looking at the CustomPaint inside NoteThumbnail
    // and ignore any potential CustomPaints from Scaffold/MaterialApp internals.
    expect(
      find.descendant(
        of: find.byType(NoteThumbnail),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });
}
