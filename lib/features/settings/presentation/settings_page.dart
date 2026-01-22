import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/input/presentation/pointer_settings_page.dart';
import 'package:ai_handwriting_app/features/editor/presentation/editor_settings_page.dart';
import 'package:ai_handwriting_app/features/editor/presentation/assistant_persona_settings_page.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Placeholder settings screen showcasing configurable sections.
class SettingsPage extends StatelessWidget {
  /// Creates a new [SettingsPage].
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    appBar: AppBar(title: Text(context.t.settings.title)),
    body: ListView(
      key: const PageStorageKey('settings_list'),
      padding: const EdgeInsets.all(20),
      children: [
        _SettingsSection(
          title: context.t.settings.general,
          tiles: [
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: context.t.settings.theme,
              subtitle: context.t.settings.themeSubtitle,
            ),
            _SettingsTile(
              icon: Icons.translate,
              title: context.t.settings.language,
              subtitle: context.t.settings.languageSubtitle,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SettingsSection(
          title: context.t.settings.input,
          tiles: [
            _SettingsTile(
              icon: Icons.tune,
              title: context.t.settings.inputDevices,
              subtitle: context.t.settings.inputDeviceSubtitle,
              onTap: () => _openPointerSettings(context),
            ),
            _SettingsTile(
              icon: Icons.view_sidebar_outlined,
              title: context.t.settings.noteEditor,
              subtitle: context.t.settings.noteEditorSubtitle,
              onTap: () => _openEditorSettings(context),
            ),
            _SettingsTile(
              icon: Icons.brush_outlined,
              title: context.t.settings.strokeWidths,
              subtitle: context.t.settings.strokeWidthsSubtitle,
            ),
            _SettingsTile(
              icon: Icons.gesture_outlined,
              title: context.t.settings.palmRejection,
              subtitle: context.t.settings.palmRejectionSubtitle,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SettingsSection(
          title: context.t.ai.assistant,
          tiles: [
            _SettingsTile(
              icon: Icons.psychology_outlined,
              title: context.t.ai.persona,
              subtitle: context.t.ai.personaSubtitle,
              onTap: () => _openPersonaSettings(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SettingsSection(
          title: context.t.settings.cloud,
          tiles: [
            _SettingsTile(
              icon: Icons.cloud_outlined,
              title: context.t.settings.storageTarget,
              subtitle: context.t.settings.storageSubtitle,
            ),
            _SettingsTile(
              icon: Icons.security_outlined,
              title: context.t.settings.encryption,
              subtitle: context.t.settings.encryptionSubtitle,
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

  static Future<void> _openPersonaSettings(BuildContext context) =>
      Navigator.of(
        context,
      ).push<void>(_PointerSettingsRoute(const AssistantPersonaSettingsPage()));
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
          context.t.settings.account,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                  SnackBar(content: Text(context.t.common.loggedOut)),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      context.t.auth.logout,
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
