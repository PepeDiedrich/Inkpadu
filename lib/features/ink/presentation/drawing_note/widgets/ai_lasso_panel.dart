import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
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
    this.onKeepHighlights,
    this.onGenerateGraph,
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
  final Future<({ui.Image image, Rect bounds})?> Function() captureRegion;

  /// Optional callback triggered when the user wants to permanently keep the extracted AI highlights.
  final VoidCallback? onKeepHighlights;

  /// Optional callback when the AI generated an HTML block to insert as a graph.
  final ValueChanged<String>? onGenerateGraph;

  @override
  State<AiLassoPanel> createState() => _AiLassoPanelState();
}

class _AiLassoPanelState extends State<AiLassoPanel> {
  late Offset _position;
  double _width = 420;
  double _height = 450;
  bool _loading = false;
  String? _answer;
  int _boxCount = 0;
  String? _generatedHtml;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _parseAiBoxColor(dynamic rawColor) {
    final String input = rawColor?.toString().trim() ?? '';
    if (input.isEmpty) return Colors.red;

    final String normalized = input.toLowerCase().replaceAll('"', '');
    String hex = normalized.replaceAll('#', '');
    if (hex.startsWith('0x')) hex = hex.substring(2);

    if (hex.length == 3) hex = hex.split('').map((char) => '$char$char').join();

    if (hex.length == 6) {
      final int? rgb = int.tryParse(hex, radix: 16);
      if (rgb != null) {
        final Color color = Color(0xFF000000 | rgb);
        return color.toARGB32() == Colors.white.toARGB32()
            ? Colors.black
            : color;
      }
    }

    if (hex.length == 8) {
      final int? argb = int.tryParse(hex, radix: 16);
      if (argb != null) {
        final Color color = Color(argb);
        return color.toARGB32() == Colors.white.toARGB32()
            ? Colors.black
            : color;
      }
    }

    switch (normalized) {
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'cyan':
        return Colors.cyan;
      case 'magenta':
        return const Color(0xFFFF00FF);
      case 'black':
      case 'white':
        return Colors.black;
      default:
        return Colors.red;
    }
  }

  Future<void> _executeAiRequest(
    AiPrompt? prompt, [
    String? customPrompt,
  ]) async {
    setState(() {
      _loading = true;
      _answer = null;
    });
    widget.onAiBoxesExtracted([]);

    final editorSettings = EditorSettingsScope.of(context);
    final String selectedPrompt =
        customPrompt ??
        prompt?.prompt ??
        'Please analyze this handwriting or drawing.';
    final String systemPrompt = editorSettings.aiSystemPrompt.trim();
    final String effectivePrompt = systemPrompt.isEmpty
        ? selectedPrompt
        : 'System instruction:\n$systemPrompt\n\nUser request:\n$selectedPrompt';

    try {
      final capturedResult = await widget.captureRegion();
      if (capturedResult == null) {
        throw Exception('Could not capture canvas region');
      }

      ui.Image imageToEncode = capturedResult.image;
      const double maxDimension = 1024.0;
      if (imageToEncode.width > maxDimension ||
          imageToEncode.height > maxDimension) {
        final double scale = imageToEncode.width > imageToEncode.height
            ? maxDimension / imageToEncode.width
            : maxDimension / imageToEncode.height;
        final int targetWidth = (imageToEncode.width * scale).toInt();
        final int targetHeight = (imageToEncode.height * scale).toInt();
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.scale(scale, scale);
        canvas.drawImage(
          imageToEncode,
          Offset.zero,
          Paint()..filterQuality = FilterQuality.medium,
        );
        imageToEncode = await recorder.endRecording().toImage(
          targetWidth,
          targetHeight,
        );
      }

      final byteData = await imageToEncode.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) throw Exception('Could not encode image data');

      final base64Image = base64Encode(byteData.buffer.asUint8List());
      final functions = appwrite.Functions(AppwriteConfig.client);
      final execution = await functions.createExecution(
        functionId: '699f260b003cfa670c2c',
        body: jsonEncode({'image': base64Image, 'prompt': effectivePrompt}),
      );

      if (!mounted) return;

      if (execution.status.name == 'completed') {
        final responseBody = jsonDecode(execution.responseBody);
        final List<AiBoundingBox> parsedBoxes = [];
        final selectionBounds = capturedResult.bounds;
        if (responseBody['boxes'] != null &&
            responseBody['boxes'] is Iterable) {
          for (final box in responseBody['boxes'] as Iterable) {
            final ymin = (box['ymin'] as num).toDouble() / 1000.0;
            final xmin = (box['xmin'] as num).toDouble() / 1000.0;
            final ymax = (box['ymax'] as num).toDouble() / 1000.0;
            final xmax = (box['xmax'] as num).toDouble() / 1000.0;
            parsedBoxes.add(
              AiBoundingBox(
                Rect.fromLTRB(
                  selectionBounds.left + xmin * selectionBounds.width,
                  selectionBounds.top + ymin * selectionBounds.height,
                  selectionBounds.left + xmax * selectionBounds.width,
                  selectionBounds.top + ymax * selectionBounds.height,
                ),
                _parseAiBoxColor(box['color']),
              ),
            );
          }
        }
        setState(() {
          _loading = false;
          _answer = responseBody['text']?.toString() ?? 'No response';
          _boxCount = parsedBoxes.length;
          _generatedHtml = null;
          if (_answer != null) {
            final htmlMatch = RegExp(
              r'```(?:html|javascript|js)?\n(.*?)```',
              dotAll: true,
            ).firstMatch(_answer!);
            if (htmlMatch != null) {
              _generatedHtml = htmlMatch.group(1);
            } else if (_answer!.trim().startsWith('<') &&
                _answer!.trim().endsWith('>')) {
              _generatedHtml = _answer!.trim();
            }
          }
        });
        widget.onAiBoxesExtracted(parsedBoxes);
      } else {
        throw Exception('AI Function Error: ${execution.responseBody}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _answer = 'Error: $e';
      });
    }
  }

  List<AiPrompt> _defaultAiShortcuts() => [
    const AiPrompt(
      id: 'ai-shortcut-1',
      title: 'Graph & Visuell',
      prompt:
          'Bitte analysiere den ausgewählten Bereich und generiere einen JavaScript und HTML basierten Graph. Antworte mit reinem HTML/JS.',
    ),
    const AiPrompt(
      id: 'ai-shortcut-2',
      title: 'Fehler markieren',
      prompt:
          'Bitte analysiere diese Notizen. Markiere Fehler mit roten Bounding Boxes.',
    ),
    const AiPrompt(
      id: 'ai-shortcut-3',
      title: 'Sokratischer Tutor',
      prompt: 'Hilf mir, diesen Inhalt sokratisch zu verstehen.',
    ),
  ];

  List<AiPrompt> _resolveAiShortcuts(List<AiPrompt> source) {
    final defaults = _defaultAiShortcuts();
    final List<AiPrompt> result = [];
    for (var i = 0; i < 3; i++) {
      final fallback = defaults[i];
      final existing = i < source.length ? source[i] : fallback;
      result.add(
        AiPrompt(
          id: fallback.id,
          title: existing.title.isEmpty ? fallback.title : existing.title,
          prompt: existing.prompt.isEmpty ? fallback.prompt : existing.prompt,
        ),
      );
    }
    return result;
  }

  void _showEditPromptDialog(AiPrompt currentPrompt, int index) {
    final titleController = TextEditingController(text: currentPrompt.title);
    final promptController = TextEditingController(text: currentPrompt.prompt);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Shortcut ${index + 1} bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Titel'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: promptController,
              decoration: const InputDecoration(labelText: 'Prompt'),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t.common.cancel),
          ),
          FilledButton(
            onPressed: () {
              final editorSettings = EditorSettingsScope.of(context);
              final currentPrompts = _resolveAiShortcuts(
                editorSettings.aiPrompts,
              );
              currentPrompts[index] = AiPrompt(
                id: currentPrompt.id,
                title: titleController.text.trim(),
                prompt: promptController.text.trim(),
              );
              editorSettings.update(aiPrompts: currentPrompts);
              Navigator.of(context).pop();
              setState(() {});
            },
            child: Text(context.t.common.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editorSettings = EditorSettingsScope.of(context);
    final aiShortcuts = _resolveAiShortcuts(editorSettings.aiPrompts);
    final screenSize = MediaQuery.sizeOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);

    // Dynamic max height based on keyboard
    final availableHeight = screenSize.height - viewInsets.bottom - 48;
    final maxPanelHeight = (_height).clamp(200.0, availableHeight);

    // Clamp position to stay within screen bounds (do NOT mutate _position
    // during build – that was resetting vertical drags).
    final clampedDy = _position.dy.clamp(
      16.0,
      (availableHeight - maxPanelHeight).clamp(16.0, availableHeight),
    );
    final clampedDx = _position.dx.clamp(
      0.0,
      (screenSize.width - 300).clamp(0.0, screenSize.width),
    );

    return Positioned(
      top: clampedDy,
      left: clampedDx,
      child: SizedBox(
        width: _width.clamp(300.0, screenSize.width - 32),
        height: maxPanelHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header (Drag handle)
                    RawGestureDetector(
                      gestures: <Type, GestureRecognizerFactory>{
                        _EagerPanGestureRecognizer:
                            GestureRecognizerFactoryWithHandlers<
                              _EagerPanGestureRecognizer
                            >(
                              _EagerPanGestureRecognizer.new,
                              (instance) => instance.onUpdate = (details) =>
                                  setState(() => _position += details.delta),
                            ),
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.t.ai.helpMeTitle,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Icon(
                              Icons.drag_indicator,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: widget.onClose,
                              child: Icon(
                                Icons.close,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Scrollable content
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.stylus,
                            PointerDeviceKind.unknown,
                          },
                        ),
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (var i = 0; i < aiShortcuts.length; i++)
                                      FilledButton.tonalIcon(
                                        onPressed: _loading
                                            ? null
                                            : () => _executeAiRequest(
                                                aiShortcuts[i],
                                              ),
                                        onLongPress: () =>
                                            _showEditPromptDialog(
                                              aiShortcuts[i],
                                              i,
                                            ),
                                        icon: const Icon(
                                          Icons.flash_on,
                                          size: 16,
                                        ),
                                        label: Text(aiShortcuts[i].title),
                                      ),
                                    if (widget.onGenerateGraph != null)
                                      FilledButton.tonalIcon(
                                        onPressed: _loading
                                            ? null
                                            : () => _executeAiRequest(
                                                null,
                                                "Generiere einen Graph.",
                                              ),
                                        icon: const Icon(Icons.bar_chart),
                                        label: const Text("Graph"),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // "Add graph to canvas" button
                                if (!_loading &&
                                    _generatedHtml != null &&
                                    widget.onGenerateGraph != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FilledButton.icon(
                                        onPressed: () {
                                          widget.onGenerateGraph?.call(
                                            _generatedHtml!,
                                          );
                                        },
                                        icon: const Icon(Icons.add_box),
                                        label: const Text(
                                          'Graph zum Canvas hinzufügen',
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.tertiaryContainer,
                                          foregroundColor: Theme.of(
                                            context,
                                          ).colorScheme.onTertiaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),

                                // "Keep highlights" button
                                if (!_loading &&
                                    _answer != null &&
                                    widget.onKeepHighlights != null &&
                                    _boxCount > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FilledButton.icon(
                                        onPressed: () {
                                          widget.onKeepHighlights?.call();
                                          widget.onClose();
                                        },
                                        icon: const Icon(
                                          Icons.playlist_add_check,
                                        ),
                                        label: Text(context.t.common.apply),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.secondaryContainer,
                                          foregroundColor: Theme.of(
                                            context,
                                          ).colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),

                                if (_loading)
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(context.t.ai.analyzingSelection),
                                    ],
                                  )
                                else if (_answer != null)
                                  MathRichText(text: _answer!),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Input Footer
                    if (!_loading)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: InputDecoration(
                                hintText: context.t.ai.askFollowUp,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onSubmitted: (val) {
                                if (val.trim().isNotEmpty) {
                                  _executeAiRequest(null, val.trim());
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
                ),
              ),

              // Resize Handle
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _width = (_width + details.delta.dx).clamp(300.0, 800.0);
                      _height = (_height + details.delta.dy).clamp(
                        200.0,
                        availableHeight,
                      );
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeDownRight,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.south_east,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EagerPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
