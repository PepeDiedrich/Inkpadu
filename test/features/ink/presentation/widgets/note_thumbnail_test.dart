
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/note_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NoteThumbnail renders correctly with strokes', (tester) async {
    final stroke = Stroke(
      points: [
        DrawingPoint(position: const Offset(10, 10), pressure: 0.5),
        DrawingPoint(position: const Offset(20, 20), pressure: 0.5),
        DrawingPoint(position: const Offset(30, 10), pressure: 0.5),
      ],
      color: Colors.red,
      baseWidth: 2.0,
    );
    final page = NotePage(strokes: [stroke]);

    // We wrap in MaterialApp for theme access
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NoteThumbnail(
          page: page,
          paperStyle: NotePaperStyle.plain,
        ),
      ),
    ));

    expect(find.byType(NoteThumbnail), findsOneWidget);
    // Should NOT show empty icon
    expect(find.byIcon(Icons.draw_outlined), findsNothing);
    // Should show at least one CustomPaint (for the strokes)
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('NoteThumbnail handles empty page', (tester) async {
    final page = NotePage(strokes: []);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NoteThumbnail(
          page: page,
          paperStyle: NotePaperStyle.plain,
        ),
      ),
    ));

    expect(find.byType(NoteThumbnail), findsOneWidget);
    // Should show empty icon
    expect(find.byIcon(Icons.draw_outlined), findsOneWidget);
  });
}
