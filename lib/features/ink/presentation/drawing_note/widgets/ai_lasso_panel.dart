import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:ai_handwriting_app/app/auth/appwrite_config.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_canvas.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/math_rich_text.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// A panel that appears when an AI lasso selection is made, allowing the user
/// to interact with AI-powered features for the selected region.
class AiLassoPanel extends StatefulWidget {
  /// Creates an [AiLassoPanel].
  const AiLassoPanel({
    super.key,
    required this.initialPosition,
    required this.lassoPoints,
    required this.onClose,
    required this.onAiBoxesExtracted,
    required this.captureRegion,
  });

  /// The initial position where the panel should appear on the canvas.
  final Offset initialPosition;

  /// The points defining the lasso selection area.
  final List<Offset> lassoPoints;

  /// Callback to close the panel.
  final VoidCallback onClose;

  /// Callback triggered when AI bounding boxes are extracted from the selection.
  final ValueChanged<List<AiBoundingBox>> onAiBoxesExtracted;

  /// Callback to capture the selected region of the canvas as an image.
  final Future<ui.Image?> Function() captureRegion;

  @override
  State<AiLassoPanel> createState() => _AiLassoPanelState();
}

class _AiLassoPanelState extends State<AiLassoPanel> {
  late Offset _position;
  bool _loading = false;
  String? _answer;
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  // Helper methodologies for AI Box color will go here
  Color _parseAiBoxColor(dynamic rawColor) {
    final String input = rawColor?.toString().trim() ?? '';
    if (input.isEmpty) {
      return Colors.red;
    }

    String normalized = input.toLowerCase();
    normalized = normalized.replaceAll('"', '');

    String hex = normalized.replaceAll('#', '');
    if (hex.startsWith('0x')) {
      hex = hex.substring(2);
    }

    if (hex.length == 3) {
      hex = hex.split('').map((char) => '$char$char').join();
    }

    if (hex.length == 6) {
      final int? rgb = int.tryParse(hex, radix: 16);
      if (rgb != null) {
        final Color color = Color(0xFF000000 | rgb);
        return color.toARGB32() == Colors.white.toARGB32() ? Colors.black : color;
      }
    }

    if (hex.length == 8) {
      final int? argb = int.tryParse(hex, radix: 16);
      if (argb != null) {
        final Color color = Color(argb);
        return color.toARGB32() == Colors.white.toARGB32() ? Colors.black : color;
      }
    }

    switch (normalized) {
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'yellow': return Colors.yellow;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      case 'pink': return Colors.pink;
      case 'cyan': return Colors.cyan;
      case 'magenta': return const Color(0xFFFF00FF);
      case 'black':
      case 'white': return Colors.black;
      case 'red':
      default: return Colors.red;
    }
  }

  Rect _boundsOfOffsets(List<Offset> points) {
    var minX = double.infinity, minY = double.infinity, maxX = -double.infinity, maxY = -double.infinity;
    for (final p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy > maxY) maxY = p.dy;
    }
    if (!minX.isFinite || !minY.isFinite || !maxX.isFinite || !maxY.isFinite) return Rect.zero;
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Future<void> _executeAiRequest(AiPrompt? prompt, [String? customPrompt]) async {
    setState(() {
      _loading = true;
      _answer = null;
    });
    widget.onAiBoxesExtracted([]);

    final editorSettings = EditorSettingsScope.of(context);
    final String selectedPrompt = customPrompt ?? prompt?.prompt ?? 'Please analyze this handwriting or drawing and provide a helpful response.';
    final String systemPrompt = editorSettings.aiSystemPrompt.trim();
    final String effectivePrompt = systemPrompt.isEmpty
        ? selectedPrompt
        : 'System instruction:\n$systemPrompt\n\nUser request:\n$selectedPrompt';

    try {
      final ui.Image? capturedImage = await widget.captureRegion();
      if (capturedImage == null) throw Exception('Could not render canvas to image');
      
      final byteData = await capturedImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Could not encode image data');
      
      final base64Image = base64Encode(byteData.buffer.asUint8List());
      final Rect selectionBounds = _boundsOfOffsets(widget.lassoPoints);

      final functions = appwrite.Functions(AppwriteConfig.client);
      final execution = await functions.createExecution(
        functionId: '699f260b003cfa670c2c',
        body: jsonEncode({'image': base64Image, 'prompt': effectivePrompt}),
      );

      if (!mounted) return;

      if (execution.status.name == 'completed') {
        final responseBody = jsonDecode(execution.responseBody);
        final List<AiBoundingBox> parsedBoxes = [];
        if (responseBody['boxes'] != null && responseBody['boxes'] is Iterable) {
          for (final box in responseBody['boxes'] as Iterable) {
            final ymin = (box['ymin'] as num).toDouble() / 1000.0;
            final xmin = (box['xmin'] as num).toDouble() / 1000.0;
            final ymax = (box['ymax'] as num).toDouble() / 1000.0;
            final xmax = (box['xmax'] as num).toDouble() / 1000.0;
            
            final rect = Rect.fromLTRB(
              selectionBounds.left + xmin * selectionBounds.width,
              selectionBounds.top + ymin * selectionBounds.height,
              selectionBounds.left + xmax * selectionBounds.width,
              selectionBounds.top + ymax * selectionBounds.height,
            );
            
            parsedBoxes.add(AiBoundingBox(rect, _parseAiBoxColor(box['color'])));
          }
        }
        setState(() {
          _loading = false;
          _answer = responseBody['text']?.toString() ?? 'No response';
        });
        widget.onAiBoxesExtracted(parsedBoxes);
      } else {
        throw Exception('Function execution failed: ${execution.responseBody}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _answer = 'Error: $e';
      });
    }
  }

  List<AiPrompt> _defaultAiShortcuts() => <AiPrompt>[
    AiPrompt(id: 'ai-shortcut-1', title: context.t.editor.aiShortcut(index: 1), prompt: context.t.editor.aiShortcutPrompt1),
    AiPrompt(id: 'ai-shortcut-2', title: context.t.editor.aiShortcut(index: 2), prompt: context.t.editor.aiShortcutPrompt2),
    AiPrompt(id: 'ai-shortcut-3', title: context.t.editor.aiShortcut(index: 3), prompt: context.t.editor.aiShortcutPrompt3),
  ];

  List<AiPrompt> _resolveAiShortcuts(List<AiPrompt> source) {
    final defaults = _defaultAiShortcuts();
    final List<AiPrompt> result = <AiPrompt>[];
    for (var i = 0; i < 3; i++) {
      final fallback = defaults[i];
      final existing = i < source.length ? source[i] : fallback;
      final title = existing.title.trim().isEmpty ? fallback.title : existing.title;
      final prompt = existing.prompt.trim().isEmpty ? fallback.prompt : existing.prompt;
      result.add(AiPrompt(id: fallback.id, title: title, prompt: prompt));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final editorSettings = EditorSettingsScope.of(context);
    final aiShortcuts = _resolveAiShortcuts(editorSettings.aiPrompts);

    return Positioned(
      top: _position.dy,
      left: _position.dx,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onPanUpdate: (details) => setState(() => _position += details.delta),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_indicator, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(context.t.ai.helpMeTitle, style: Theme.of(context).textTheme.titleMedium),
                      ),
                      IconButton(
                        tooltip: context.t.common.close,
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final prompt in aiShortcuts)
                      FilledButton.tonalIcon(
                        onPressed: _loading ? null : () => _executeAiRequest(prompt),
                        icon: const Icon(Icons.flash_on),
                        label: Text(prompt.title),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_loading)
                  Row(
                    children: [
                      const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(context.t.ai.analyzingSelection)),
                    ],
                  )
                else if (_answer != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: SingleChildScrollView(child: MathRichText(text: _answer!)),
                  ),
                if (!_loading) ...[
                  if (_answer != null) const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: InputDecoration(
                            hintText: context.t.ai.askFollowUp,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _executeAiRequest(null, value.trim());
                              _chatController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          final text = _chatController.text.trim();
                          if (text.isNotEmpty) {
                            _executeAiRequest(null, text);
                            _chatController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
