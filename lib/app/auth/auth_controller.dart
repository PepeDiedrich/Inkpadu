import 'dart:async';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:appwrite/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
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

  bool get _isDesktop => !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);

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
      if (_isDesktop) {
        final uri = _buildDesktopOAuthUrl(provider: provider, scopes: scopes);
        final callbackFuture = _listenForDesktopCallback();
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        final callback = await callbackFuture;
        if (kDebugMode) {
          final sanitizedCallback = callback
              .toString()
              .replaceFirst(RegExp(r'secret=[^&]+'), 'secret=***');
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
        // Explicitly providing success/failure URLs to avoid "missing redirect url" errors
        // The scheme must match the one defined in AndroidManifest.xml
        final redirectUrl = 'appwrite-callback-${AppwriteConfig.projectId}://callback';
        await account.createOAuth2Session(
          provider: provider,
          scopes: scopes,
          success: redirectUrl,
          failure: redirectUrl,
        );
        // Nach Redirect und erfolgreichem Session-Aufbau versuchen wir den User zu laden.
        _user = await account.get();
      }
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

  Future<Uri> _listenForDesktopCallback() async {
    final server = await HttpServer.bind(AppwriteConfig.callbackHost, AppwriteConfig.callbackPort);
    final completer = Completer<Uri>();
    server.listen((HttpRequest request) async {
      final uri = request.uri;
      final isCallbackPath = uri.path == AppwriteConfig.callbackPath ||
          uri.path == '${AppwriteConfig.callbackPath}/';
      final hasTokens = uri.queryParameters.containsKey('userId') &&
          uri.queryParameters.containsKey('secret');
      if (kDebugMode) {
        final sanitizedQuery =
            uri.query.replaceFirst(RegExp(r'secret=[^&]+'), 'secret=***');
        debugPrint(
            '[Auth] Incoming redirect path=${uri.path} query=$sanitizedQuery tokens=$hasTokens');
      }

      if (isCallbackPath && hasTokens && !completer.isCompleted) {
        completer.complete(uri);
        request.response.statusCode = 200;
        request.response.headers.contentType = ContentType.html;
        request.response.write(
            '<html><body><h2>Login abgeschlossen. Du kannst dieses Fenster schließen.</h2></body></html>');
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
    return completer.future.timeout(const Duration(minutes: 3), onTimeout: () {
      server.close(force: true);
      throw TimeoutException('Login callback timed out');
    });
  }

  Uri _buildDesktopOAuthUrl({required OAuthProvider provider, List<String>? scopes}) {
    final endpoint = Uri.parse(AppwriteConfig.endpoint);
    final buffer = StringBuffer()
      ..write(endpoint.replace(path: '${endpoint.path}/account/tokens/oauth2/${provider.value}'));
    final baseParams = <String, String>{
      'project': AppwriteConfig.projectId,
      'success': AppwriteConfig.callbackUrl,
      'failure': AppwriteConfig.callbackUrl,
    };
    final params = <String>[];
    baseParams.forEach((key, value) => params.add('${Uri.encodeComponent(key)}=${Uri.encodeComponent(value)}'));
    if (scopes != null && scopes.isNotEmpty) {
      for (final scope in scopes) {
        params.add('scopes%5B%5D=${Uri.encodeComponent(scope)}');
      }
    }
    buffer.write('?${params.join('&')}');
    return Uri.parse(buffer.toString());
  }
}
