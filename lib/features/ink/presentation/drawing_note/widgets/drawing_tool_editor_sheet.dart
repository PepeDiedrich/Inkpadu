import 'dart:math' as math;

import 'package:ai_handwriting_app/app/theme/app_colors.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Vollbild-Bottom-Sheet zum Anpassen eines Zeichenwerkzeugs.
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
  late final TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialTool;
    _labelController = TextEditingController(text: widget.initialTool.label)
      ..addListener(_handleLabelChanged);
  }

  @override
  void dispose() {
    _labelController
      ..removeListener(_handleLabelChanged)
      ..dispose();
    super.dispose();
  }

  void _handleLabelChanged() {
    final String nextLabel = _labelController.text;
    if (nextLabel == _draft.label) {
      return;
    }
    setState(() {
      _draft = _draft.copyWith(label: nextLabel);
    });
  }

  void _handleApply() {
    final String sanitizedLabel = _labelController.text.trim();
    final String nextLabel = sanitizedLabel.isEmpty
        ? widget.initialTool.label
        : sanitizedLabel;
    Navigator.pop(context, _draft.copyWith(label: nextLabel));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    final bool showColorPicker = !_draft.isEraser;
    final bool showHighlighterToggle = !_draft.isEraser;
    final bool showPressureToggle = !_draft.isEraser;

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

    final String displayName = _draft.label.trim().isEmpty
        ? widget.initialTool.label
        : _draft.label;

    return SafeArea(
      child: SizedBox(
        height: mediaQuery.size.height * 0.92,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: mediaQuery.viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$displayName anpassen', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              TextField(
                controller: _labelController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Werkzeugname',
                  border: OutlineInputBorder(),
                ),
              ),
              if (showColorPicker) ...[
                const SizedBox(height: 16),
                Text('Farbe', style: theme.textTheme.labelLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _defaultToolColors
                      .map((color) {
                        final bool isActive = _draft.color == color;
                        return GestureDetector(
                          onTap: () => setState(
                            () => _draft = _draft.copyWith(color: color),
                          ),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: Border.all(
                                color: isActive
                                    ? AppColors.primaryAccent
                                    : colorScheme.outlineVariant,
                                width: isActive ? 3 : 1,
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
                                    size: 18,
                                  )
                                : null,
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Farbkreis', style: theme.textTheme.labelMedium),
                        const SizedBox(height: 12),
                        ColorPicker(
                          pickerColor: _draft.color,
                          onColorChanged: (color) => setState(
                            () => _draft = _draft.copyWith(color: color),
                          ),
                          enableAlpha: false,
                          paletteType: PaletteType.hueWheel,
                          displayThumbColor: true,
                          portraitOnly: true,
                          pickerAreaBorderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aktuelle Farbe: ${_formatColorHex(_draft.color)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (!_draft.isEraser) ...[
                const SizedBox(height: 24),
                Text('Symbol', style: theme.textTheme.labelLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _toolIconOptions
                      .map((option) {
                        final bool isActive = option.icon == _draft.icon;
                        return Tooltip(
                          message: option.label,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(
                              () => _draft = _draft.copyWith(icon: option.icon),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primaryAccent.withValues(
                                        alpha: 0.12,
                                      )
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.primaryAccent
                                      : colorScheme.outlineVariant,
                                  width: isActive ? 3 : 1,
                                ),
                              ),
                              child: Icon(
                                option.icon,
                                color: isActive
                                    ? AppColors.primaryAccent
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                _draft.isEraser ? 'Radierbreite' : 'Linienstärke',
                style: theme.textTheme.labelLarge,
              ),
              Slider.adaptive(
                value: sliderValue,
                min: minWidth,
                max: maxWidth,
                divisions: math.max(1, ((maxWidth - minWidth) * 2).round()),
                label: '${sliderValue.toStringAsFixed(1)} px',
                onChanged: (value) =>
                    setState(() => _draft = _draft.copyWith(baseWidth: value)),
              ),
              if (showHighlighterToggle) ...[
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Marker-Modus (durchscheinend)'),
                  value: _draft.isHighlighter,
                  onChanged: (value) => setState(() {
                    final double adjustedWidth = value
                        ? math.max(_draft.baseWidth, 6).toDouble()
                        : _draft.baseWidth.clamp(1, 12).toDouble();
                    _draft = _draft.copyWith(
                      isHighlighter: value,
                      baseWidth: adjustedWidth,
                    );
                  }),
                ),
              ],
              if (showPressureToggle) ...[
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Druckerkennung'),
                  subtitle: Text(
                    'Steuert, ob Stiftdruck die Linienstärke beeinflusst.',
                    style: theme.textTheme.bodySmall,
                  ),
                  value: _draft.usePressure,
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(usePressure: value),
                  ),
                ),
              ],
              const SizedBox(height: 12),
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

  String _formatColorHex(Color color) {
    final int argb = color.toARGB32();
    final String rgb = argb.toRadixString(16).padLeft(8, '0').substring(2);
    return '#${rgb.toUpperCase()}';
  }
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

class _ToolIconOption {
  const _ToolIconOption({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const List<_ToolIconOption> _toolIconOptions = <_ToolIconOption>[
  _ToolIconOption(icon: Icons.edit, label: 'Fineliner'),
  _ToolIconOption(icon: Icons.create, label: 'Tintenroller'),
  _ToolIconOption(icon: Icons.draw, label: 'Füller'),
  _ToolIconOption(icon: Icons.brush, label: 'Pinsel'),
  _ToolIconOption(icon: Icons.mode_edit_outline, label: 'Skizzieren'),
  _ToolIconOption(icon: Icons.gesture, label: 'Gesten'),
  _ToolIconOption(icon: Icons.edit_note, label: 'Notizen'),
  _ToolIconOption(icon: Icons.border_color, label: 'Marker'),
  _ToolIconOption(icon: Icons.highlight, label: 'Highlight'),
  _ToolIconOption(icon: Icons.auto_fix_high, label: 'Effekt'),
  _ToolIconOption(icon: Icons.colorize, label: 'Farbverlauf'),
  _ToolIconOption(icon: Icons.flash_on, label: 'Blitz'),
];
