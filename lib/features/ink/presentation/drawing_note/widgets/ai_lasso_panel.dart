import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_canvas.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/ai_lasso_panel/services/ai_lasso_service.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/ai_lasso_panel/components/ai_lasso_panel_header.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/ai_lasso_panel/components/ai_lasso_content_view.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/ai_lasso_panel/components/ai_lasso_input_area.dart';

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

    try {
      final response = await AiLassoService.executeAiRequest(
        captureRegion: widget.captureRegion,
        prompt: selectedPrompt,
        systemPrompt: systemPrompt,
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _answer = response.text;
        _boxCount = response.boxes.length;
        _generatedHtml = response.generatedHtml;
      });
      widget.onAiBoxesExtracted(response.boxes);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _answer = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    AiLassoPanelHeader(
                      onClose: widget.onClose,
                      onPositionUpdate: (delta) =>
                          setState(() => _position += delta),
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
                            child: AiLassoContentView(
                              isLoading: _loading,
                              answer: _answer,
                              generatedHtml: _generatedHtml,
                              boxCount: _boxCount,
                              onExecuteShortcut: (prompt) =>
                                  _executeAiRequest(prompt),
                              onExecuteGraph: widget.onGenerateGraph != null
                                  ? () => _executeAiRequest(
                                      null,
                                      "Generiere einen Graph.",
                                    )
                                  : null,
                              onGenerateGraph: widget.onGenerateGraph,
                              onKeepHighlights: widget.onKeepHighlights,
                              onStateUpdate: () => setState(() {}),
                              onClose: widget.onClose,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Input Footer
                    AiLassoInputArea(
                      controller: _chatController,
                      isLoading: _loading,
                      onSubmit: (text) => _executeAiRequest(null, text),
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
