import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note_page.dart';
import 'package:ai_handwriting_app/features/input/presentation/pointer_settings_sheet.dart';

/// Startseite: Liste handschriftlicher Notizen mit Navigation in den Zeichen-Editor.
class HomePage extends StatefulWidget {
  /// Creates a new [HomePage].
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _createAndOpen() {
    final controller = InkNotesScope.of(context);
    final note = controller.createEmpty();
    _open(note.id);
  }

  void _open(String id) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => DrawingNotePage(noteId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = InkNotesScope.of(context).notes;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notizen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Eingabe-Einstellungen',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (_) => const PointerSettingsSheet(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createAndOpen,
        icon: const Icon(Icons.add),
        label: const Text('Neue Notiz'),
      ),
      body: notes.isEmpty
          ? const Center(child: Text('Noch keine handschriftlichen Notizen'))
          : ListView.builder(
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
                      '${n.page.strokes.length} Striche · ${_fmt(n.updatedAt)}',
                    ),
                    onTap: () => _open(n.id),
                    trailing: const Icon(Icons.chevron_right),
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
