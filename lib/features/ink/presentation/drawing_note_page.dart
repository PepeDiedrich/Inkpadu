import 'dart:math' as math;

import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart'
    show StrokeBoundingBoxCluster;
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_note_controller.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_tool_preferences_repository.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/drawing_tool_preferences_sync_service.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/pdf_export_service.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/animated_sidebar.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_tool_editor_sheet.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_page_content.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/floating_tool_window.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/sidebar_resize_handle.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Page for editing/drawing a single handwritten note.
class DrawingNotePage extends StatefulWidget {
  /// Creates a page for the note with the given [noteId].
  const DrawingNotePage({super.key, required this.noteId});

  /// ID of the note to edit.
  final String noteId;

  @override
  State<DrawingNotePage> createState() => _DrawingNotePageState();
}

class _DrawingNotePageState extends State<DrawingNotePage> {
  static const double _minSidebarFraction = 0.0;
  static const double _minVisibleSidebarFraction = 0.15;
  static const double _maxSidebarFraction = 0.45;
  static const double _dragHandleWidth = 12;

  DrawingToolPreferencesRepository? _toolPreferencesRepository;
  DrawingNoteController? _controller;
  bool _repositoryInitialized = false;
  bool _controllerInitialized = false;
  PageController? _pageController;
  bool _creatingPage = false;
  bool _pageScrollLocked = false;

  double _sidebarFraction = 0.3;
  double? _previewSidebarFraction;
  bool _isResizing = false;
  SidebarResizeTrend _resizeTrend = SidebarResizeTrend.none;
  List<StrokeBoundingBoxCluster> _latestStrokeClusters =
      const <StrokeBoundingBoxCluster>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_repositoryInitialized) {
      final authController = AuthScope.maybeOf(context);
      _toolPreferencesRepository = DrawingToolPreferencesRepository(
        authController: authController,
        syncService: DrawingToolPreferencesSyncService(),
      );
      _repositoryInitialized = true;
    }

    if (_controllerInitialized) {
      return;
    }
    final InkNotesController notesController = InkNotesScope.of(context);
    final DrawingToolPreferencesRepository repository =
        _toolPreferencesRepository!;
    _controller = DrawingNoteController(
      noteId: widget.noteId,
      inkNotesController: notesController,
      toolPreferencesRepository: repository,
    );
    _controllerInitialized = true;
    _controller!.initialize();
  }

  @override
  void dispose() {
    _pageController?.dispose();
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

  Future<void> _openToolConfigurator(DrawingTool tool) async {
    final controller = _maybeController;
    if (controller == null) return;
    final updated = await DrawingToolEditorSheet.show(context, tool: tool);
    if (!mounted || updated == null) {
      return;
    }
    await controller.updateTool(updated);
  }

  Future<void> _exportNoteToPdf(DrawingNoteController controller) async {
    final scaffold = ScaffoldMessenger.of(context);
    final exportingText = context.t.pdf.exporting;
    final errorColor = Theme.of(context).colorScheme.error;

    // Persist current strokes before export
    controller.persistDrawing();

    if (!mounted) return;

    // Show loading indicator
    scaffold.showSnackBar(
      SnackBar(
        content: Text(exportingText),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      final service = PdfExportService();
      await service.exportAndShare(controller.note);
    } on Exception catch (e) {
      if (!mounted) return;
      scaffold.showSnackBar(
        SnackBar(
          content: Text(context.t.pdf.exportFailed(error: e.toString())),
          backgroundColor: errorColor,
        ),
      );
    }
  }

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

  void _handlePageChanged(int index, DrawingNoteController controller) {
    final notesScope = InkNotesScope.of(context);
    final canCreateNewPage = controller.currentPageHasContent;
    final placeholderIndex = canCreateNewPage ? controller.pages.length : -1;
    final pages = controller.pages;

    if (canCreateNewPage && index == placeholderIndex) {
      if (!_creatingPage) {
        _creatingPage = true;
        final int? newIndex = controller.addPageAfterCurrent();
        if (newIndex != null && _pageController?.hasClients == true) {
          _pageController!.animateToPage(
            newIndex,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        } else if (_pageController?.hasClients == true) {
          _pageController!.animateToPage(
            controller.currentPageIndex,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
        _creatingPage = false;
      }
      return;
    }
    if (index >= pages.length) {
      return;
    }
    if (index != controller.currentPageIndex) {
      // Save scroll offset of old page on page change
      final oldId = controller.note.id;
      final oldPage = controller.currentPageIndex;
      final scrollOffset = notesScope.getScrollOffset(oldId, oldPage) ?? 0.0;
      notesScope.setScrollOffset(oldId, oldPage, scrollOffset);

      controller.setCurrentPage(index);
    }
  }

  void _focusPage(int index) {
    final controller = _maybeController;
    if (controller == null || !controller.isInitialized) {
      return;
    }
    controller.setCurrentPage(index);
    if (_pageController?.hasClients == true) {
      _pageController!.animateToPage(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleStrokeClustersChanged(List<StrokeBoundingBoxCluster> clusters) {
    if (!mounted) {
      return;
    }
    if (_latestStrokeClusters.length == clusters.length) {
      var allEqual = true;
      for (var i = 0; i < clusters.length; i++) {
        if (_latestStrokeClusters[i] != clusters[i]) {
          allEqual = false;
          break;
        }
      }
      if (allEqual) {
        return;
      }
    }
    setState(() {
      _latestStrokeClusters = clusters;
    });
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

        // Initialize PageController on first build
        _pageController ??= PageController(
          initialPage: controller.currentPageIndex,
        );

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              // Persist current page and strokes
              controller.persistDrawing();
              // Save last opened page index
              final notes = InkNotesScope.of(context);
              final note = controller.note;
              notes.upsert(
                note.copyWith(
                  lastOpenedPageIndex: controller.currentPageIndex,
                  updatedAt: DateTime.now(),
                ),
                changedPageIndices: const <int>{},
              );
            }
          },
          child: Scaffold(
            body: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxWidth = constraints.maxWidth;
                    final double baseWidth = maxWidth <= 0 ? 1 : maxWidth;
                    final double panelWidth = baseWidth * sidebarFraction;
                    final double handlePreviewWidth =
                        baseWidth * previewFraction;
                    final bool isCollapsed =
                        sidebarFraction < _minVisibleSidebarFraction;

                    final notesScope = InkNotesScope.of(context);
                    final String noteId = controller.note.id;
                    final int pageIndex = controller.currentPageIndex;
                    final double? initOffset = notesScope.getScrollOffset(
                      noteId,
                      pageIndex,
                    );

                    final double rawHandleOffset = math.max(
                      handlePreviewWidth - _dragHandleWidth,
                      0,
                    );
                    final double handleOffset = rawHandleOffset > baseWidth
                        ? baseWidth
                        : rawHandleOffset;
                    final double orientationFactor = panelOnRight ? 1 : -1;
                    final double contentInset = isCollapsed
                        ? 0
                        : baseWidth * previewFraction;

                    return Stack(
                      children: [
                        // Main canvas area
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: panelOnRight ? 0 : contentInset,
                              right: panelOnRight ? contentInset : 0,
                            ),
                            child: NotePageContent(
                              noteId: noteId,
                              pages: controller.pages,
                              currentPageIndex: controller.currentPageIndex,
                              pageController: _pageController!,
                              pageScrollLocked: _pageScrollLocked,
                              drawingController: controller.drawingController,
                              currentTool: controller.currentTool,
                              resolveTool: controller.resolveTool,
                              eraserRadiusFor: controller.eraserRadiusFor,
                              onPersistDrawing: controller.persistDrawing,
                              onTwoFingerUndo: _handleUndo,
                              onThreeFingerRedo: _handleRedo,
                              paperStyle: controller.note.paperStyle,
                              onRequestParentScrollLock: (lock) {
                                if (!mounted) return;
                                if (_pageScrollLocked == lock) return;
                                setState(() => _pageScrollLocked = lock);
                              },
                              initScrollOffset: initOffset,
                              onScrollOffsetChanged: (offset) {
                                final c = _maybeController;
                                if (c == null || !c.isInitialized) return;
                                final currentId = c.note.id;
                                final currentPage = c.currentPageIndex;
                                notesScope.setScrollOffset(
                                  currentId,
                                  currentPage,
                                  offset,
                                );
                              },
                              onStrokeClustersChanged:
                                  _handleStrokeClustersChanged,
                              onPageChanged: (index) =>
                                  _handlePageChanged(index, controller),
                              onFocusPage: _focusPage,
                              canCreateNewPage:
                                  controller.currentPageHasContent,
                            ),
                          ),
                        ),
                        // Sidebar panel
                        AnimatedSidebar(
                          panelWidth: panelWidth,
                          isResizing: _isResizing,
                          previewFraction: previewFraction,
                          resizeTrend: _resizeTrend,
                          sidebarSide: editorSettings.sidebarSide,
                          controller: controller,
                          strokeClusters: _latestStrokeClusters,
                          isCollapsed: isCollapsed,
                        ),
                        // Resize handle
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
                                      _previewSidebarFraction ??
                                      _sidebarFraction;
                                  final double deltaFraction =
                                      (delta / baseWidth) * orientationFactor;
                                  final double proposedFraction =
                                      currentPreview - deltaFraction;
                                  final double nextPreview =
                                      _snapSidebarFraction(
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
                                final double adjustedTarget =
                                    _snapSidebarFraction(previous, target);

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
                // Floating Tool Window
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingToolWindow(
                      tools: controller.tools,
                      selectedToolId: controller.selectedToolId,
                      onToolSelected: controller.selectTool,
                      onToolLongPress: _openToolConfigurator,
                      onExportPdf: () => _exportNoteToPdf(controller),
                      onBackPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
