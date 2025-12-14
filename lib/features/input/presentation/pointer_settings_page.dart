import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

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
      appBar: AppBar(title: Text(context.t.settings.inputDevices)),
      body: ListView(
        key: const PageStorageKey('pointer_settings_list'),
        padding: const EdgeInsets.all(20),
        children: [
          Text(context.t.settings.inputDevices, style: textTheme.titleMedium),
          const SizedBox(height: 12),
          _ToggleTile(
            label: context.t.settings.pen,
            value: settings.allowStylus,
            onChanged: (value) =>
                setState(() => settings.update(stylus: value)),
          ),
          _ToggleTile(
            label: context.t.settings.touch,
            value: settings.allowTouch,
            onChanged: (value) => setState(() => settings.update(touch: value)),
          ),
          _ToggleTile(
            label: context.t.settings.mouse,
            value: settings.allowMouse,
            onChanged: (value) => setState(() => settings.update(mouse: value)),
          ),
          const Divider(height: 32),
          Text(context.t.settings.automation, style: textTheme.titleMedium),
          const SizedBox(height: 12),
          _ToggleTile(
            label: context.t.settings.autoLockOnStylus,
            value: settings.autoLockOnStylus,
            onChanged: (value) =>
                setState(() => settings.update(autoLock: value)),
          ),
          if (settings.stylusLocked) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => settings.resetStylusLock()),
                child: Text(context.t.settings.unlockPen),
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
