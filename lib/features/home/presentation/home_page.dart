import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/app/theme/app_colors.dart';

/// Placeholder page representing the handwritten file manager view.
class HomePage extends StatelessWidget {
  /// Creates a new [HomePage].
  const HomePage({super.key});

  static const List<_NotePreview> _notes = [
    _NotePreview(
      title: 'Meeting-Notizen',
      subtitle: 'Kickoff mit dem Design-Team',
      timestamp: 'Heute · 09:30',
    ),
    _NotePreview(
      title: 'Skizze – App Layout',
      subtitle: 'Navigation und Editor-Fluss',
      timestamp: 'Gestern · 18:12',
    ),
    _NotePreview(
      title: 'Ideen für neue Stifte',
      subtitle: 'Varianten für Drucksensitivität',
      timestamp: '28. Aug · 14:05',
    ),
    _NotePreview(
      title: 'Workshop Protokoll',
      subtitle: 'Fokus: Handschriftliche Eingaben',
      timestamp: '26. Aug · 11:20',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Deine Notizen'),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_list),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.create),
          label: const Text('Neue Notiz'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                avatar: const Icon(Icons.auto_fix_high, color: Colors.white),
                label: const Text('KI-Empfehlung: Fokus-Notizen'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                labelStyle: const TextStyle(color: AppColors.darkText),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Card(
                      elevation: 0,
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        title: Text(
                          note.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(note.subtitle),
                              const SizedBox(height: 4),
                              Text(
                                note.timestamp,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.more_vert),
                        onTap: () {},
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
}

class _NotePreview {
  const _NotePreview({
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  final String title;
  final String subtitle;
  final String timestamp;
}
