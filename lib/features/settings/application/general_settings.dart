import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Verwaltet allgemeine App-Einstellungen wie Theme und Sprache.
class GeneralSettings extends ChangeNotifier {
  /// Erstellt neue [GeneralSettings] und lädt gespeicherte Werte.
  GeneralSettings() {
    _loadFromPrefs();
  }

  static const String _prefKeyTheme = 'general_settings_themeMode';
  static const String _prefKeyLocale = 'general_settings_locale';

  ThemeMode _themeMode = ThemeMode.system;
  AppLocale? _locale;

  /// Der aktuell gewählte Theme-Modus.
  ThemeMode get themeMode => _themeMode;

  /// Die aktuell gewählte Sprache (null bedeutet Systemstandard).
  AppLocale? get locale => _locale;

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeIndex = prefs.getInt(_prefKeyTheme);
      if (themeIndex != null &&
          themeIndex >= 0 &&
          themeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeIndex];
      }

      final localeTag = prefs.getString(_prefKeyLocale);
      if (localeTag != null) {
        try {
          _locale = AppLocaleUtils.parse(localeTag);
        } catch (_) {
          _locale = null;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load GeneralSettings: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKeyTheme, _themeMode.index);
      if (_locale != null) {
        await prefs.setString(_prefKeyLocale, _locale!.languageTag);
      } else {
        await prefs.remove(_prefKeyLocale);
      }
    } catch (e) {
      debugPrint('Failed to save GeneralSettings: $e');
    }
  }

  /// Aktualisiert den Theme-Modus.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _saveToPrefs();
      notifyListeners();
    }
  }

  /// Aktualisiert die Sprache.
  void setLocale(AppLocale? locale) {
    if (_locale != locale) {
      _locale = locale;
      _saveToPrefs();
      notifyListeners();
      if (locale != null) {
        LocaleSettings.setLocale(locale);
      } else {
        LocaleSettings.useDeviceLocale();
      }
    }
  }
}

/// InheritedNotifier für [GeneralSettings].
class GeneralSettingsScope extends InheritedNotifier<GeneralSettings> {
  /// Erstellt einen neuen Scope.
  const GeneralSettingsScope({
    super.key,
    required GeneralSettings settings,
    required super.child,
  }) : super(notifier: settings);

  /// Liefert die [GeneralSettings] aus dem Kontext.
  static GeneralSettings of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<GeneralSettingsScope>();
    assert(scope != null, 'GeneralSettingsScope nicht im Widget-Tree gefunden');
    return scope!.notifier!;
  }

  @override
  bool updateShouldNotify(
    covariant InheritedNotifier<GeneralSettings> oldWidget,
  ) => true;
}
