import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/static_note_page.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Eine Miniaturansicht einer Notiz.
class NoteThumbnail extends StatefulWidget {
  /// Erstellt eine [NoteThumbnail].
  const NoteThumbnail({
    super.key,
    required this.note,
    this.width = 100,
    this.height = 140,
  });

  /// Die Notiz, für die ein Thumbnail angezeigt werden soll.
  final InkNote note;

  /// Breite des Thumbnails.
  final double width;

  /// Höhe des Thumbnails.
  final double height;

  @override
  State<NoteThumbnail> createState() => _NoteThumbnailState();
}

class _NoteThumbnailState extends State<NoteThumbnail> {
  PdfDocument? _pdfDocument;
  bool _isLoadingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadPdfIfNeeded();
  }

  @override
  void didUpdateWidget(NoteThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.note.pdfBackgroundPath != oldWidget.note.pdfBackgroundPath) {
      _loadPdfIfNeeded();
    }
  }

  @override
  void dispose() {
    _pdfDocument?.dispose();
    super.dispose();
  }

  Future<void> _loadPdfIfNeeded() async {
    final path = widget.note.pdfBackgroundPath;
    if (path == null) {
      if (_pdfDocument != null) {
        setState(() {
          _pdfDocument?.dispose();
          _pdfDocument = null;
        });
      }
      return;
    }

    setState(() {
      _isLoadingPdf = true;
    });

    try {
      final doc = await PdfDocument.openFile(path);
      if (mounted) {
        setState(() {
          _pdfDocument?.dispose();
          _pdfDocument = doc;
          _isLoadingPdf = false;
        });
      } else {
        doc.dispose();
      }
    } catch (e) {
      debugPrint('[NoteThumbnail] Error loading PDF: $e');
      if (mounted) {
        setState(() {
          _isLoadingPdf = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = widget.note;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // StaticNotePage as preview
          Positioned.fill(
            child: IgnorePointer(
              child: FittedBox(
                alignment: Alignment.topCenter,
                fit: BoxFit.cover,
                child: SizedBox(
                  width: 1000,
                  height: 1414,
                  child: StaticNotePage(
                    page: note.currentPage,
                    paperStyle: note.paperStyle,
                    pdfDocument: _pdfDocument,
                    pdfPageIndex: note.lastOpenedPageIndex,
                  ),
                ),
              ),
            ),
          ),

          if (_isLoadingPdf)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),

          if (note.pdfBackgroundPath != null)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.picture_as_pdf,
                  size: 12,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget für den "Keine Notizen" Zustand.
class EmptyNotesView extends StatelessWidget {
  /// Erstellt eine [EmptyNotesView].
  const EmptyNotesView({super.key, required this.onCreatePressed});

  /// Callback, wenn der "Erste Notiz erstellen" Button gedrückt wird.
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note_alt_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              t.notes.noNotes,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              t.onboarding.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onCreatePressed,
              icon: const Icon(Icons.add),
              label: Text(t.notes.createFirst),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
