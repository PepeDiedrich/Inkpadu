import 'package:flutter/material.dart';

/// Legt fest, auf welcher Seite das Editor-Seitenpanel angezeigt wird.
enum EditorSidebarSide {
  /// Panel befindet sich links neben der Zeichenfläche (empfohlen für Rechtshänder:innen).
  left,

  /// Panel befindet sich rechts neben der Zeichenfläche (empfohlen für Linkshänder:innen).
  right,
}

/// Einstellungen für den Notiz-Editor.
class EditorSettings extends ChangeNotifier {
  /// Erstellt neue [EditorSettings] mit optionaler Vorgabe.
  EditorSettings({this.sidebarSide = EditorSidebarSide.right});

  /// Aktuell gewählte Seite des Assistenz-Panels.
  EditorSidebarSide sidebarSide;

  /// Convenience: `true`, wenn das Panel links erscheinen soll.
  bool get isPanelOnLeft => sidebarSide == EditorSidebarSide.left;

  /// Convenience: `true`, wenn das Panel rechts erscheinen soll.
  bool get isPanelOnRight => sidebarSide == EditorSidebarSide.right;

  /// Aktualisiert einzelne Properties und benachrichtigt Listener.
  void update({EditorSidebarSide? sidebarSide}) {
    if (sidebarSide != null && sidebarSide != this.sidebarSide) {
      this.sidebarSide = sidebarSide;
      notifyListeners();
    }
  }
}

/// Ermöglicht globalen Zugriff auf [EditorSettings].
class EditorSettingsScope extends InheritedNotifier<EditorSettings> {
  /// Erstellt einen neuen Scope.
  const EditorSettingsScope({
    super.key,
    required EditorSettings settings,
    required super.child,
  }) : super(notifier: settings);

  /// Liefert die [EditorSettings] aus dem Kontext.
  static EditorSettings of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<EditorSettingsScope>();
    assert(scope != null, 'EditorSettingsScope nicht im Widget-Tree gefunden');
    return scope!.notifier!;
  }

  @override
  bool updateShouldNotify(
    covariant InheritedNotifier<EditorSettings> oldWidget,
  ) => true;
}
