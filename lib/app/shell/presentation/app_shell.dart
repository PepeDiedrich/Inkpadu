import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/home/presentation/home_page.dart';
import 'package:ai_handwriting_app/features/settings/presentation/settings_page.dart';

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

  static const List<NavigationDestination> _destinations =
      <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.folder_copy_outlined),
          selectedIcon: Icon(Icons.folder_copy),
          label: 'Notizen',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Einstellungen',
        ),
      ];

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
      destinations: _destinations,
      onDestinationSelected: _onDestinationSelected,
    ),
  );
}
