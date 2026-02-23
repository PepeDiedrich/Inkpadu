import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/add_page_placeholder.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_canvas.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/static_note_page.dart';
import 'package:flutter/material.dart';

/// The main content area showing the PageView with note pages.
///
/// Renders the active page with [DrawingCanvas] and inactive pages
/// with [StaticNotePage]. Handles page navigation and creation.
class NotePageContent extends StatelessWidget {
  /// Creates the note page content.
  const NotePageContent({
    super.key,
    required this.noteId,
    required this.pages,
    required this.currentPageIndex,
    required this.pageController,
    required this.pageScrollLocked,
    required this.drawingController,
    required this.currentTool,
    required this.resolveTool,
    required this.eraserRadiusFor,
    required this.onPersistDrawing,
    required this.onTwoFingerUndo,
    required this.onThreeFingerRedo,
    required this.paperStyle,
    required this.onRequestParentScrollLock,
    required this.initScrollOffset,
    required this.onScrollOffsetChanged,
    required this.onPageChanged,
    required this.onFocusPage,
    required this.canCreateNewPage,
  });

  /// The note ID for storage keys.
  final String noteId;

  /// All pages in the note.
  final List<NotePage> pages;

  /// Index of the currently active page.
  final int currentPageIndex;

  /// Controller for the PageView.
  final PageController pageController;

  /// Whether page scrolling is locked (during drawing).
  final bool pageScrollLocked;

  /// Controller for the drawing canvas.
  final DrawingController drawingController;

  /// The currently selected drawing tool.
  final DrawingTool currentTool;

  /// Callback to resolve a tool by ID.
  final DrawingTool Function(String? toolId) resolveTool;

  /// Callback to get eraser radius for a tool.
  final double Function(DrawingTool tool) eraserRadiusFor;

  /// Callback to persist drawing changes.
  final VoidCallback onPersistDrawing;

  /// Callback for two-finger undo gesture.
  final VoidCallback onTwoFingerUndo;

  /// Callback for three-finger redo gesture.
  final VoidCallback onThreeFingerRedo;

  /// The paper style for the canvas.
  final NotePaperStyle paperStyle;

  /// Callback to lock/unlock parent scroll.
  final ValueChanged<bool> onRequestParentScrollLock;

  /// Initial scroll offset for the canvas.
  final double? initScrollOffset;

  /// Callback when scroll offset changes.
  final ValueChanged<double> onScrollOffsetChanged;

  /// Callback when page changes.
  final ValueChanged<int> onPageChanged;

  /// Callback to focus a specific page.
  final ValueChanged<int> onFocusPage;

  /// Whether a new page can be created.
  final bool canCreateNewPage;

  @override
  Widget build(BuildContext context) {
    final int placeholderIndex = canCreateNewPage ? pages.length : -1;
    final int pageCount = pages.length + (canCreateNewPage ? 1 : 0);

    return PageView.builder(
      key: PageStorageKey('note_${noteId}_page_view'),
      controller: pageController,
      physics: pageScrollLocked
          ? const NeverScrollableScrollPhysics()
          : const PageScrollPhysics(),
      onPageChanged: onPageChanged,
      itemCount: pageCount,
      itemBuilder: (context, index) {
        if (canCreateNewPage && index == placeholderIndex) {
          return const AddPagePlaceholder();
        }
        if (index >= pages.length) {
          return const SizedBox.shrink();
        }
        final page = pages[index];
        final bool isActive = index == currentPageIndex;

        if (isActive) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Expanded(
                  child: DrawingCanvas(
                    drawingController: drawingController,
                    currentTool: currentTool,
                    resolveTool: resolveTool,
                    eraserRadiusFor: eraserRadiusFor,
                    onPersistDrawing: onPersistDrawing,
                    onTwoFingerUndo: onTwoFingerUndo,
                    onThreeFingerRedo: onThreeFingerRedo,
                    paperStyle: paperStyle,
                    onRequestParentScrollLock: onRequestParentScrollLock,
                    scrollKey: PageStorageKey(
                      'note_${noteId}_page_${currentPageIndex}_scroll',
                    ),
                    initScrollOffset: initScrollOffset,
                    onScrollOffsetChanged: onScrollOffsetChanged,
                  ),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onFocusPage(index),
            child: Column(
              children: [
                Expanded(
                  child: StaticNotePage(
                    page: page,
                    paperStyle: paperStyle,
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
