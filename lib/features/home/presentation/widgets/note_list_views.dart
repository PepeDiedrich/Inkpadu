import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/home/presentation/widgets/home_widgets.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// A list view for displaying notes.
class NoteListView extends StatelessWidget {
  /// The notes to display.
  final List<InkNote> notes;

  /// The selected note IDs.
  final Set<String> selectedNoteIds;

  /// Whether selection mode is active.
  final bool isSelectionMode;

  /// Callback when a note selection is toggled.
  final ValueChanged<String> onToggleSelection;

  /// Callback when a note is opened.
  final ValueChanged<String> onOpen;

  /// Callback when selection mode is entered.
  final ValueChanged<String> onEnterSelectionMode;

  /// Creates a [NoteListView].
  const NoteListView({
    super.key,
    required this.notes,
    required this.selectedNoteIds,
    required this.isSelectionMode,
    required this.onToggleSelection,
    required this.onOpen,
    required this.onEnterSelectionMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      key: const PageStorageKey('home_list'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final n = notes[index];
        final isSelected = selectedNoteIds.contains(n.id);

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
                  _fmt(context, n.updatedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              if (isSelectionMode) {
                onToggleSelection(n.id);
              } else {
                onOpen(n.id);
              }
            },
            onLongPress: () => onEnterSelectionMode(n.id),
            trailing: isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggleSelection(n.id),
                  )
                : const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

String _fmt(BuildContext context, DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return context.t.common.justNow;
  if (diff.inHours < 1) return '${diff.inMinutes} min';
  if (diff.inHours < 24) return '${diff.inHours} h';
  return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
}

/// A grid view for displaying notes.
class NoteGridView extends StatelessWidget {
  /// The notes to display.
  final List<InkNote> notes;

  /// The selected note IDs.
  final Set<String> selectedNoteIds;

  /// Whether selection mode is active.
  final bool isSelectionMode;

  /// Callback when a note selection is toggled.
  final ValueChanged<String> onToggleSelection;

  /// Callback when a note is opened.
  final ValueChanged<String> onOpen;

  /// Callback when selection mode is entered.
  final ValueChanged<String> onEnterSelectionMode;

  /// Callback when note actions are shown.
  final ValueChanged<InkNote> onShowNoteActions;

  /// Creates a [NoteGridView].
  const NoteGridView({
    super.key,
    required this.notes,
    required this.selectedNoteIds,
    required this.isSelectionMode,
    required this.onToggleSelection,
    required this.onOpen,
    required this.onEnterSelectionMode,
    required this.onShowNoteActions,
  });

  @override
  Widget build(BuildContext context) {
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
        final isSelected = selectedNoteIds.contains(n.id);

        return InkWell(
          onTap: () {
            if (isSelectionMode) {
              onToggleSelection(n.id);
            } else {
              onOpen(n.id);
            }
          },
          onLongPress: () => onEnterSelectionMode(n.id),
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
                          tooltip: context.t.common.edit,
                          onPressed: () => onShowNoteActions(n),
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
                        _fmt(context, n.updatedAt),
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
}
