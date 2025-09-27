import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// Konfiguration der erlaubten Eingabegeräte.
/// Verwaltet welche Eingabegeräte akzeptiert werden und Stylus-Lock Logik.
class PointerSettings extends ChangeNotifier {
  /// Gibt an, ob Eingaben per Stylus erlaubt sind.
  bool allowStylus;

  /// Gibt an, ob Touch-Eingaben akzeptiert werden.
  bool allowTouch;

  /// Gibt an, ob Maus-Eingaben akzeptiert werden.
  bool allowMouse;

  /// Aktiviert den automatischen Stylus-Lock nach erster Nutzung.
  bool autoLockOnStylus;
  bool _stylusLocked = false;

  /// Erstellt eine neue [PointerSettings]-Instanz.
  PointerSettings({
    this.allowStylus = true,
    this.allowTouch = true,
    this.allowMouse = true,
    this.autoLockOnStylus = true,
  });

  /// True sobald Stylus erkannt und Lock aktiv ist.
  bool get stylusLocked => _stylusLocked;

  /// Hebt den Stylus-Lock auf.
  void resetStylusLock() {
    _stylusLocked = false;
    notifyListeners();
  }

  /// Aktualisiert Konfiguration einzelner Flags.
  void update({bool? stylus, bool? touch, bool? mouse, bool? autoLock}) {
    if (stylus != null) allowStylus = stylus;
    if (touch != null) allowTouch = touch;
    if (mouse != null) allowMouse = mouse;
    if (autoLock != null) autoLockOnStylus = autoLock;
    notifyListeners();
  }

  /// Prüft ob der Pointer akzeptiert wird (unter Berücksichtigung des Locks).
  bool accept(PointerDeviceKind kind) {
    if (_stylusLocked && kind != PointerDeviceKind.stylus) return false;
    switch (kind) {
      case PointerDeviceKind.stylus:
        return allowStylus;
      case PointerDeviceKind.touch:
        return allowTouch;
      case PointerDeviceKind.mouse:
        return allowMouse;
      default:
        return false;
    }
  }

  /// Registriert eine Pointer-Nutzung (für Auto-Lock Stylus).
  void register(PointerDeviceKind kind) {
    if (autoLockOnStylus &&
        !_stylusLocked &&
        kind == PointerDeviceKind.stylus) {
      _stylusLocked = true;
      notifyListeners();
    }
  }
}

/// Inherited Scope für globalen Zugriff auf [PointerSettings].
/// Ein [InheritedNotifier] zum Verwalten des Zustands der Zeigereinstellungen.
class PointerSettingsScope extends InheritedNotifier<PointerSettings> {
  /// Erstellt eine neue [PointerSettingsScope].
  const PointerSettingsScope({
    super.key,
    required PointerSettings settings,
    required super.child,
  }) : super(notifier: settings);

  /// Liefert die [PointerSettings] Instanz aus dem Kontext.
  static PointerSettings of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<PointerSettingsScope>();
    assert(scope != null, 'PointerSettingsScope nicht gefunden');
    return scope!.notifier!;
  }

  @override
  @override
  bool updateShouldNotify(
    covariant InheritedNotifier<PointerSettings> oldWidget,
  ) => true;
}
