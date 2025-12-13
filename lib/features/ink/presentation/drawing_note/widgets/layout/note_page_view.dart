import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/features/drawing/presentation/drawing_painter.dart';

class NotePageView extends StatefulWidget {
  const NotePageView({
    super.key,
    required this.noteId,
    required this.pages,
    required this.currentPageIndex,
    required this.paperStyle,
    required this.canCreateNewPage,
    required this.activeCanvas,
    this.onPageChanged,
    this.onPageCreated,
    this.scrollLocked = false,
  });

  final String noteId;
  final List<NotePage> pages;
  final int currentPageIndex;
  final NotePaperStyle paperStyle;
  final bool canCreateNewPage;

  /// The widget to display for the currently active page (the editable canvas).
  final Widget activeCanvas;

  final ValueChanged<int>? onPageChanged;
  final Future<int?> Function()? onPageCreated;
  final bool scrollLocked;

  @override
  State<NotePageView> createState() => NotePageViewState();
}

class NotePageViewState extends State<NotePageView> {
  PageController? _pageController;
  bool _creatingPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentPageIndex);
  }

  @override
  void didUpdateWidget(NotePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPageIndex != oldWidget.currentPageIndex) {
       // If the external index changed (e.g. via tap on overview), animate there if needed
       if (_pageController?.hasClients == true &&
           _pageController?.page?.round() != widget.currentPageIndex) {
         _pageController?.jumpToPage(widget.currentPageIndex);
       }
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  /// Public method to animate to a page
  void animateToPage(int index) {
    if (_pageController?.hasClients == true) {
      _pageController!.animateToPage(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int placeholderIndex = widget.canCreateNewPage ? widget.pages.length : -1;
    final int pageCount = widget.pages.length + (widget.canCreateNewPage ? 1 : 0);

    return PageView.builder(
      key: PageStorageKey('note_${widget.noteId}_page_view'),
      controller: _pageController,
      physics: widget.scrollLocked
          ? const NeverScrollableScrollPhysics()
          : const PageScrollPhysics(),
      onPageChanged: (index) async {
        if (widget.canCreateNewPage && index == placeholderIndex) {
          if (!_creatingPage) {
            _creatingPage = true;
            if (widget.onPageCreated != null) {
              final int? newIndex = await widget.onPageCreated!();
              if (newIndex != null && _pageController?.hasClients == true) {
                _pageController!.animateToPage(
                  newIndex,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                );
              } else if (_pageController?.hasClients == true) {
                // Fallback to previous page if creation failed or cancelled
                _pageController!.animateToPage(
                  widget.currentPageIndex,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                );
              }
            }
            _creatingPage = false;
          }
          return;
        }

        if (index >= widget.pages.length) return;

        if (index != widget.currentPageIndex) {
          widget.onPageChanged?.call(index);
        }
      },
      itemCount: pageCount,
      itemBuilder: (context, index) {
        if (widget.canCreateNewPage && index == placeholderIndex) {
          return const _AddPagePlaceholder();
        }
        if (index >= widget.pages.length) {
          return const SizedBox.shrink();
        }

        final page = widget.pages[index];
        final bool isActive = index == widget.currentPageIndex;

        if (isActive) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: widget.activeCanvas,
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
               widget.onPageChanged?.call(index);
               animateToPage(index);
            },
            child: _StaticNotePage(
              page: page,
              paperStyle: widget.paperStyle,
            ),
          ),
        );
      },
    );
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
