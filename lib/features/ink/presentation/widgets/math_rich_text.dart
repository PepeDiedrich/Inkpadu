import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Renders text with inline LaTeX segments using flutter_math_fork.
class MathRichText extends StatelessWidget {
  /// Creates a rich text widget that renders inline and block LaTeX ($...$, $$...$$).
  const MathRichText({super.key, required this.text, this.style});

  /// Full text that may contain LaTeX segments.
  final String text;

  /// Optional base style applied to both text and math.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = style ??
        Theme.of(context).textTheme.bodyMedium ??
        const TextStyle(fontSize: 14);
    final _MathSpanBuilder builder = _MathSpanBuilder(baseStyle);
    final List<InlineSpan> spans = builder.build(text);

    return SelectionArea(
      child: RichText(
        text: TextSpan(
          style: baseStyle,
          children: spans,
        ),
      ),
    );
  }
}

class _MathSpanBuilder {
  const _MathSpanBuilder(this.baseStyle);

  final TextStyle baseStyle;

  List<InlineSpan> build(String input) {
    if (input.isEmpty) {
      return <InlineSpan>[const TextSpan(text: '')];
    }

    final List<InlineSpan> spans = <InlineSpan>[];
    final RegExp pattern = RegExp(r'(\$\$.*?\$\$|\$[^$]+\$)', dotAll: true);
    int cursor = 0;

    for (final RegExpMatch match in pattern.allMatches(input)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: input.substring(cursor, match.start)));
      }

      final String matchText = match.group(0)!;
      final bool isBlock = matchText.startsWith(r'$$');
      final String mathContent = matchText.substring(
        isBlock ? 2 : 1,
        matchText.length - (isBlock ? 2 : 1),
      ).trim();

      if (mathContent.isNotEmpty) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isBlock ? 8 : 0),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final Widget mathWidget = Math.tex(
                    mathContent,
                    textStyle: baseStyle,
                    options: MathOptions(
                      style: isBlock ? MathStyle.display : MathStyle.text,
                    ),
                  );

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
