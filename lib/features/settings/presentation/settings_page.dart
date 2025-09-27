import 'package:flutter/material.dart';

/// Placeholder settings screen showcasing configurable sections.
class SettingsPage extends StatelessWidget {
  /// Creates a new [SettingsPage].
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    appBar: AppBar(title: const Text('Einstellungen')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SettingsSection(
          title: 'Allgemein',
          tiles: [
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: 'Hell · Dunkel · System',
            ),
            _SettingsTile(
              icon: Icons.translate,
              title: 'Sprache',
              subtitle: 'Deutsch (beta)',
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SettingsSection(
          title: 'Handschrift',
          tiles: [
            _SettingsTile(
              icon: Icons.brush_outlined,
              title: 'Stiftstärken',
              subtitle: 'Dünn · Medium · Fett',
            ),
            _SettingsTile(
              icon: Icons.gesture_outlined,
              title: 'Handflächen-Erkennung',
              subtitle: 'Verhindert ungewollte Eingaben',
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SettingsSection(
          title: 'Cloud & Synchronisation',
          tiles: [
            _SettingsTile(
              icon: Icons.cloud_outlined,
              title: 'Speicherziel',
              subtitle: 'Inkpadu Cloud (kostenlos)',
            ),
            _SettingsTile(
              icon: Icons.security_outlined,
              title: 'Verschlüsselung',
              subtitle: 'Ende-zu-Ende aktiv',
            ),
          ],
        ),
      ],
    ),
  );
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.tiles});

  final String title;
  final List<_SettingsTile> tiles;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 12),
      for (var index = 0; index < tiles.length; index++) ...[
        tiles[index],
        if (index < tiles.length - 1) const SizedBox(height: 12),
      ],
    ],
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}
