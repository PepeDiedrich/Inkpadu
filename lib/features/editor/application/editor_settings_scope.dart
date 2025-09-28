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
  /// Erstellt neue [EditorSettings] mit optionalen Vorgaben.
  EditorSettings({
    this.sidebarSide = EditorSidebarSide.right,
    this.lineSimplifierEnabled = true,
  });

  /// Aktuell gewählte Seite des Assistenz-Panels.
  EditorSidebarSide sidebarSide;

  /// `true`, wenn der Linien-Simplifier aktiv ist.
  bool lineSimplifierEnabled;

  /// Convenience: `true`, wenn das Panel links erscheinen soll.
  bool get isPanelOnLeft => sidebarSide == EditorSidebarSide.left;

  /// Convenience: `true`, wenn das Panel rechts erscheinen soll.
  bool get isPanelOnRight => sidebarSide == EditorSidebarSide.right;

  /// Aktualisiert einzelne Properties und benachrichtigt Listener.
  void update({EditorSidebarSide? sidebarSide, bool? lineSimplifierEnabled}) {
    var hasChanged = false;
    if (sidebarSide != null && sidebarSide != this.sidebarSide) {
      this.sidebarSide = sidebarSide;
      hasChanged = true;
    }
    if (lineSimplifierEnabled != null &&
        lineSimplifierEnabled != this.lineSimplifierEnabled) {
      this.lineSimplifierEnabled = lineSimplifierEnabled;
      hasChanged = true;
    }
    if (hasChanged) {
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
