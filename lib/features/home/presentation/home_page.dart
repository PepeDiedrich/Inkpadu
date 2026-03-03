import 'package:ai_handwriting_app/features/ink/application/pdf_export_service.dart';
import 'package:ai_handwriting_app/features/home/presentation/widgets/home_widgets.dart';
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note_page.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/note_metadata_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Startseite: Liste handschriftlicher Notizen mit Navigation in den Zeichen-Editor.
class HomePage extends StatefulWidget {
  /// Creates a new [HomePage].
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum _NoteAction { open, metadata, exportPdf, delete }

enum _SortOption { dateDesc, dateAsc, nameAsc, nameDesc }

class _HomePageState extends State<HomePage> {
  bool _isGridView = false;
  String _searchQuery = '';
  _SortOption _sortOption = _SortOption.dateDesc;
  final Set<String> _selectedNoteIds = {};
  bool _isSelectionMode = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InkNote> _getFilteredAndSortedNotes(List<InkNote> notes) {
    List<InkNote> filtered = notes;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = notes
          .where((n) => n.title.toLowerCase().contains(query))
          .toList();
    } else {
      filtered = List.from(notes);
    }

    switch (_sortOption) {
      case _SortOption.dateDesc:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case _SortOption.dateAsc:
        filtered.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case _SortOption.nameAsc:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case _SortOption.nameDesc:
        filtered.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
    }
    return filtered;
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedNoteIds.contains(id)) {
        _selectedNoteIds.remove(id);
        if (_selectedNoteIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedNoteIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _enterSelectionMode(String id) {
    setState(() {
      _isSelectionMode = true;
      _selectedNoteIds.add(id);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNoteIds.clear();
    });
  }

  Future<void> _deleteSelectedNotes() async {
    final t = context.t;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.notes.deleteSelected),
        content: Text(
          t.notes.deleteNoteConfirm(
            title: '${_selectedNoteIds.length} ${t.notes.title}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.common.delete),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    final controller = InkNotesScope.of(context);
    for (final id in _selectedNoteIds) {
      controller.delete(id);
    }
    _exitSelectionMode();
  }

  Future<void> _exportSelectedNotes() async {
    // Basic implementation: export as separate PDFs or one combined?
    // For now, let's just show a snackbar or implement a simple loop.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.t.common.loading)));
    // TODO: Implement bulk export if needed
    _exitSelectionMode();
  }

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
                    Icon(
                      Icons.note_alt_outlined,
                      color: theme.colorScheme.primary,
                    ),
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
      final pdfBytes = await service.exportNoteToPdf(
        note,
        canvasWidth: screenWidth,
      );

      if (!mounted) return;
      // Schließe Ladeindikator
      Navigator.of(context).pop();

      // Teile/Speichere das PDF
      await Printing.sharePdf(bytes: pdfBytes, filename: '${note.title}.pdf');
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
    final String nextTitle = trimmedTitle.isEmpty
        ? InkNote.generateTitle()
        : trimmedTitle;
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.t.errors.unknownError)));
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
    final allNotes = InkNotesScope.of(context).notes;
    final filteredNotes = _getFilteredAndSortedNotes(allNotes);
    final theme = Theme.of(context);
    final t = context.t;

    return Scaffold(
      appBar: _buildAppBar(allNotes.length),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showCreateOptions(),
              icon: const Icon(Icons.add),
              label: Text(t.notes.newNote),
            ),
      body: allNotes.isEmpty
          ? EmptyNotesView(onCreatePressed: _showCreateOptions)
          : Column(
              children: [
                if (_isSearching)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: t.notes.searchNotes,
                      leading: const Icon(Icons.search),
                      trailing: [
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor: WidgetStatePropertyAll(
                        theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: filteredNotes.isEmpty
                      ? Center(
                          child: Text(t.common.no),
                        ) // "No results" would be better
                      : _isGridView
                      ? _buildGridView(filteredNotes)
                      : _buildListView(filteredNotes),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(int totalNotesCount) {
    final t = context.t;
    final theme = Theme.of(context);

    if (_isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSelectionMode,
        ),
        title: Text(t.notes.selectedCount(count: _selectedNoteIds.length)),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () {
              setState(() {
                final allNotes = InkNotesScope.of(context).notes;
                _selectedNoteIds.addAll(allNotes.map((n) => n.id));
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteSelectedNotes,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: _exportSelectedNotes,
          ),
        ],
      );
    }

    return AppBar(
      title: _isSearching
          ? null
          : Row(
              children: [
                SvgPicture.asset(
                  'assets/logo.svg',
                  height: 32,
                  width: 32,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
                Text(t.notes.title),
              ],
            ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.search_off : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchQuery = '';
                _searchController.clear();
              }
            });
          },
        ),
        PopupMenuButton<_SortOption>(
          icon: const Icon(Icons.sort),
          onSelected: (value) => setState(() => _sortOption = value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _SortOption.dateDesc,
              child: Text(t.notes.sortByDate),
            ),
            PopupMenuItem(
              value: _SortOption.nameAsc,
              child: Text(t.notes.sortByName),
            ),
          ],
        ),
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () => setState(() => _isGridView = !_isGridView),
          tooltip: _isGridView ? t.notes.listView : t.notes.gridView,
        ),
      ],
    );
  }

  Widget _buildListView(List<InkNote> notes) {
    final theme = Theme.of(context);
    return ListView.builder(
      key: const PageStorageKey('home_list'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final n = notes[index];
        final isSelected = _selectedNoteIds.contains(n.id);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isSelected
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            leading: Stack(
              children: [
                NoteThumbnail(note: n, width: 60, height: 80),
                if (isSelected)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
            title: Text(
              n.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${n.pages.length} ${context.t.notes.pagesCount(count: n.pages.length)} · ${n.paperStyle.label}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  _fmt(n.updatedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              if (_isSelectionMode) {
                _toggleSelection(n.id);
              } else {
                _open(n.id);
              }
            },
            onLongPress: () => _enterSelectionMode(n.id),
            trailing: _isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(n.id),
                  )
                : const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<InkNote> notes) {
    final theme = Theme.of(context);
    return GridView.builder(
      key: const PageStorageKey('home_grid'),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final n = notes[index];
        final isSelected = _selectedNoteIds.contains(n.id);

        return InkWell(
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(n.id);
            } else {
              _open(n.id);
            }
          },
          onLongPress: () => _enterSelectionMode(n.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : theme.colorScheme.surface,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      NoteThumbnail(
                        note: n,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showNoteActions(n),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface
                                .withValues(alpha: 0.7),
                            padding: const EdgeInsets.all(4),
                          ),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fmt(n.updatedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
