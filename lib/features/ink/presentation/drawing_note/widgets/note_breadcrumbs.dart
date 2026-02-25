import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note_page.dart';
import 'package:flutter/material.dart';

/// Zeigt den Pfad der aktuellen Notiz in der Hierarchie an.
class NoteBreadcrumbs extends StatelessWidget {
  /// Erstellt ein Breadcrumb-Widget.
  const NoteBreadcrumbs({
    super.key,
    required this.currentNoteId,
  });

  /// Die ID der aktuellen Notiz.
  final String currentNoteId;

  @override
  Widget build(BuildContext context) {
    final notesController = InkNotesScope.of(context);
    final path = _buildPath(notesController, currentNoteId);

    if (path.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: path.length,
              separatorBuilder: (context, index) => Icon(
                Icons.chevron_right,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              itemBuilder: (context, index) {
                final note = path[index];
                final isLast = index == path.length - 1;

                return InkWell(
                  onTap: isLast
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => DrawingNotePage(
                                noteId: note.id,
                              ),
                            ),
                          );
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Center(
                      child: Text(
                        note.title.isEmpty ? 'Untitled' : note.title,
                        style: TextStyle(
                          color: isLast
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.primary,
                          fontWeight:
                              isLast ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<InkNote> _buildPath(InkNotesController controller, String noteId) {
    final List<InkNote> path = [];
    try {
      final note = controller.notes.firstWhere((n) => n.id == noteId);
      path.add(note);
    } catch (e) {
      // Note not found
    }
    return path;
  }
}
