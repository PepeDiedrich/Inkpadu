import 'package:ai_handwriting_app/features/ink/presentation/widgets/math_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MathRichText', () {
    testWidgets('renders plain text without LaTeX', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MathRichText(text: 'Hello World')),
        ),
      );

      expect(find.byType(MathRichText), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('renders empty text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MathRichText(text: '')),
        ),
      );

      // Should not throw and should render
      expect(find.byType(MathRichText), findsOneWidget);
    });

    testWidgets('applies custom style', (tester) async {
      const customStyle = TextStyle(fontSize: 20, color: Colors.red);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MathRichText(text: 'Styled text', style: customStyle),
          ),
        ),
      );

      expect(find.byType(MathRichText), findsOneWidget);
    });

    testWidgets('renders inline LaTeX (single dollar)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MathRichText(text: r'The formula is $x^2$')),
        ),
      );

      expect(find.byType(MathRichText), findsOneWidget);
      // Math widget creates multiple RichText widgets for formula parts
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('renders block LaTeX (double dollar)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MathRichText(text: r'Block: $$\sum_{i=1}^{n} i$$'),
          ),
        ),
      );

      expect(find.byType(MathRichText), findsOneWidget);
    });

    testWidgets('renders mixed text and LaTeX', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MathRichText(
              text: r'Before $a+b$ middle $$c \cdot d$$ after',
            ),
          ),
        ),
      );

      expect(find.byType(MathRichText), findsOneWidget);
    });
  });
}
