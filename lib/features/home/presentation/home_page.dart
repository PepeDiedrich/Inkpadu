import 'package:ai_handwriting_app/features/ink/application/pdf_export_service.dart';
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note_page.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/note_metadata_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Startseite: Liste handschriftlicher Notizen mit Navigation in den Zeichen-Editor.
class HomePage extends StatefulWidget {
  /// Creates a new [HomePage].
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum _NoteAction { open, metadata, exportPdf, delete }


class _HomePageState extends State<HomePage> {
  Future<void> _showNoteActions(InkNote note) async {
    final _NoteAction? action = await showModalBottomSheet<_NoteAction>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  children: [
                    Icon(Icons.note_alt_outlined,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        note.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.draw_outlined),
                title: Text(context.t.notes.openNote),
                onTap: () => Navigator.of(context).pop(_NoteAction.open),
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: Text(context.t.notes.adjustTitlePaper),
                onTap: () => Navigator.of(context).pop(_NoteAction.metadata),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: Text(context.t.pdf.export),
                onTap: () => Navigator.of(context).pop(_NoteAction.exportPdf),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  context.t.notes.deleteNote,
                  style: textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => Navigator.of(context).pop(_NoteAction.delete),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _NoteAction.open:
        _open(note.id);
        break;
      case _NoteAction.metadata:
        await _editNoteMetadata(note);
        break;
      case _NoteAction.exportPdf:
        await _exportPdf(note);
        break;
      case _NoteAction.delete:
        await _deleteNote(note.id, note.title);
        break;
    }
  }

  Future<void> _exportPdf(InkNote note) async {
    // Zeige Ladeindikator
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Text(context.t.pdf.exporting),
          ],
        ),
      ),
    );

    try {
      final service = PdfExportService();
      final screenWidth = MediaQuery.of(context).size.width;
      final pdfBytes = await service.exportNoteToPdf(note, canvasWidth: screenWidth);
      
      if (!mounted) return;
      // Schließe Ladeindikator
      Navigator.of(context).pop();

      // Teile/Speichere das PDF
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '${note.title}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      // Schließe Ladeindikator
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t.pdf.exportFailed(error: e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _editNoteMetadata(InkNote note) async {
    final controller = InkNotesScope.of(context);
    final NoteMetadataResult? result = await showNoteMetadataDialog(
      context,
      initialTitle: note.title,
      initialPaperStyle: note.paperStyle,
      isEditing: true,
    );

    if (!mounted || result == null) {
      return;
    }

    final String trimmedTitle = result.title.trim();
    final String nextTitle =
        trimmedTitle.isEmpty ? InkNote.generateTitle() : trimmedTitle;
    final InkNote updated = note.copyWith(
      title: nextTitle,
      paperStyle: result.paperStyle,
      updatedAt: DateTime.now(),
    );
    controller.upsert(updated, changedPageIndices: const <int>{});
  }

  Future<void> _showCreateOptions() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final String? choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      context.t.notes.createNew,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.note_add_outlined),
                title: Text(context.t.notes.emptyNote),
                subtitle: Text(context.t.notes.emptyNoteSubtitle),
                onTap: () => Navigator.of(context).pop('empty'),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: Text(context.t.pdf.import),
                subtitle: Text(context.t.notes.createNew),
                onTap: () => Navigator.of(context).pop('pdf'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
    );

    if (!mounted || choice == null) return;

    switch (choice) {
      case 'empty':
        await _createAndOpen();
        break;
      case 'pdf':
        await _importPdf();
        break;
    }
  }

  Future<void> _importPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final filename = result.files.single.name;
      
      if (!mounted) return;
      final controller = InkNotesScope.of(context);
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Text(context.t.pdfDialog.processPdf),
            ],
          ),
        ),
      );

      final note = await controller.createFromPdf(path, title: filename);
      
      if (!mounted) return;
      Navigator.of(context).pop();

      if (note != null) {
        _open(note.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.errors.unknownError)),
        );
      }
    }
  }

  Future<void> _createAndOpen() async {
    final controller = InkNotesScope.of(context);
    final result = await showNoteMetadataDialog(
      context,
      initialTitle: InkNote.generateTitle(),
      initialPaperStyle: NotePaperStyle.plain,
    );
    if (!mounted) {
      return;
    }
    if (result == null) {
      return;
    }

    final note = controller.createEmpty(
      title: result.title,
      paperStyle: result.paperStyle,
    );
    _open(note.id);
  }

  void _open(String id) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => DrawingNotePage(noteId: id)),
    );
  }

  Future<void> _deleteNote(String id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t.notes.deleteNote),
        content: Text(context.t.notes.deleteNoteConfirm(title: title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.t.common.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.t.common.delete),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final controller = InkNotesScope.of(context);
    controller.delete(id);
  }

  @override
  Widget build(BuildContext context) {
  final notes = InkNotesScope.of(context).notes;
  final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.t.notes.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOptions(),
        icon: const Icon(Icons.add),
        label: Text(context.t.notes.newNote),
      ),
      body: notes.isEmpty
          ? Center(child: Text(context.t.notes.noNotes))
      : ListView.builder(
        key: const PageStorageKey('home_list'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final n = notes[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(n.title),
                    subtitle: Text(
                      '${n.currentPage.strokes.length} Striche · ${_fmt(n.updatedAt)} · ${n.paperStyle.label}',
                    ),
                    onTap: () => _open(n.id),
                    onLongPress: () => _showNoteActions(n),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: context.t.notes.deleteNoteTooltip,
                          icon: const Icon(Icons.delete_outline),
                          color: theme.colorScheme.error,
                          onPressed: () => _deleteNote(n.id, n.title),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _fmt(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return context.t.common.justNow;
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}
