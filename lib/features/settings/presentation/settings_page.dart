// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:inkpadu/features/input/presentation/pointer_settings_page.dart';
import 'package:inkpadu/features/editor/presentation/editor_settings_page.dart';
import 'package:inkpadu/app/auth/auth_scope.dart';
import 'package:inkpadu/features/settings/application/general_settings.dart';
import 'package:inkpadu/features/input/application/pointer_settings_scope.dart';
import 'package:inkpadu/i18n/translations.g.dart';

/// Polished settings screen with interactive elements and refined sections.
class SettingsPage extends StatelessWidget {
  /// Creates a new [SettingsPage].
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final generalSettings = GeneralSettingsScope.of(context);
    final pointerSettings = PointerSettingsScope.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(context.t.settings.title),
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([generalSettings, pointerSettings]),
        builder: (context, _) => ListView(
          key: const PageStorageKey('settings_list'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _SettingsSectionTitle(title: context.t.settings.general),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  title: context.t.settings.theme,
                  subtitle: _getThemeName(context, generalSettings.themeMode),
                  onTap: () => _showThemeDialog(context, generalSettings),
                ),
                _SettingsTile(
                  icon: Icons.translate,
                  title: context.t.settings.language,
                  subtitle: generalSettings.locale?.languageTag ?? 'System',
                  onTap: () => _showLanguageDialog(context, generalSettings),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsSectionTitle(title: context.t.settings.input),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.tune,
                  title: context.t.settings.inputDevices,
                  subtitle: context.t.settings.inputDeviceSubtitle,
                  onTap: () => _openPointerSettings(context),
                ),
                _SettingsTile(
                  icon: Icons.view_sidebar_outlined,
                  title: context.t.settings.noteEditor,
                  subtitle: 'Glättung · KI-Prompts',
                  onTap: () => _openEditorSettings(context),
                ),
                _SwitchSettingsTile(
                  icon: Icons.gesture_outlined,
                  title: context.t.settings.palmRejection,
                  subtitle: context.t.settings.palmRejectionSubtitle,
                  value: pointerSettings.autoLockOnStylus,
                  onChanged: (value) => pointerSettings.update(autoLock: value),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsSectionTitle(title: context.t.settings.about),
            _SettingsCard(
              children: [
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version ?? '...';
                    final buildNumber = snapshot.data?.buildNumber ?? '';
                    return _SettingsTile(
                      icon: Icons.info_outline,
                      title: context.t.settings.version,
                      subtitle: '$version ($buildNumber)',
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Lizenzen',
                  subtitle: 'Open-Source Bibliotheken',
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'Inkpadu',
                    applicationVersion: '1.0.0',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const _LogoutSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _getThemeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return context.t.settings.systemMode;
      case ThemeMode.light:
        return context.t.settings.lightMode;
      case ThemeMode.dark:
        return context.t.settings.darkMode;
    }
  }

  void _showThemeDialog(BuildContext context, GeneralSettings settings) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t.settings.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(context.t.settings.systemMode),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) settings.setThemeMode(value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(context.t.settings.lightMode),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) settings.setThemeMode(value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(context.t.settings.darkMode),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) settings.setThemeMode(value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, GeneralSettings settings) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t.settings.language),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              RadioListTile<AppLocale?>(
                title: Text(context.t.settings.systemMode),
                value: null,
                groupValue: settings.locale,
                onChanged: (value) {
                  settings.setLocale(null);
                  Navigator.pop(context);
                },
              ),
              ...AppLocale.values.map(
                (locale) => RadioListTile<AppLocale?>(
                  title: Text(locale.languageTag),
                  value: locale,
                  groupValue: settings.locale,
                  onChanged: (value) {
                    settings.setLocale(value);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _openPointerSettings(BuildContext context) =>
      Navigator.of(context).push<void>(_FadeRoute(const PointerSettingsPage()));

  static Future<void> _openEditorSettings(BuildContext context) =>
      Navigator.of(context).push<void>(_FadeRoute(const EditorSettingsPage()));
}

class _SettingsSectionTitle extends StatelessWidget {
  final String title;
  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 8),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    ),
  );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1)
            Divider(
              height: 1,
              indent: 56,
              endIndent: 16,
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
        ],
      ],
    ),
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
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(
      subtitle,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
    trailing: onTap != null ? const Icon(Icons.chevron_right, size: 20) : null,
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}

class _SwitchSettingsTile extends StatelessWidget {
  const _SwitchSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
    secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(
      subtitle,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
    value: value,
    onChanged: onChanged,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}

class _LogoutSection extends StatelessWidget {
  const _LogoutSection();

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    if (!auth.isLoggedIn) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingsSectionTitle(title: context.t.settings.account),
        _SettingsCard(
          children: [
            _SettingsTile(
              icon: Icons.logout,
              title: context.t.auth.logout,
              subtitle: 'Von diesem Gerät abmelden',
              onTap: () async {
                await auth.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.t.common.loggedOut)),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _FadeRoute extends PageRouteBuilder<void> {
  _FadeRoute(this.child)
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      );

  final Widget child;
}
