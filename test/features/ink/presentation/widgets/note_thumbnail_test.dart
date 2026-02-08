import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/note_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NoteThumbnail renders correctly with strokes', (tester) async {
    // Arrange
    final stroke = Stroke(
      points: [
        DrawingPoint(
          position: const Offset(10, 10),
        ),
        DrawingPoint(
          position: const Offset(100, 100),
        ),
      ],
      color: Colors.blue,
    );
    final page = NotePage(strokes: [stroke]);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: NoteThumbnail(
            page: page,
            paperStyle: NotePaperStyle.plain,
            size: 100.0,
          ),
        ),
      ),
    );

    // Assert
    expect(find.byType(NoteThumbnail), findsOneWidget);
    expect(find.byType(CustomPaint), findsOneWidget);
    expect(find.byType(ClipRRect), findsOneWidget); // Thumbnail clips content
  });

  testWidgets('NoteThumbnail renders empty state correctly', (tester) async {
    // Arrange
    final page = NotePage(strokes: []);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteThumbnail(
            page: page,
            paperStyle: NotePaperStyle.plain,
            size: 100.0,
          ),
        ),
      ),
    );

    // Assert
    expect(find.byType(NoteThumbnail), findsOneWidget);
    expect(find.byIcon(Icons.draw_outlined), findsOneWidget);
  });
}
