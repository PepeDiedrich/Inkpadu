import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/static_note_page.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Displays an overview panel showing thumbnails of all note pages.
class PageOverviewPanel extends StatefulWidget {
  /// Creates a new page overview panel.
  const PageOverviewPanel({
    super.key,
    required this.pages,
    required this.currentPageIndex,
    required this.paperStyle,
    this.pdfBackgroundPath,
    required this.onPageSelected,
  });

  /// The list of pages to display.
  final List<NotePage> pages;

  /// The index of the currently active page.
  final int currentPageIndex;

  /// The style of the note paper (e.g., ruled, squared, blank).
  final NotePaperStyle paperStyle;

  /// Optional path to a PDF background file.
  final String? pdfBackgroundPath;

  /// Callback fired when a page is selected from the overview.
  final ValueChanged<int> onPageSelected;

  @override
  State<PageOverviewPanel> createState() => _PageOverviewPanelState();
}

class _PageOverviewPanelState extends State<PageOverviewPanel> {
  PdfDocument? _sharedPdfDocument;

  @override
  void initState() {
    super.initState();
    _loadPdfIfNeeded();
  }

  @override
  void didUpdateWidget(PageOverviewPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pdfBackgroundPath != oldWidget.pdfBackgroundPath) {
      _loadPdfIfNeeded();
    }
  }

  @override
  void dispose() {
    _sharedPdfDocument?.dispose();
    super.dispose();
  }

  Future<void> _loadPdfIfNeeded() async {
    final path = widget.pdfBackgroundPath;
    if (path == null) {
      if (_sharedPdfDocument != null) {
        _sharedPdfDocument!.dispose();
        _sharedPdfDocument = null;
        if (mounted) setState(() {});
      }
      return;
    }

    try {
      final doc = await PdfDocument.openFile(path);
      if (mounted) {
        setState(() {
          _sharedPdfDocument?.dispose();
          _sharedPdfDocument = doc;
        });
      } else {
        doc.dispose();
      }
    } catch (e) {
      debugPrint('[PageOverviewPanel] Error loading PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(left: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Überblick',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: widget.pages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final page = widget.pages[index];
                final isSelected = index == widget.currentPageIndex;

                return GestureDetector(
                  onTap: () => widget.onPageSelected(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: colorScheme.surface,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AspectRatio(
                          aspectRatio: 1 / 1.414, // A4 ratio
                          child: IgnorePointer(
                            child: FittedBox(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: 1000,
                                height: 1414,
                                child: StaticNotePage(
                                  page: page,
                                  paperStyle: widget.paperStyle,
                                  pdfDocument: _sharedPdfDocument,
                                  pdfPageIndex: index,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seite ${index + 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : null,
                          color: isSelected ? colorScheme.primary : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
