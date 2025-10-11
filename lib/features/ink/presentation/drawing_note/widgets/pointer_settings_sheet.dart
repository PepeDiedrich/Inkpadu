import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:flutter/material.dart';

/// Bottom-Sheet zum Konfigurieren der Eingabegeräte für die Zeichenfläche.
class PointerSettingsSheet extends StatefulWidget {
  /// Erstellt das Sheet.
  const PointerSettingsSheet({super.key});

  /// Öffnet das Sheet im aktuellen Kontext.
  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (_) => const PointerSettingsSheet(),
  );

  @override
  State<PointerSettingsSheet> createState() => _PointerSettingsSheetState();
}

class _PointerSettingsSheetState extends State<PointerSettingsSheet> {
  @override
  Widget build(BuildContext context) {
    final settings = PointerSettingsScope.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        key: const PageStorageKey('pointer_settings_sheet_scroll'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eingabegeräte',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _ToggleRow(
              label: 'Stift',
              value: settings.allowStylus,
              onChanged: (v) => setState(() => settings.update(stylus: v)),
            ),
            _ToggleRow(
              label: 'Touch',
              value: settings.allowTouch,
              onChanged: (v) => setState(() => settings.update(touch: v)),
            ),
            _ToggleRow(
              label: 'Maus',
              value: settings.allowMouse,
              onChanged: (v) => setState(() => settings.update(mouse: v)),
            ),
            const Divider(height: 28),
            _ToggleRow(
              label: 'Automatisch auf Stift sperren',
              value: settings.autoLockOnStylus,
              onChanged: (v) => setState(() => settings.update(autoLock: v)),
            ),
            if (settings.stylusLocked) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => settings.resetStylusLock()),
                child: const Text('Stift-Sperre aufheben'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    value: value,
    onChanged: onChanged,
  );
}
