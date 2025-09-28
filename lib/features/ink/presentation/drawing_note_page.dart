import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_note_controller.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_tool_preferences_repository.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/assistant_panel.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_canvas.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_tool_editor_sheet.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_tool_palette.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/pointer_settings_sheet.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/sidebar_resize_handle.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/note_metadata_dialog.dart';
import 'package:flutter/material.dart';

/// Seite zum Bearbeiten / Zeichnen einer einzelnen handschriftlichen Notiz.
class DrawingNotePage extends StatefulWidget {
  /// Erstellt eine Seite für die Notiz mit der gegebenen [noteId].
  const DrawingNotePage({super.key, required this.noteId});

  /// ID der zu bearbeitenden Notiz.
  final String noteId;

  @override
  State<DrawingNotePage> createState() => _DrawingNotePageState();
}

class _DrawingNotePageState extends State<DrawingNotePage> {
  static const double _minSidebarFraction = 0.0;
  static const double _minVisibleSidebarFraction = 0.15;
  static const double _maxSidebarFraction = 0.45;
  static const double _dragHandleWidth = 12;
  static const Duration _panelAnimationDuration = Duration(milliseconds: 220);
  static const Curve _panelAnimationCurve = Curves.easeOutCubic;

  final DrawingToolPreferencesRepository _toolPreferencesRepository =
      const DrawingToolPreferencesRepository();

  DrawingNoteController? _controller;
  bool _controllerInitialized = false;

  double _sidebarFraction = 0.3;
  double? _previewSidebarFraction;
  bool _isResizing = false;
  SidebarResizeTrend _resizeTrend = SidebarResizeTrend.none;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllerInitialized) {
      return;
    }
    final InkNotesController notesController = InkNotesScope.of(context);
    _controller = DrawingNoteController(
      noteId: widget.noteId,
      inkNotesController: notesController,
      toolPreferencesRepository: _toolPreferencesRepository,
    );
    _controllerInitialized = true;
    _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  DrawingNoteController? get _maybeController => _controller;

  void _handleUndo() {
    final controller = _maybeController;
    if (controller == null) return;
    if (controller.drawingController.undo()) {
      controller.persistDrawing();
    }
  }

  void _handleRedo() {
    final controller = _maybeController;
    if (controller == null) return;
    if (controller.drawingController.redo()) {
      controller.persistDrawing();
    }
  }

  void _handleClear() {
    final controller = _maybeController;
    if (controller == null) return;
    if (controller.drawingController.clear()) {
      controller.persistDrawing();
    }
  }

  Future<void> _editMetadata() async {
    final controller = _maybeController;
    if (controller == null) return;
    final note = controller.note;
    final result = await showNoteMetadataDialog(
      context,
      initialTitle: note.title,
      initialPaperStyle: note.paperStyle,
      isEditing: true,
    );
    if (result == null) {
      return;
    }

    controller.updateMetadata(
      title: result.title,
      paperStyle: result.paperStyle,
    );
  }

  Future<void> _openToolConfigurator(DrawingTool tool) async {
    final controller = _maybeController;
    if (controller == null) return;
    final updated = await DrawingToolEditorSheet.show(context, tool: tool);
    if (!mounted || updated == null) {
      return;
    }
    await controller.updateTool(updated);
  }

  Future<void> _openPointerSettings() => PointerSettingsSheet.show(context);

  double _snapSidebarFraction(
    double previousFraction,
    double proposedFraction,
  ) {
    final double clamped = proposedFraction
        .clamp(_minSidebarFraction, _maxSidebarFraction)
        .toDouble();
    if (clamped < _minVisibleSidebarFraction) {
      if (clamped < previousFraction) {
        return _minSidebarFraction;
      }
      if (clamped > previousFraction) {
        return _minVisibleSidebarFraction;
      }
    }
    return clamped;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _maybeController;
    if (controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final EditorSettings editorSettings = EditorSettingsScope.of(context);
        final bool panelOnRight = editorSettings.isPanelOnRight;
        final double sidebarFraction = _sidebarFraction
            .clamp(_minSidebarFraction, _maxSidebarFraction)
            .toDouble();
        final double previewFraction =
            (_previewSidebarFraction ?? sidebarFraction)
                .clamp(_minSidebarFraction, _maxSidebarFraction)
                .toDouble();

        final DrawingController drawingController =
            controller.drawingController;
        final DrawingTool currentTool = controller.currentTool;

        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            centerTitle: true,
            toolbarHeight: 94,
            titleSpacing: 0,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.note.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 40),
                  child: DrawingToolPalette(
                    tools: controller.tools,
                    selectedToolId: controller.selectedToolId,
                    onToolSelected: controller.selectTool,
                    onToolLongPress: _openToolConfigurator,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _editMetadata,
                tooltip: 'Titel & Papier anpassen',
                icon: const Icon(Icons.edit_note),
              ),
              IconButton(
                onPressed: _openPointerSettings,
                tooltip: 'Eingabeoptionen',
                icon: const Icon(Icons.tune),
              ),
              AnimatedBuilder(
                animation: drawingController,
                builder: (context, child) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: drawingController.canUndo ? _handleUndo : null,
                      icon: const Icon(Icons.undo),
                      tooltip: 'Undo',
                    ),
                    IconButton(
                      onPressed: drawingController.canRedo ? _handleRedo : null,
                      icon: const Icon(Icons.redo),
                      tooltip: 'Redo',
                    ),
                    IconButton(
                      onPressed: drawingController.canUndo
                          ? _handleClear
                          : null,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Zeichenfläche leeren',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              final double baseWidth = maxWidth <= 0 ? 1 : maxWidth;
              final double panelWidth = baseWidth * sidebarFraction;
              final double handlePreviewWidth = baseWidth * previewFraction;
              final bool isCollapsed =
                  sidebarFraction < _minVisibleSidebarFraction;

              final Widget canvas = DrawingCanvas(
                drawingController: drawingController,
                currentTool: currentTool,
                resolveTool: controller.resolveTool,
                eraserRadiusFor: controller.eraserRadiusFor,
                onPersistDrawing: controller.persistDrawing,
                onTwoFingerUndo: _handleUndo,
                paperStyle: controller.note.paperStyle,
              );

              final double rawHandleOffset = math.max(
                handlePreviewWidth - _dragHandleWidth,
                0,
              );
              final double handleOffset = rawHandleOffset > baseWidth
                  ? baseWidth
                  : rawHandleOffset;
              final double orientationFactor = panelOnRight ? 1 : -1;

              return Stack(
                children: [
                  Positioned.fill(child: canvas),
                  AnimatedPositioned(
                    duration: _panelAnimationDuration,
                    curve: _panelAnimationCurve,
                    top: 0,
                    bottom: 0,
                    left: panelOnRight ? null : 0,
                    right: panelOnRight ? 0 : null,
                    width: panelWidth,
                    child: IgnorePointer(
                      ignoring: isCollapsed,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 120),
                        opacity: isCollapsed ? 0 : 1,
                        child: AssistantPanel(
                          isActive: _isResizing,
                          widthFraction: previewFraction,
                          resizeTrend: _resizeTrend,
                          side: editorSettings.sidebarSide,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: panelOnRight ? null : handleOffset,
                    right: panelOnRight ? handleOffset : null,
                    child: SizedBox(
                      width: _dragHandleWidth,
                      child: SidebarResizeHandle(
                        isActive: _isResizing,
                        side: editorSettings.sidebarSide,
                        onDragStart: () => setState(() {
                          _isResizing = true;
                          _previewSidebarFraction = _sidebarFraction;
                          _resizeTrend = SidebarResizeTrend.none;
                        }),
                        onDragUpdate: (delta) {
                          setState(() {
                            final double currentPreview =
                                _previewSidebarFraction ?? _sidebarFraction;
                            final double deltaFraction =
                                (delta / baseWidth) * orientationFactor;
                            final double proposedFraction =
                                currentPreview - deltaFraction;
                            final double nextPreview = _snapSidebarFraction(
                              currentPreview,
                              proposedFraction,
                            );

                            _previewSidebarFraction = nextPreview;

                            if (nextPreview > currentPreview) {
                              _resizeTrend = SidebarResizeTrend.expand;
                            } else if (nextPreview < currentPreview) {
                              _resizeTrend = SidebarResizeTrend.shrink;
                            } else {
                              _resizeTrend = SidebarResizeTrend.none;
                            }
                          });
                        },
                        onDragEnd: () => setState(() {
                          final double previous = _sidebarFraction;
                          final double target =
                              _previewSidebarFraction ?? _sidebarFraction;
                          final double adjustedTarget = _snapSidebarFraction(
                            previous,
                            target,
                          );

                          _sidebarFraction = adjustedTarget;
                          _previewSidebarFraction = null;
                          _isResizing = false;
                          _resizeTrend = SidebarResizeTrend.none;
                        }),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
