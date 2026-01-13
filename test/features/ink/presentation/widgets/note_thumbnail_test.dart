import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/note_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NoteThumbnail renders strokes correctly', (tester) async {
    final stroke = Stroke(
      points: [
        DrawingPoint(position: const Offset(0, 0), pressure: 0.5),
        DrawingPoint(position: const Offset(100, 100), pressure: 0.5),
      ],
    );
    final page = NotePage(strokes: [stroke]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteThumbnail(
            page: page,
            paperStyle: NotePaperStyle.lined,
            size: 100,
          ),
        ),
      ),
    );

    expect(find.byType(NoteThumbnail), findsOneWidget);
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });

  testWidgets('NoteThumbnail handles empty page', (tester) async {
    final page = NotePage(strokes: []);

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
    expect(find.byIcon(Icons.draw_outlined), findsOneWidget);
  });
}
