import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/editor/presentation/editor_page.dart';
import 'package:ai_handwriting_app/features/notes/domain/note.dart';

/// Displays the list of saved notes and routes to the editor.
class HomePage extends StatefulWidget {
  /// Creates a new [HomePage].
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Note> _notes;

  @override
  void initState() {
    super.initState();
    _notes = _initialNotes();
  }

  List<Note> _initialNotes() {
    final now = DateTime.now();
    final notes = <Note>[
      Note(
        id: '1',
        title: 'Meeting-Notizen',
        content: 'Kickoff mit dem Design-Team vorbereitet. Aufgaben festhalten.',
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      Note(
        id: '2',
        title: 'Skizze – App Layout',
        content: 'Navigation und Editor-Fluss skizzieren.',
        updatedAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      Note(
        id: '3',
        title: 'Ideen für neue Stifte',
        content: 'Varianten für Drucksensitivität notieren.',
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Future<void> _openEditor(Note note, {required bool isNew}) async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (context) => EditorPage(initialNote: note, isNew: isNew),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (isNew && result.title.trim().isEmpty && result.content.trim().isEmpty) {
      return;
    }

    setState(() {
      final updated = List<Note>.from(_notes);
      final existingIndex =
          updated.indexWhere((item) => item.id == result.id);

      if (existingIndex >= 0) {
        updated[existingIndex] = result;
      } else {
        updated.add(result);
      }

      updated.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _notes = updated;
    });
  }

  Future<void> _createNote() => _openEditor(Note.empty(), isNew: true);

  Future<void> _editExisting(Note note) => _openEditor(note, isNew: false);

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Heute, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }

    if (difference.inDays == 1) {
      return 'Gestern, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }

    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    return '$day.$month.${timestamp.year}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Deine Notizen'),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _createNote,
      icon: const Icon(Icons.create),
      label: const Text('Neue Notiz'),
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: _notes.isEmpty
          ? const Center(
            child: Text('Noch keine Notizen. Starte mit einer neuen.'),
          )
          : ListView.builder(
            itemCount: _notes.length,
            itemBuilder: (context, index) {
              final note = _notes[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    note.displayTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(note.preview),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(note.updatedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editExisting(note),
                ),
              );
            },
          ),
    ),
  );
}
