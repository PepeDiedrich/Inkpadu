import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotePaperBackground', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotePaperBackground(
              paperStyle: NotePaperStyle.plain,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('renders with plain style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotePaperBackground(
              paperStyle: NotePaperStyle.plain,
              child: SizedBox.expand(),
            ),
          ),
        ),
      );

      expect(find.byType(NotePaperBackground), findsOneWidget);
      // CustomPaint is used for the paper background pattern
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with lined style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotePaperBackground(
              paperStyle: NotePaperStyle.lined,
              child: SizedBox.expand(),
            ),
          ),
        ),
      );

      expect(find.byType(NotePaperBackground), findsOneWidget);
    });

    testWidgets('renders with grid style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotePaperBackground(
              paperStyle: NotePaperStyle.grid,
              child: SizedBox.expand(),
            ),
          ),
        ),
      );

      expect(find.byType(NotePaperBackground), findsOneWidget);
    });

    testWidgets('renders with dotted style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotePaperBackground(
              paperStyle: NotePaperStyle.dotted,
              child: SizedBox.expand(),
            ),
          ),
        ),
      );

      expect(find.byType(NotePaperBackground), findsOneWidget);
    });

  });
}
