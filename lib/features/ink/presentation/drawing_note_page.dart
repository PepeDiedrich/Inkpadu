import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart'
    show StrokeBoundingBoxCluster;
import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_note_controller.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_tool_preferences_repository.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/drawing_tool_preferences_sync_service.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/pdf_export_service.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/assistant_panel.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_canvas.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_tool_editor_sheet.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_tool_palette.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/layout/note_page_view.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/layout/resizable_sidebar_layout.dart';
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
  DrawingToolPreferencesRepository? _toolPreferencesRepository;
  DrawingNoteController? _controller;
  bool _repositoryInitialized = false;
  bool _controllerInitialized = false;
  bool _pageScrollLocked = false;

  // Sidebar state
  double _sidebarFraction = 0.3;

  // Assistant state
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

    // Persistiere aktuelle Striche bevor Export
    controller.persistDrawing();

    // Zeige Ladeanzeige
    scaffold.showSnackBar(
      const SnackBar(
        content: Text('PDF wird erstellt...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final service = PdfExportService();
      await service.exportAndShare(controller.note);
    } on Exception catch (e) {
      if (!mounted) return;
      scaffold.showSnackBar(
        SnackBar(
          content: Text('PDF-Export fehlgeschlagen: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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

        final DrawingController drawingController =
            controller.drawingController;
        final DrawingTool currentTool = controller.currentTool;

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
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  tooltip: 'Als PDF exportieren',
                  onPressed: () => _exportNoteToPdf(controller),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: ResizableSidebarLayout(
              initialSidebarFraction: _sidebarFraction,
              onSidebarFractionChanged: (fraction) => _sidebarFraction = fraction,
              content: Builder(builder: (context) {
                  final notesScope = InkNotesScope.of(context);
                  final String noteId = controller.note.id;
                  final int pageIndex = controller.currentPageIndex;
                  final double? initOffset =
                    notesScope.getScrollOffset(noteId, pageIndex);

                  return NotePageView(
                    noteId: controller.note.id,
                    pages: controller.pages,
                    currentPageIndex: controller.currentPageIndex,
                    paperStyle: controller.note.paperStyle,
                    canCreateNewPage: controller.currentPageHasContent,
                    scrollLocked: _pageScrollLocked,
                    onPageChanged: (index) {
                      final oldId = controller.note.id;
                      final oldPage = controller.currentPageIndex;
                      // Scroll offset is managed by the canvas/list view,
                      // but we are relying on InkNotesScope to hold it.
                      // When page changes, we need to save the offset of the OLD page.
                      // Since we don't have direct access to the ScrollController here easily
                      // (it's inside DrawingCanvas), we rely on DrawingCanvas's onScrollOffsetChanged
                      // to keep the scope updated live. So we just need to set the new page index.
                      controller.setCurrentPage(index);
                    },
                    onPageCreated: controller.addPageAfterCurrent,
                    activeCanvas: DrawingCanvas(
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
                    ),
                  );
                }
              ),
              sidebar: Builder(
                builder: (context) {
                   // We need the resize state from the layout.
                   // However, AssistantPanel needs 'isActive' (isResizing) and 'resizeTrend'
                   // which are internal to ResizableSidebarLayoutState.
                   // Ideally AssistantPanel wouldn't need these layout details, but it likely uses them for animation.
                   //
                   // Since ResizableSidebarLayout encapsulates this, we can try to pass the state down
                   // or accept that AssistantPanel inside might not animate perfectly with drag *trends*
                   // unless we expose them.
                   //
                   // To keep it simple and clean, let's look at what AssistantPanel needs:
                   // isActive: _isResizing
                   // widthFraction: previewFraction
                   // resizeTrend: _resizeTrend
                   // side: editorSettings.sidebarSide
                   //
                   // We can access the parent ResizableSidebarLayoutState if we want, or pass a builder.
                   final layoutState = context.findAncestorStateOfType<ResizableSidebarLayoutState>();

                   return AssistantPanel(
                      isActive: layoutState?.isResizing ?? false,
                      widthFraction: layoutState?.currentFraction ?? _sidebarFraction,
                      resizeTrend: layoutState?.resizeTrend ?? SidebarResizeTrend.none,
                      side: editorSettings.sidebarSide,
                      controller: controller,
                      strokeClusters: _latestStrokeClusters,
                    );
                }
              ),
            ),
          ),
        );
      },
    );
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
