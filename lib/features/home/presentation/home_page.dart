import 'package:inkpadu/features/ink/application/pdf_export_service.dart';
import 'package:inkpadu/features/home/presentation/widgets/home_widgets.dart';
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:inkpadu/features/ink/application/ink_notes_scope.dart';
import 'package:inkpadu/features/ink/domain/ink_note.dart';
import 'package:inkpadu/features/ink/domain/note_paper_style.dart';
import 'package:inkpadu/features/home/presentation/widgets/note_list_views.dart';
import 'package:inkpadu/features/ink/presentation/drawing_note_page.dart';
import 'package:inkpadu/features/ink/presentation/widgets/note_metadata_dialog.dart';
import 'package:inkpadu/i18n/translations.g.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Startseite: Liste handschriftlicher Notizen mit Navigation in den Zeichen-Editor.
class HomePage extends StatefulWidget {
  /// Creates a new [HomePage].
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum _NoteAction { open, metadata, exportPdf, delete }

/// Optionen für die Sortierung von Notizen.
enum SortOption {
  /// Absteigend nach Datum.
  dateDesc,

  /// Aufsteigend nach Datum.
  dateAsc,

  /// Aufsteigend nach Name.
  nameAsc,

  /// Absteigend nach Name.
  nameDesc,
}

class _HomePageState extends State<HomePage> {
  bool _isGridView = true;
  String _searchQuery = '';
  SortOption _sortOption = SortOption.dateDesc;
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
      case SortOption.dateDesc:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case SortOption.dateAsc:
        filtered.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case SortOption.nameAsc:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case SortOption.nameDesc:
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
      appBar: _buildAppBar(),
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
                            tooltip: t.common.close,
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
                      ? NoteGridView(
                          notes: filteredNotes,
                          selectedNoteIds: _selectedNoteIds,
                          isSelectionMode: _isSelectionMode,
                          onToggleSelection: _toggleSelection,
                          onOpen: _open,
                          onEnterSelectionMode: _enterSelectionMode,
                          onShowNoteActions: _showNoteActions,
                        )
                      : NoteListView(
                          notes: filteredNotes,
                          selectedNoteIds: _selectedNoteIds,
                          isSelectionMode: _isSelectionMode,
                          onToggleSelection: _toggleSelection,
                          onOpen: _open,
                          onEnterSelectionMode: _enterSelectionMode,
                        ),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() => HomeAppBar(
    isSelectionMode: _isSelectionMode,
    selectedNotesCount: _selectedNoteIds.length,
    isSearching: _isSearching,
    isGridView: _isGridView,
    onExitSelectionMode: _exitSelectionMode,
    onSelectAll: () {
      setState(() {
        final allNotes = InkNotesScope.of(context).notes;
        _selectedNoteIds.addAll(allNotes.map((n) => n.id));
      });
    },
    onDeleteSelected: _deleteSelectedNotes,
    onExportSelected: _exportSelectedNotes,
    onToggleSearch: () => setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    }),
    onSortSelected: (value) => setState(() => _sortOption = value),
    onToggleGridView: () => setState(() => _isGridView = !_isGridView),
  );
}

/// Startseite AppBar.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Ob der Auswahlmodus aktiv ist.
  final bool isSelectionMode;

  /// Anzahl der ausgewählten Notizen.
  final int selectedNotesCount;

  /// Ob gerade gesucht wird.
  final bool isSearching;

  /// Ob die Grid-Ansicht aktiv ist.
  final bool isGridView;

  /// Callback zum Beenden des Auswahlmodus.
  final VoidCallback onExitSelectionMode;

  /// Callback zum Auswählen aller Notizen.
  final VoidCallback onSelectAll;

  /// Callback zum Löschen der ausgewählten Notizen.
  final VoidCallback onDeleteSelected;

  /// Callback zum Exportieren der ausgewählten Notizen.
  final VoidCallback onExportSelected;

  /// Callback zum Umschalten der Suche.
  final VoidCallback onToggleSearch;

  /// Callback zum Ändern der Sortierung.
  final ValueChanged<SortOption> onSortSelected;

  /// Callback zum Umschalten der Ansicht.
  final VoidCallback onToggleGridView;

  /// Erstellt eine [HomeAppBar].
  const HomeAppBar({
    super.key,
    required this.isSelectionMode,
    required this.selectedNotesCount,
    required this.isSearching,
    required this.isGridView,
    required this.onExitSelectionMode,
    required this.onSelectAll,
    required this.onDeleteSelected,
    required this.onExportSelected,
    required this.onToggleSearch,
    required this.onSortSelected,
    required this.onToggleGridView,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    if (isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: t.common.close,
          onPressed: onExitSelectionMode,
        ),
        title: Text(t.notes.selectedCount(count: selectedNotesCount)),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: t.notes.selectAll,
            onPressed: onSelectAll,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: t.notes.deleteSelected,
            onPressed: onDeleteSelected,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: t.notes.exportSelected,
            onPressed: onExportSelected,
          ),
        ],
      );
    }

    return AppBar(
      title: isSearching
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
          icon: Icon(isSearching ? Icons.search_off : Icons.search),
          tooltip: t.common.search,
          onPressed: onToggleSearch,
        ),
        PopupMenuButton<SortOption>(
          icon: const Icon(Icons.sort),
          onSelected: onSortSelected,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: SortOption.dateDesc,
              child: Text(t.notes.sortByDate),
            ),
            PopupMenuItem(
              value: SortOption.nameAsc,
              child: Text(t.notes.sortByName),
            ),
          ],
        ),
        IconButton(
          icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: onToggleGridView,
          tooltip: isGridView ? t.notes.listView : t.notes.gridView,
        ),
      ],
    );
  }
}
