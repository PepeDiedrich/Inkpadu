import 'dart:math' as math;

import 'package:ai_handwriting_app/app/theme/app_colors.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Kompakter Bottom-Sheet-Editor zum Anpassen eines Zeichenwerkzeugs.
class DrawingToolEditorSheet extends StatefulWidget {
  /// Erstellt das Sheet für das angegebene Werkzeug.
  const DrawingToolEditorSheet({super.key, required this.initialTool});

  /// Werkzeugzustand, der beim Öffnen angezeigt wird.
  final DrawingTool initialTool;

  /// Öffnet den Editor als Bottom-Sheet und liefert das Ergebnis zurück.
  static Future<DrawingTool?> show(
    BuildContext context, {
    required DrawingTool tool,
  }) => showModalBottomSheet<DrawingTool>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) => DrawingToolEditorSheet(initialTool: tool),
  );

  @override
  State<DrawingToolEditorSheet> createState() => _DrawingToolEditorSheetState();
}

class _DrawingToolEditorSheetState extends State<DrawingToolEditorSheet> {
  late DrawingTool _draft;
  bool _showCustomColor = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialTool;
  }

  void _handleApply() {
    Navigator.pop(context, _draft);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    final bool showColorPicker = !_draft.isEraser;

    final double minWidth = _draft.isEraser
        ? 8
        : _draft.isHighlighter
        ? 6
        : 1;
    final double maxWidth = _draft.isEraser
        ? 32
        : _draft.isHighlighter
        ? 24
        : 12;
    final double sliderValue = _draft.baseWidth.clamp(minWidth, maxWidth);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: mediaQuery.viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Color selection
              if (showColorPicker) ...[
                Text('Farbe', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                // Preset colors in a compact row
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _defaultToolColors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final color = _defaultToolColors[index];
                      final bool isActive = _draft.color == color;
                      return GestureDetector(
                        onTap: () => setState(
                          () => _draft = _draft.copyWith(color: color),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primaryAccent
                                  : colorScheme.outlineVariant,
                              width: isActive ? 2.5 : 1,
                            ),
                          ),
                          child: isActive
                              ? Icon(
                                  Icons.check,
                                  color:
                                      ThemeData.estimateBrightnessForColor(
                                            color,
                                          ) ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  size: 14,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Expandable custom color picker
                _CustomColorSection(
                  color: _draft.color,
                  isExpanded: _showCustomColor,
                  onToggle: () =>
                      setState(() => _showCustomColor = !_showCustomColor),
                  onColorChanged: (color) =>
                      setState(() => _draft = _draft.copyWith(color: color)),
                ),

                const SizedBox(height: 12),
              ],

              // Stroke width slider
              Row(
                children: [
                  Text(
                    _draft.isEraser ? 'Radierbreite' : 'Linienstärke',
                    style: theme.textTheme.labelLarge,
                  ),
                  const Spacer(),
                  Text(
                    '${sliderValue.toStringAsFixed(1)} px',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                  ),
                ),
                child: Slider.adaptive(
                  value: sliderValue,
                  min: minWidth,
                  max: maxWidth,
                  divisions: math.max(1, ((maxWidth - minWidth) * 2).round()),
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(baseWidth: value),
                  ),
                ),
              ),

              // Stroke preview
              if (!_draft.isEraser) ...[
                const SizedBox(height: 4),
                Center(
                  child: CustomPaint(
                    size: const Size(200, 24),
                    painter: _StrokePreviewPainter(
                      color: _draft.color,
                      strokeWidth: sliderValue,
                      isMarker: _draft.isHighlighter,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Abbrechen'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _handleApply,
                    child: const Text('Übernehmen'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomColorSection extends StatelessWidget {
  const _CustomColorSection({
    required this.color,
    required this.isExpanded,
    required this.onToggle,
    required this.onColorChanged,
  });

  final Color color;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Eigene Farbe',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatColorHex(color),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Guard against zero-width during animation transitions.
                if (constraints.maxWidth < 50) {
                  return const SizedBox(height: 280);
                }
                return SizedBox(
                  height: 440,
                  child: ColorPicker(
                    pickerColor: color,
                    onColorChanged: onColorChanged,
                    enableAlpha: false,
                    paletteType: PaletteType.hueWheel,
                    displayThumbColor: true,
                    portraitOnly: true,
                    pickerAreaBorderRadius: const BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }

  static String _formatColorHex(Color color) {
    final int argb = color.toARGB32();
    final String rgb = argb.toRadixString(16).padLeft(8, '0').substring(2);
    return '#${rgb.toUpperCase()}';
  }
}

class _StrokePreviewPainter extends CustomPainter {
  _StrokePreviewPainter({
    required this.color,
    required this.strokeWidth,
    required this.isMarker,
  });

  final Color color;
  final double strokeWidth;
  final bool isMarker;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isMarker ? color.withValues(alpha: 0.45) : color
      ..strokeCap = isMarker ? StrokeCap.square : StrokeCap.round
      ..strokeJoin = isMarker ? StrokeJoin.bevel : StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.1,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.9,
        size.width,
        size.height * 0.4,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokePreviewPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.isMarker != isMarker;
}

const List<Color> _defaultToolColors = [
  Colors.black,
  Color(0xFF424242),
  Color(0xFF1E88E5),
  Color(0xFF00897B),
  Color(0xFF7CB342),
  Color(0xFFFDD835),
  Color(0xFFFFA726),
  Color(0xFFE53935),
  Color(0xFF8E24AA),
  Color(0xFF6D4C41),
  Color(0xFF607D8B),
  Colors.white,
];
