import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';

/// Seite zum Konfigurieren der erlaubten Eingabequellen.
class PointerSettingsPage extends StatefulWidget {
  /// Erstellt eine neue [PointerSettingsPage].
  const PointerSettingsPage({super.key});

  @override
  State<PointerSettingsPage> createState() => _PointerSettingsPageState();
}

class _PointerSettingsPageState extends State<PointerSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = PointerSettingsScope.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Eingabegeräte')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Eingabegeräte', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          _ToggleTile(
            label: 'Stift',
            value: settings.allowStylus,
            onChanged: (value) => setState(() => settings.update(stylus: value)),
          ),
          _ToggleTile(
            label: 'Touch',
            value: settings.allowTouch,
            onChanged: (value) => setState(() => settings.update(touch: value)),
          ),
          _ToggleTile(
            label: 'Maus',
            value: settings.allowMouse,
            onChanged: (value) => setState(() => settings.update(mouse: value)),
          ),
          const Divider(height: 32),
          Text('Automatisierung', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          _ToggleTile(
            label: 'Automatisch auf Stift sperren',
            value: settings.autoLockOnStylus,
            onChanged: (value) => setState(() => settings.update(autoLock: value)),
          ),
          if (settings.stylusLocked) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => settings.resetStylusLock()),
                child: const Text('Stift-Sperre aufheben'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        title: Text(label),
        contentPadding: EdgeInsets.zero,
      );
}
