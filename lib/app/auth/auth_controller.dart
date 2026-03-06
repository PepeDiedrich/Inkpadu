import 'dart:async';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:appwrite/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  /// Sichere Speicherung für sensible Daten (User ID, Email).
  final FlutterSecureStorage _secureStorage;

  /// Erstellt einen [AuthController].
  ///
  /// Erlaubt das Injizieren von [secureStorage] für Tests.
  AuthController({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

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

  bool get _isDesktop =>
      !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);

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
      _status == AuthStatus.authenticated &&
      (_user != null || _cachedUserId != null);

  /// Lädt den aktuellen Auth-Status inklusive gecachter Offline-Daten.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _hasLoggedIn = prefs.getBool(_kHasLoggedInKey) ?? false;

    // MIGRATION CHECK: Check if we have legacy insecure data
    // If we find data in SharedPreferences but NOT in SecureStorage, migrate it.
    final legacyId = prefs.getString(_kCachedUserIdKey);
    final legacyEmail = prefs.getString(_kCachedEmailKey);

    // Note: We check `containsKey` on secure storage to be safe, but simply reading is enough.
    // If we have legacy data, we want to ensure it's moved to secure storage.
    if (legacyId != null) {
      // Migrate to secure storage
      await _secureStorage.write(key: _kCachedUserIdKey, value: legacyId);
      if (legacyEmail != null) {
        await _secureStorage.write(key: _kCachedEmailKey, value: legacyEmail);
      }
      // Remove from insecure storage
      await prefs.remove(_kCachedUserIdKey);
      await prefs.remove(_kCachedEmailKey);
    }

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
      // READ FROM SECURE STORAGE
      final cachedId = await _secureStorage.read(key: _kCachedUserIdKey);
      final cachedEmail = await _secureStorage.read(key: _kCachedEmailKey);

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
  Future<void> loginWithProvider({
    required OAuthProvider provider,
    List<String>? scopes,
  }) async {
    if (_status == AuthStatus.loading) return;
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      final account = AppwriteConfig.account;
      if (_isDesktop) {
        final uri = _buildDesktopOAuthUrl(provider: provider, scopes: scopes);
        final callbackFuture = _listenForDesktopCallback();
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        final callback = await callbackFuture;
        if (kDebugMode) {
          final sanitizedCallback = callback.toString().replaceFirst(
            RegExp(r'secret=[^&]+'),
            'secret=***',
          );
          debugPrint('[Auth] OAuth callback: $sanitizedCallback');
        }
        final userId = callback.queryParameters['userId'];
        final secret = callback.queryParameters['secret'];
        if (userId == null || secret == null) {
          throw StateError('Missing OAuth token in callback');
        }
        if (kDebugMode) {
          debugPrint('[Auth] Creating session for userId=$userId');
        }
        try {
          await account.createSession(userId: userId, secret: secret);
        } catch (e, st) {
          if (kDebugMode) {
            debugPrint('[Auth] createSession failed: $e');
            debugPrint('[Auth] stack: $st');
          }
          rethrow;
        }
        // Nach Redirect und erfolgreichem Session-Aufbau versuchen wir den User zu laden.
        if (kDebugMode) {
          debugPrint('[Auth] Fetching user after session creation');
        }
        _user = await account.get();
      } else {
        // Wir lassen success und failure weg, damit das SDK die Standard-URLs generiert.
        // Das SDK baut intern eine URL wie: appwrite-callback-[PROJECT_ID]://localhost
        await account.createOAuth2Session(provider: provider, scopes: scopes);

        // Kurze Verzögerung, damit das SDK die Cookies speichern kann
        await Future<void>.delayed(const Duration(milliseconds: 5000));

        // Nach Redirect und erfolgreichem Session-Aufbau versuchen wir den User zu laden.
        _user = await account.get();
      }
      _status = AuthStatus.authenticated;
      await _saveCachedUserFromUser();
      // mark that we successfully logged in at least once
      final prefs = await SharedPreferences.getInstance();
      _hasLoggedIn = true;
      await prefs.setBool(_kHasLoggedInKey, true);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[Auth] loginWithProvider failed: $e');
        debugPrint('[Auth] stack: $st');
      }
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
    } catch (_) {
      // Ignore network errors during logout, but proceed to clear local data
    } finally {
      _user = null;
      _status = AuthStatus.unauthenticated;
      await _clearCachedUser();
      notifyListeners();
    }
  }

  Future<void> _saveCachedUserFromUser() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    _cachedUserId =
        _user!.$id; // ignore: invalid_use_of_visible_for_testing_member
    _cachedEmail = _user!.email;

    // WRITE TO SECURE STORAGE
    await _secureStorage.write(key: _kCachedUserIdKey, value: _cachedUserId!);
    if (_cachedEmail != null) {
      await _secureStorage.write(key: _kCachedEmailKey, value: _cachedEmail!);
    }

    // ensure the "has logged in" flag is set as well
    _hasLoggedIn = true;
    await prefs.setBool(_kHasLoggedInKey, true);
  }

  Future<void> _clearCachedUser() async {
    _cachedUserId = null;
    _cachedEmail = null;
    final prefs = await SharedPreferences.getInstance();

    // DELETE FROM SECURE STORAGE
    await _secureStorage.delete(key: _kCachedUserIdKey);
    await _secureStorage.delete(key: _kCachedEmailKey);

    // Also clear legacy keys from SharedPreferences just in case
    await prefs.remove(_kCachedUserIdKey);
    await prefs.remove(_kCachedEmailKey);

    _hasLoggedIn = false;
    await prefs.setBool(_kHasLoggedInKey, false);
  }

  /// Gibt zurück, ob der Nutzer sich jemals erfolgreich angemeldet hat.
  bool get hasLoggedIn => _hasLoggedIn;

  Future<Uri> _listenForDesktopCallback() async {
    final server = await HttpServer.bind(
      AppwriteConfig.callbackHost,
      AppwriteConfig.callbackPort,
    );
    final completer = Completer<Uri>();
    server.listen((HttpRequest request) async {
      final uri = request.uri;
      final isCallbackPath =
          uri.path == AppwriteConfig.callbackPath ||
          uri.path == '${AppwriteConfig.callbackPath}/';
      final hasTokens =
          uri.queryParameters.containsKey('userId') &&
          uri.queryParameters.containsKey('secret');
      if (kDebugMode) {
        final sanitizedQuery = uri.query.replaceFirst(
          RegExp(r'secret=[^&]+'),
          'secret=***',
        );
        debugPrint(
          '[Auth] Incoming redirect path=${uri.path} query=$sanitizedQuery tokens=$hasTokens',
        );
      }

      if (isCallbackPath && hasTokens && !completer.isCompleted) {
        completer.complete(uri);
        request.response.statusCode = 200;
        request.response.headers.contentType = ContentType.html;
        request.response.write(
          '<html><body><h2>Login abgeschlossen. Du kannst dieses Fenster schließen.</h2></body></html>',
        );
        await request.response.close();
        await server.close(force: true);
        return;
      }

      if (isCallbackPath && !hasTokens) {
        if (kDebugMode) {
          debugPrint('[Auth] Callback without tokens received');
        }
      }

      // Ignore noise like /favicon.ico; respond with 204.
      request.response.statusCode = 204;
      await request.response.close();
    });
    // Timeout fallback to avoid hanging indefinitely
    return completer.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () {
        server.close(force: true);
        throw TimeoutException('Login callback timed out');
      },
    );
  }

  Uri _buildDesktopOAuthUrl({
    required OAuthProvider provider,
    List<String>? scopes,
  }) {
    final endpoint = Uri.parse(AppwriteConfig.endpoint);
    final buffer = StringBuffer()
      ..write(
        endpoint.replace(
          path: '${endpoint.path}/account/tokens/oauth2/${provider.value}',
        ),
      );
    final baseParams = <String, String>{
      'project': AppwriteConfig.projectId,
      'success': AppwriteConfig.callbackUrl,
      'failure': AppwriteConfig.callbackUrl,
    };
    final params = <String>[];
    baseParams.forEach(
      (key, value) => params.add(
        '${Uri.encodeComponent(key)}=${Uri.encodeComponent(value)}',
      ),
    );
    if (scopes != null && scopes.isNotEmpty) {
      for (final scope in scopes) {
        params.add('scopes%5B%5D=${Uri.encodeComponent(scope)}');
      }
    }
    buffer.write('?${params.join('&')}');
    return Uri.parse(buffer.toString());
  }
}
