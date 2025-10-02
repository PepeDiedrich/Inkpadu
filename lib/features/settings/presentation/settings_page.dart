import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/input/presentation/pointer_settings_page.dart';
import 'package:ai_handwriting_app/features/editor/presentation/editor_settings_page.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';

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
        _SettingsSection(
          title: 'Eingabe',
          tiles: [
            _SettingsTile(
              icon: Icons.tune,
              title: 'Eingabegerät',
              subtitle: 'Stift · Touch · Maus',
              onTap: () => _openPointerSettings(context),
            ),
            _SettingsTile(
              icon: Icons.view_sidebar_outlined,
              title: 'Notiz-Editor',
              subtitle: 'Seitenpanel links · rechts',
              onTap: () => _openEditorSettings(context),
            ),
            const _SettingsTile(
              icon: Icons.brush_outlined,
              title: 'Stiftstärken',
              subtitle: 'Dünn · Medium · Fett',
            ),
            const _SettingsTile(
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
        const SizedBox(height: 32),
        _LogoutSection(),
      ],
    ),
  );

  static Future<void> _openPointerSettings(BuildContext context) =>
      Navigator.of(
        context,
      ).push<void>(_PointerSettingsRoute(const PointerSettingsPage()));

  static Future<void> _openEditorSettings(BuildContext context) => Navigator.of(
    context,
  ).push<void>(_PointerSettingsRoute(const EditorSettingsPage()));
}

class _LogoutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final isLoggedIn = auth.isLoggedIn;
    if (!isLoggedIn) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konto',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () async {
              await auth.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abgemeldet')), );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Abmelden',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
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
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
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

class _PointerSettingsRoute extends PageRouteBuilder<void> {
  _PointerSettingsRoute(this.child)
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: const Duration(milliseconds: 280),
      );

  final Widget child;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    final offsetAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(curved);
    return SlideTransition(position: offsetAnimation, child: child);
  }
}
