import 'package:flutter/material.dart';

import 'package:inkpadu/features/home/presentation/home_page.dart';
import 'package:inkpadu/features/settings/presentation/settings_page.dart';
import 'package:inkpadu/i18n/translations.g.dart';

/// Hosts the main navigation scaffold with bottom navigation items.
class AppShell extends StatefulWidget {
  /// Creates a new [AppShell].
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = <Widget>[HomePage(), SettingsPage()];

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _currentIndex, children: _pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _currentIndex,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.folder_copy_outlined),
          selectedIcon: const Icon(Icons.folder_copy),
          label: context.t.nav.notes,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: context.t.nav.settings,
        ),
      ],
      onDestinationSelected: _onDestinationSelected,
    ),
  );
}
