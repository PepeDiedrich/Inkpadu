import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/paper_style_selection_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  Widget createTestWidget(NotePaperStyle initialStyle) {
    return TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await showDialog<NotePaperStyle>(
                  context: context,
                  builder: (context) => PaperStyleSelectionDialog(
                    initialPaperStyle: initialStyle,
                  ),
                );
                // For test verification purposes, we might display the result text
                // or just handle it in the test interactions.
                if (result != null && context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Result: ${result.name}')));
                }
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders all elements correctly', (tester) async {
    await tester.pumpWidget(createTestWidget(NotePaperStyle.plain));
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.byType(PaperStyleSelectionDialog), findsOneWidget);
    expect(find.text('Choose background'), findsOneWidget); // Localized title
    expect(find.text('Plain'), findsOneWidget);
    expect(find.text('Lined'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('Dotted'), findsOneWidget);

    // Check buttons
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
  });

  testWidgets('selecting a style updates the UI selection', (tester) async {
    await tester.pumpWidget(createTestWidget(NotePaperStyle.plain));
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Initial state: Plain selected.
    // We can check the icon color or container decoration, but finding the widget is easier.
    // Let's tap 'Grid'.
    await tester.tap(find.text('Grid'));
    await tester.pumpAndSettle();

    // Tap Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    // Verify result via SnackBar
    expect(find.text('Result: grid'), findsOneWidget);
  });

  testWidgets('cancel returns null (no result)', (tester) async {
    await tester.pumpWidget(createTestWidget(NotePaperStyle.plain));
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grid')); // Select something else
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // No SnackBar should appear
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('starts with initial style selected', (tester) async {
    // Ideally we would inspect the widget state, but functionally:
    // If we open with 'Lined' and click Apply immediately, it should return 'lined'.
    await tester.pumpWidget(createTestWidget(NotePaperStyle.lined));
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Result: lined'), findsOneWidget);
  });
}
