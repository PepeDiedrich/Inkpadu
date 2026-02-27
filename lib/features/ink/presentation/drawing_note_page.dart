import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_note_controller.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_tool_preferences_repository.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/drawing_tool_preferences_sync_service.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_tool_editor_sheet.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/floating_tool_window.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_page_content.dart';
import 'package:flutter/material.dart';

/// Editor-Seite zum Bearbeiten einer handschriftlichen Notiz.
class DrawingNotePage extends StatefulWidget {
  /// Creates a new [DrawingNotePage].
  const DrawingNotePage({super.key, required this.noteId});

  /// ID der zu öffnenden Notiz.
  final String noteId;

  @override
  State<DrawingNotePage> createState() => _DrawingNotePageState();
}

class _DrawingNotePageState extends State<DrawingNotePage> {
  DrawingToolPreferencesRepository? _toolPreferencesRepository;
  DrawingNoteController? _controller;
  bool _repositoryInitialized = false;
  bool _controllerInitialized = false;
  PageController? _pageController;
  bool _creatingPage = false;
  bool _pageScrollLocked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_repositoryInitialized) {
      _toolPreferencesRepository = DrawingToolPreferencesRepository(
        authController: AuthScope.maybeOf(context),
        syncService: DrawingToolPreferencesSyncService(),
      );
      _repositoryInitialized = true;
    }

    if (!_controllerInitialized) {
      _controller = DrawingNoteController(
        noteId: widget.noteId,
        inkNotesController: InkNotesScope.of(context),
        toolPreferencesRepository: _toolPreferencesRepository!,
      );
      _controllerInitialized = true;
      _controller!.initialize();
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _handleUndo() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.drawingController.undo()) {
      controller.persistDrawing();
    }
  }

  void _handleRedo() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.drawingController.redo()) {
      controller.persistDrawing();
    }
  }

  void _handlePageChanged(int index, DrawingNoteController controller) {
    if (!mounted) return;

    final notesScope = InkNotesScope.of(context);
    if (index >= controller.pages.length && !_creatingPage) {
      _creatingPage = true;
      final int? newIndex = controller.addPageAfterCurrent();
      if (newIndex != null) {
        _pageController?.animateToPage(
          newIndex,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
      _creatingPage = false;
      return;
    }

    if (index < controller.pages.length && index != controller.currentPageIndex) {
      notesScope.setScrollOffset(
        controller.note.id,
        controller.currentPageIndex,
        notesScope.getScrollOffset(controller.note.id, controller.currentPageIndex) ??
            0.0,
      );
      controller.setCurrentPage(index);
    }
  }

  Future<void> _openToolConfigurator(DrawingTool tool) async {
    final controller = _controller;
    if (controller == null) return;

    if (tool.id == DrawingToolDefaults.aiLassoId) {
      return;
    }

    final DrawingTool? updated = await DrawingToolEditorSheet.show(
      context,
      tool: tool,
    );
    if (updated == null) return;
    await controller.updateTool(updated);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        _pageController ??= PageController(initialPage: controller.currentPageIndex);
        final notesScope = InkNotesScope.of(context);

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) return;
            controller.persistDrawing();
            InkNotesScope.of(context).upsert(
              controller.note.copyWith(
                lastOpenedPageIndex: controller.currentPageIndex,
                updatedAt: DateTime.now(),
              ),
              changedPageIndices: const <int>{},
            );
          },
          child: Scaffold(
            body: Stack(
              children: [
                NotePageContent(
                  noteId: controller.note.id,
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
                  pdfBackgroundPath: controller.note.pdfBackgroundPath,
                  onRequestParentScrollLock: (lock) =>
                      setState(() => _pageScrollLocked = lock),
                  initScrollOffset: notesScope.getScrollOffset(
                    controller.note.id,
                    controller.currentPageIndex,
                  ),
                  onScrollOffsetChanged: (offset) => notesScope.setScrollOffset(
                    controller.note.id,
                    controller.currentPageIndex,
                    offset,
                  ),
                  onPageChanged: (index) => _handlePageChanged(index, controller),
                  onFocusPage: (index) {
                    controller.setCurrentPage(index);
                    _pageController?.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  canCreateNewPage: controller.currentPageHasContent,
                ),
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
