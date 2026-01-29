import 'package:flutter/material.dart';

/// Placeholder widget displayed when swiping to create a new page.
class AddPagePlaceholder extends StatelessWidget {
  /// Creates an add page placeholder.
  const AddPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Wische nach rechts, um eine neue Seite zu erstellen.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
}
