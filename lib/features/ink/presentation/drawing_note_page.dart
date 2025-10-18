import 'dart:math' as math;

import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart'
  show StrokeBoundingBoxCluster;
import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_note_controller.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_tool_preferences_repository.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/drawing/presentation/drawing_painter.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/drawing_tool_preferences_sync_service.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/assistant_panel.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_canvas.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_tool_editor_sheet.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_tool_palette.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/sidebar_resize_handle.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

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

  void _handleClear() {
    final controller = _maybeController;
    if (controller == null) return;
    if (controller.drawingController.clear()) {
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

        // PageController beim ersten initialisierten Build anlegen
        _pageController ??= PageController(
          initialPage: controller.currentPageIndex,
        );

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              // Sicherstellen, dass die aktuelle Seite und Striche persistiert werden,
              // damit beim nächsten Öffnen genau diese Seite wieder geladen wird.
              controller.persistDrawing();
              // Letzten geöffneten Seitenindex speichern
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
                const SizedBox(height: 4),
                Text(
                  'Seite ${controller.currentPageIndex + 1} / ${controller.pages.length}',
                  style: Theme.of(context).textTheme.bodySmall,
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
                onPressed: () => _openToolConfigurator(currentTool),
                tooltip: 'Aktuelles Werkzeug bearbeiten',
                icon: const Icon(Icons.design_services),
              ),
              AnimatedBuilder(
                animation: drawingController,
                builder: (context, _) => IconButton(
                  onPressed:
                      drawingController.canUndo ? _handleClear : null,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Zeichenfläche leeren',
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

        final notesScope = InkNotesScope.of(context);
        final String noteId = controller.note.id;
        final int pageIndex = controller.currentPageIndex;
        final double? initOffset =
          notesScope.getScrollOffset(noteId, pageIndex);

              final Widget canvas = DrawingCanvas(
                drawingController: drawingController,
                currentTool: currentTool,
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
                scrollKey: PageStorageKey(
                  'note_${controller.note.id}_page_${controller.currentPageIndex}_scroll',
                ),
                initScrollOffset: initOffset,
                onScrollOffsetChanged: (offset) {
                  final c = _maybeController;
                  if (c == null || !c.isInitialized) return;
                  final currentId = c.note.id;
                  final currentPage = c.currentPageIndex;
                  notesScope.setScrollOffset(currentId, currentPage, offset);
                },
                onStrokeClustersChanged: _handleStrokeClustersChanged,
              );

              final double rawHandleOffset = math.max(
                handlePreviewWidth - _dragHandleWidth,
                0,
              );
              final double handleOffset = rawHandleOffset > baseWidth
                  ? baseWidth
                  : rawHandleOffset;
              final double orientationFactor = panelOnRight ? 1 : -1;

              final List<NotePage> pages = controller.pages;
              final bool canCreateNewPage = controller.currentPageHasContent;
              final int placeholderIndex =
                  canCreateNewPage ? pages.length : -1;
              final int pageCount = pages.length + (canCreateNewPage ? 1 : 0);

              return Stack(
                children: [
                  Positioned.fill(
                    child: PageView.builder(
                      key: PageStorageKey('note_${controller.note.id}_page_view'),
                      controller: _pageController,
                      physics: _pageScrollLocked
                          ? const NeverScrollableScrollPhysics()
                          : const PageScrollPhysics(),
                      onPageChanged: (index) {
                        if (canCreateNewPage && index == placeholderIndex) {
                          if (!_creatingPage) {
                            _creatingPage = true;
                            final int? newIndex =
                                controller.addPageAfterCurrent();
                            if (newIndex != null &&
                                _pageController?.hasClients == true) {
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
                          // Beim Seitenwechsel: aktuellen Offset der alten Seite sichern
                          final oldId = controller.note.id;
                          final oldPage = controller.currentPageIndex;
                          final scrollOffset =
                              notesScope.getScrollOffset(oldId, oldPage) ?? 0.0;
                          notesScope.setScrollOffset(oldId, oldPage, scrollOffset);

                          controller.setCurrentPage(index);

              // Für die neue Seite: der Canvas liest initScrollOffset
              // beim Neuaufbau (siehe oben), daher kein direkter jumpTo nötig.
                        }
                      },
                      itemCount: pageCount,
                      itemBuilder: (context, index) {
                        if (canCreateNewPage && index == placeholderIndex) {
                          return const _AddPagePlaceholder();
                        }
                        if (index >= pages.length) {
                          return const SizedBox.shrink();
                        }
                        final page = pages[index];
                        final bool isActive = index == controller.currentPageIndex;
                        if (isActive) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: canvas,
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _focusPage(index),
                            child: _StaticNotePage(
                              page: page,
                              paperStyle: controller.note.paperStyle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
                          controller: controller,
                          strokeClusters: _latestStrokeClusters,
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
        ),
        );
      },
    );
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

  void _handleStrokeClustersChanged(
    List<StrokeBoundingBoxCluster> clusters,
  ) {
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
}

class _AddPagePlaceholder extends StatelessWidget {
  const _AddPagePlaceholder();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Wische nach rechts, um eine neue Seite zu erstellen.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
}

class _StaticNotePage extends StatelessWidget {
  const _StaticNotePage({required this.page, required this.paperStyle});

  final NotePage page;
  final NotePaperStyle paperStyle;

  static const double _initialCanvasHeight = 1600;
  static const double _canvasBottomPadding = 600;

  double _requiredCanvasHeight() {
    var maxY = 0.0;
    for (final stroke in page.strokes) {
      for (final point in stroke.points) {
        if (point.position.dy > maxY) {
          maxY = point.position.dy;
        }
      }
    }
    return math.max(_initialCanvasHeight, maxY + _canvasBottomPadding);
  }

  @override
  Widget build(BuildContext context) {
    final double height = _requiredCanvasHeight();
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: NotePaperBackground(
          paperStyle: paperStyle,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: FinishedStrokesPainter(
                strokes: page.strokes,
                version: page.strokes.hashCode,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
