import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import 'package:ai_handwriting_app/app/auth/appwrite_config.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/application/pdf/pdf_import_service.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/pdf_export_service.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note_page.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/note_metadata_dialog.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/pdf_picker_dialog.dart';

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
                title: const Text('Notiz öffnen'),
                onTap: () => Navigator.of(context).pop(_NoteAction.open),
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: const Text('Titel & Papier anpassen'),
                onTap: () => Navigator.of(context).pop(_NoteAction.metadata),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Als PDF exportieren'),
                onTap: () => Navigator.of(context).pop(_NoteAction.exportPdf),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Notiz löschen',
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
        await _exportNoteToPdf(note);
        break;
      case _NoteAction.delete:
        await _deleteNote(note.id, note.title);
        break;
    }
  }

  Future<void> _exportNoteToPdf(InkNote note) async {
    final scaffold = ScaffoldMessenger.of(context);

    // Zeige Ladeanzeige
    scaffold.showSnackBar(
      const SnackBar(
        content: Text('PDF wird erstellt...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final service = PdfExportService();
      await service.exportAndShare(note);
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
                      'Neue Notiz erstellen',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.note_add_outlined),
                title: const Text('Leere Notiz'),
                subtitle: const Text('Starte mit einer leeren Seite'),
                onTap: () => Navigator.of(context).pop('empty'),
              ),
              if (PdfImportService.isAvailable)
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('PDF importieren'),
                  subtitle: const Text('Text wird automatisch extrahiert'),
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
        await _importPdfAndCreate();
        break;
    }
  }

  Future<void> _importPdfAndCreate() async {
    // PDF auswählen
    final PdfPickerResult? pickerResult = await PdfPickerDialog.show(context);

    if (!mounted || pickerResult == null) return;

    // Metadaten-Dialog anzeigen
    final result = await showNoteMetadataDialog(
      context,
      initialTitle: InkNote.generateTitle(),
      initialPaperStyle: NotePaperStyle.plain,
    );

    if (!mounted || result == null) return;

    final controller = InkNotesScope.of(context);
    
    // Notiz mit leeren Seiten erstellen (Anzahl = PDF-Seitenzahl)
    final note = controller.createEmptyForPdfImport(
      pageCount: pickerResult.pageCount,
      title: result.title,
      paperStyle: result.paperStyle,
    );

    // Notiz sofort öffnen
    _open(note.id);

    // PDF-Verarbeitung im Hintergrund starten
    final functions = Functions(AppwriteConfig.client);
    
    // Optional: Anderes Modell für PDF-Extraktion konfigurieren
    // const pdfConfig = PdfExtractionConfig(
    //   deploymentName: 'gpt-4o',  // Oder ein anderes Vision-Modell
    // );
    final pdfImportService = PdfImportService(functions: functions);

    // Hintergrundverarbeitung starten (fire and forget)
    controller.startPdfBackgroundProcessing(
      noteId: note.id,
      pdfBytes: pickerResult.pdfBytes,
      pdfImportService: pdfImportService,
    );
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
        title: const Text('Notiz löschen'),
        content: Text('Möchten Sie "$title" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen'),
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
      appBar: AppBar(title: const Text('Notizen')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOptions(),
        icon: const Icon(Icons.add),
        label: const Text('Neue Notiz'),
      ),
      body: notes.isEmpty
          ? const Center(child: Text('Noch keine handschriftlichen Notizen'))
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
                          tooltip: 'Notiz löschen',
                          icon: const Icon(Icons.delete_outline),
                          style: IconButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
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
    if (diff.inMinutes < 1) return 'Gerade eben';
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}
