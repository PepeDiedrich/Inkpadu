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
  bool _loading = false;
  String? _answer;
  int _boxCount = 0;
  String? _generatedHtml;
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
      case 'red':
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
        'Please analyze this handwriting or drawing and provide a helpful response.';
    final String systemPrompt = editorSettings.aiSystemPrompt.trim();
    final String effectivePrompt = systemPrompt.isEmpty
        ? selectedPrompt
        : 'System instruction:\n$systemPrompt\n\nUser request:\n$selectedPrompt';

    try {
      final capturedResult = await widget.captureRegion();
      if (capturedResult == null) {
        throw Exception('Could not capture canvas region');
      }
      final ui.Image capturedImage = capturedResult.image;
      final Rect selectionBounds = capturedResult.bounds;

      ui.Image imageToEncode = capturedImage;
      const double maxDimension = 1024.0;
      if (capturedImage.width > maxDimension ||
          capturedImage.height > maxDimension) {
        final double scale = capturedImage.width > capturedImage.height
            ? maxDimension / capturedImage.width
            : maxDimension / capturedImage.height;
        final int targetWidth = (capturedImage.width * scale).toInt();
        final int targetHeight = (capturedImage.height * scale).toInt();

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.scale(scale, scale);
        // FilterQuality.medium provides a good balance between quality and performance
        canvas.drawImage(
          capturedImage,
          Offset.zero,
          Paint()..filterQuality = FilterQuality.medium,
        );

        final picture = recorder.endRecording();
        imageToEncode = await picture.toImage(targetWidth, targetHeight);
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
        if (responseBody['boxes'] != null &&
            responseBody['boxes'] is Iterable) {
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

            parsedBoxes.add(
              AiBoundingBox(rect, _parseAiBoxColor(box['color'])),
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
              final htmlContent = htmlMatch.group(1);
              if (htmlContent != null && htmlContent.trim().isNotEmpty) {
                _generatedHtml = htmlContent;
              }
            } else if (_answer!.trim().startsWith('<') &&
                _answer!.trim().endsWith('>')) {
              _generatedHtml = _answer!.trim();
            }
          }
        });
        widget.onAiBoxesExtracted(parsedBoxes);
      } else {
        final errorMsg = execution.responseBody.isNotEmpty
            ? execution.responseBody
            : 'Execution status: ${execution.status.name}';
        throw Exception('AI Function Error: $errorMsg');
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('AI Request failed: $e');
      setState(() {
        _loading = false;
        _answer = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  List<AiPrompt> _defaultAiShortcuts() => <AiPrompt>[
    const AiPrompt(
      id: 'ai-shortcut-1',
      title: 'Graph & Visuell',
      prompt:
          'Bitte analysiere den ausgewählten Bereich und generiere einen JavaScript und HTML basierten Graph, der den Inhalt repräsentiert. Antworte mit dem reinen HTML/JS Code in einem Markdown Block. Nutze keine externen Bibliotheken.',
    ),
    const AiPrompt(
      id: 'ai-shortcut-2',
      title: 'Fehler markieren',
      prompt:
          'Bitte analysiere diese Notizen. Markiere alle Fehler, die du findest, mit roten Bounding Boxes. Erkläre kurz, was falsch ist.',
    ),
    const AiPrompt(
      id: 'ai-shortcut-3',
      title: 'Sokratischer Tutor',
      prompt:
          'Bitte verhalte dich wie ein sokratischer Tutor. Hilf mir, diesen Inhalt zu verstehen, indem du Fragen stellst und Hinweise gibst, anstatt nur die direkte Lösung zu verraten.',
    ),
  ];

  List<AiPrompt> _resolveAiShortcuts(List<AiPrompt> source) {
    final defaults = _defaultAiShortcuts();
    final List<AiPrompt> result = <AiPrompt>[];
    for (var i = 0; i < 3; i++) {
      final fallback = defaults[i];
      final existing = i < source.length ? source[i] : fallback;
      final title = existing.title.trim().isEmpty
          ? fallback.title
          : existing.title;
      final prompt = existing.prompt.trim().isEmpty
          ? fallback.prompt
          : existing.prompt;
      result.add(AiPrompt(id: fallback.id, title: title, prompt: prompt));
    }
    return result;
  }

  void _showEditPromptDialog(AiPrompt currentPrompt, int index) {
    final titleController = TextEditingController(text: currentPrompt.title);
    final promptController = TextEditingController(text: currentPrompt.prompt);

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                final newPrompt = AiPrompt(
                  id: currentPrompt.id,
                  title: titleController.text.trim(),
                  prompt: promptController.text.trim(),
                );

                final editorSettings = EditorSettingsScope.of(context);
                final currentPrompts = _resolveAiShortcuts(
                  editorSettings.aiPrompts,
                );
                currentPrompts[index] = newPrompt;
                editorSettings.update(aiPrompts: currentPrompts);

                Navigator.of(context).pop();
                setState(() {}); // Trigger rebuild to show new title
              },
              child: Text(context.t.common.save),
            ),
          ],
        );
      },
    );
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
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) {},
          onPointerMove: (_) {},
          onPointerUp: (_) {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Card(
                elevation: 4,
                margin: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: (details) =>
                            setState(() => _position += details.delta),
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
                            ],
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < aiShortcuts.length; i++)
                            FilledButton.tonalIcon(
                              onPressed: _loading
                                  ? null
                                  : () => _executeAiRequest(aiShortcuts[i]),
                              onLongPress: () =>
                                  _showEditPromptDialog(aiShortcuts[i], i),
                              icon: const Icon(Icons.flash_on, size: 16),
                              label: Text(aiShortcuts[i].title),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          if (widget.onGenerateGraph != null)
                            FilledButton.tonalIcon(
                              onPressed: _loading
                                  ? null
                                  : () => _executeAiRequest(
                                      null,
                                      "Bitte analysiere den ausgewählten Bereich und generiere einen JavaScript und HTML basierten Graph, der den Inhalt repräsentiert. Antworte mit dem reinen HTML/JS Code in einem Markdown Block. Nutze keine externen Bibliotheken außer ggf. chart.js oder d3.js über ein CDN.",
                                    ),
                              icon: const Icon(Icons.bar_chart),
                              label: const Text(
                                "Graph generieren",
                              ), // text hardcoded for now or use t.common.apply
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!_loading &&
                          _generatedHtml != null &&
                          widget.onGenerateGraph != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              onPressed: () {
                                widget.onGenerateGraph?.call(_generatedHtml!);
                              },
                              icon: const Icon(Icons.add_box),
                              label: const Text('Graph zum Canvas hinzufügen'),
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
                                widget
                                    .onClose(); // Optional: Close panel after keeping
                              },
                              icon: const Icon(Icons.playlist_add_check),
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(context.t.ai.analyzingSelection),
                            ),
                          ],
                        )
                      else if (_answer != null)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: SingleChildScrollView(
                            child: MathRichText(text: _answer!),
                          ),
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
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
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
          ),
        ),
      ),
    );
  }
}
