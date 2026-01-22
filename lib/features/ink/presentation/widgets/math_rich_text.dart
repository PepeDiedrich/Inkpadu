import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Renders text with inline LaTeX segments using flutter_math_fork.
class MathRichText extends StatefulWidget {
  /// Creates a rich text widget that renders inline and block LaTeX ($...$, $$...$$)
  /// and bold terms (**...**).
  const MathRichText({
    super.key,
    required this.text,
    this.style,
    this.onMathTap,
    this.onTermTap,
  });

  /// Full text that may contain LaTeX segments.
  final String text;

  /// Optional base style applied to both text and math.
  final TextStyle? style;

  /// Callback when a math formula is tapped.
  final void Function(String mathContent)? onMathTap;

  /// Callback when a bold term is tapped.
  final void Function(String term)? onTermTap;

  @override
  State<MathRichText> createState() => _MathRichTextState();
}

class _MathRichTextState extends State<MathRichText> {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final TapGestureRecognizer recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dispose old recognizers before creating new ones for the new build
    for (final TapGestureRecognizer recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    final TextStyle baseStyle =
        widget.style ??
        Theme.of(context).textTheme.bodyMedium ??
        const TextStyle(fontSize: 14);

    final _MathSpanBuilder builder = _MathSpanBuilder(
      baseStyle: baseStyle,
      context: context,
      onMathTap: widget.onMathTap,
      onTermTap: widget.onTermTap,
      registerRecognizer: _recognizers.add,
    );
    final List<InlineSpan> spans = builder.build(widget.text);

    return SelectionArea(
      child: RichText(
        text: TextSpan(style: baseStyle, children: spans),
      ),
    );
  }
}

class _MathSpanBuilder {
  const _MathSpanBuilder({
    required this.baseStyle,
    required this.context,
    required this.registerRecognizer,
    this.onMathTap,
    this.onTermTap,
  });

  final TextStyle baseStyle;
  final BuildContext context;
  final void Function(TapGestureRecognizer) registerRecognizer;
  final void Function(String)? onMathTap;
  final void Function(String)? onTermTap;

  List<InlineSpan> build(String input) {
    if (input.isEmpty) {
      return <InlineSpan>[const TextSpan(text: '')];
    }

    final List<InlineSpan> spans = <InlineSpan>[];
    // Matches $$...$$, $...$, or **...**
    final RegExp pattern = RegExp(
      r'(\$\$.*?\$\$|\$[^$]+\$|\*\*.*?\*\*)',
      dotAll: true,
    );
    int cursor = 0;

    for (final RegExpMatch match in pattern.allMatches(input)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: input.substring(cursor, match.start)));
      }

      final String matchText = match.group(0)!;

      if (matchText.startsWith(r'$')) {
        // Math segment
        final bool isBlock = matchText.startsWith(r'$$');
        final String mathContent = matchText
            .substring(isBlock ? 2 : 1, matchText.length - (isBlock ? 2 : 1))
            .trim();

        if (mathContent.isNotEmpty) {
          Widget mathWidget = Math.tex(
            mathContent,
            textStyle: baseStyle,
            options: MathOptions(
              style: isBlock ? MathStyle.display : MathStyle.text,
            ),
          );

          // Make math clickable if callback is provided
          if (onMathTap != null) {
            mathWidget = MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onMathTap!(mathContent),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: mathWidget,
                ),
              ),
            );
          }

          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isBlock ? 8 : 0),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool hasBoundedWidth =
                        constraints.hasBoundedWidth &&
                        constraints.maxWidth.isFinite;

                    if (hasBoundedWidth) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: mathWidget,
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: mathWidget,
                    );
                  },
                ),
              ),
            ),
          );
        }
      } else if (matchText.startsWith('**')) {
        // Bold term segment
        final String termContent = matchText.substring(2, matchText.length - 2);
        if (termContent.isNotEmpty) {
          final TapGestureRecognizer? recognizer = onTermTap != null
              ? (TapGestureRecognizer()..onTap = () => onTermTap!(termContent))
              : null;

          if (recognizer != null) {
            registerRecognizer(recognizer);
          }

          final Color primaryColor = Theme.of(context).colorScheme.primary;

          spans.add(
            TextSpan(
              text: termContent,
              style: baseStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: onTermTap != null ? primaryColor : null,
                decoration: onTermTap != null ? TextDecoration.underline : null,
                decorationColor: onTermTap != null
                    ? primaryColor.withValues(alpha: 0.5)
                    : null,
                decorationStyle: onTermTap != null
                    ? TextDecorationStyle.dashed
                    : null,
              ),
              recognizer: recognizer,
            ),
          );
        }
      }

      cursor = match.end;
    }

    if (cursor < input.length) {
      spans.add(TextSpan(text: input.substring(cursor)));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: input));
    }

    return spans;
  }
}
