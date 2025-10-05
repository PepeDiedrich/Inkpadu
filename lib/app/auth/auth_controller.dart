import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:appwrite/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_handwriting_app/app/auth/appwrite_config.dart';

/// Enum für den Authentifizierungsstatus der App.
enum AuthStatus {
  /// Status ist noch nicht bestimmt, z.B. beim App-Start.
  unknown,

  /// Nutzer ist nicht angemeldet und es existiert kein gültiger Cache.
  unauthenticated,

  /// Nutzer ist erfolgreich angemeldet oder durch Cache verifiziert.
  authenticated,

  /// Authentifizierungsprozesse laufen gerade.
  loading,
}

/// Verantwortlich für das Abrufen & Aktualisieren des Authentifizierungszustands.
class AuthController extends ChangeNotifier {
  /// Erstellt einen [AuthController].
  AuthController();

  /// Der aktuelle Authentifizierungsstatus.
  AuthStatus _status = AuthStatus.unknown;
  /// Das aktuelle User-Objekt aus Appwrite, falls authentifiziert.
  models.User? _user;
  /// Die gecachte User-ID für Offline-Modus.
  String? _cachedUserId;
  /// Die gecachte E-Mail für Offline-Modus.
  String? _cachedEmail;
  /// Gibt an, ob der Nutzer sich jemals erfolgreich angemeldet hat.
  bool _hasLoggedIn = false;

  static const _kCachedUserIdKey = 'inkpadu_cached_user_id';
  static const _kCachedEmailKey = 'inkpadu_cached_email';
  static const _kHasLoggedInKey = 'inkpadu_has_logged_in';

  /// Gibt den aktuellen Authentifizierungsstatus zurück.
  AuthStatus get status => _status;
  /// Gibt den aktuellen Benutzer zurück, falls authentifiziert.
  models.User? get user => _user;

  /// Liefert die User-ID, entweder aus dem live User-Objekt oder aus dem lokalen Cache.
  String? get userId => _user?.$id ?? _cachedUserId;

  /// Liefert die Email, entweder aus dem live User-Objekt oder aus dem lokalen Cache.
  String? get email => _user?.email ?? _cachedEmail;

  /// Gibt zurück, ob der Nutzer aktuell eingeloggt ist.
  bool get isLoggedIn =>
      _status == AuthStatus.authenticated && (_user != null || _cachedUserId != null);

  /// Lädt den aktuellen Auth-Status inklusive gecachter Offline-Daten.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _hasLoggedIn = prefs.getBool(_kHasLoggedInKey) ?? false;
    try {
      _status = AuthStatus.loading;
      notifyListeners();
      final account = AppwriteConfig.account;
      _user = await account.get();
      _status = AuthStatus.authenticated;
      await _saveCachedUserFromUser();
    } on AppwriteException {
      // No network or Appwrite error: try load cached credentials
      _user = null;
      final cachedId = prefs.getString(_kCachedUserIdKey);
      final cachedEmail = prefs.getString(_kCachedEmailKey);
      if (cachedId != null) {
        _cachedUserId = cachedId;
        _cachedEmail = cachedEmail;
        _status = AuthStatus.authenticated; // treat as authenticated offline
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } finally {
      notifyListeners();
    }
  }

  /// Startet den OAuth2 Flow (z.B. GitHub). Weitere Provider über Parameter.
  /// Startet den OAuth2-Flow für den angegebenen [provider] und optionale [scopes].
  Future<void> loginWithProvider({required OAuthProvider provider, List<String>? scopes}) async {
    if (_status == AuthStatus.loading) return;
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      final account = AppwriteConfig.account;
      await account.createOAuth2Session(provider: provider, scopes: scopes);
      // Nach Redirect und erfolgreichem Session-Aufbau versuchen wir den User zu laden.
      _user = await account.get();
      _status = AuthStatus.authenticated;
      await _saveCachedUserFromUser();
      // mark that we successfully logged in at least once
      final prefs = await SharedPreferences.getInstance();
      _hasLoggedIn = true;
      await prefs.setBool(_kHasLoggedInKey, true);
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  /// Beendet die aktuelle Sitzung und räumt den Cache auf.
  Future<void> logout() async {
    if (_status == AuthStatus.loading) return;
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      await AppwriteConfig.account.deleteSession(sessionId: 'current');
      _user = null;
      _status = AuthStatus.unauthenticated;
      await _clearCachedUser();
    } catch (_) {
      _status = AuthStatus.unauthenticated; // Fallback
    } finally {
      notifyListeners();
    }
  }

  Future<void> _saveCachedUserFromUser() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    _cachedUserId = _user!.
        $id; // ignore: invalid_use_of_visible_for_testing_member
    _cachedEmail = _user!.email;
    await prefs.setString(_kCachedUserIdKey, _cachedUserId!);
    if (_cachedEmail != null) {
      await prefs.setString(_kCachedEmailKey, _cachedEmail!);
    }
    // ensure the "has logged in" flag is set as well
    _hasLoggedIn = true;
    await prefs.setBool(_kHasLoggedInKey, true);
  }

  Future<void> _clearCachedUser() async {
    _cachedUserId = null;
    _cachedEmail = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCachedUserIdKey);
    await prefs.remove(_kCachedEmailKey);
    _hasLoggedIn = false;
    await prefs.setBool(_kHasLoggedInKey, false);
  }

  /// Gibt zurück, ob der Nutzer sich jemals erfolgreich angemeldet hat.
  bool get hasLoggedIn => _hasLoggedIn;
}
