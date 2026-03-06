import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Timer? _stylusLockTimer;

  static const String _prefKeyDb = 'pointer_settings_';

  /// Erstellt eine neue [PointerSettings]-Instanz.
  PointerSettings({
    this.allowStylus = true,
    this.allowTouch = true,
    this.allowMouse = true,
    this.autoLockOnStylus = true,
  }) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      allowStylus = prefs.getBool('${_prefKeyDb}allowStylus') ?? allowStylus;
      allowTouch = prefs.getBool('${_prefKeyDb}allowTouch') ?? allowTouch;
      allowMouse = prefs.getBool('${_prefKeyDb}allowMouse') ?? allowMouse;
      autoLockOnStylus =
          prefs.getBool('${_prefKeyDb}autoLockOnStylus') ?? autoLockOnStylus;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load PointerSettings: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_prefKeyDb}allowStylus', allowStylus);
      await prefs.setBool('${_prefKeyDb}allowTouch', allowTouch);
      await prefs.setBool('${_prefKeyDb}allowMouse', allowMouse);
      await prefs.setBool('${_prefKeyDb}autoLockOnStylus', autoLockOnStylus);
    } catch (e) {
      debugPrint('Failed to save PointerSettings: $e');
    }
  }

  /// True sobald Stylus erkannt und Lock aktiv ist.
  bool get stylusLocked => _stylusLocked;

  /// Hebt den Stylus-Lock auf.
  void resetStylusLock() {
    _stylusLocked = false;
    _stylusLockTimer?.cancel();
    notifyListeners();
  }

  /// Aktualisiert Konfiguration einzelner Flags.
  void update({bool? stylus, bool? touch, bool? mouse, bool? autoLock}) {
    var changed = false;
    if (stylus != null && stylus != allowStylus) {
      allowStylus = stylus;
      changed = true;
    }
    if (touch != null && touch != allowTouch) {
      allowTouch = touch;
      changed = true;
    }
    if (mouse != null && mouse != allowMouse) {
      allowMouse = mouse;
      changed = true;
    }
    if (autoLock != null && autoLock != autoLockOnStylus) {
      autoLockOnStylus = autoLock;
      changed = true;
    }

    if (changed) {
      _saveToPrefs();
      notifyListeners();
    }
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
    if (autoLockOnStylus && kind == PointerDeviceKind.stylus) {
      if (!_stylusLocked) {
        _stylusLocked = true;
        notifyListeners();
      }
      _stylusLockTimer?.cancel();
      _stylusLockTimer = Timer(const Duration(seconds: 10), () {
        _stylusLocked = false;
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _stylusLockTimer?.cancel();
    super.dispose();
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
