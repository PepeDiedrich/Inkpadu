import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:appwrite/enums.dart';
import 'package:flutter/foundation.dart';

import 'appwrite_config.dart';

enum AuthStatus { unknown, unauthenticated, authenticated, loading }

/// Verantwortlich für das Abrufen & Aktualisieren des Authentifizierungszustands.
class AuthController extends ChangeNotifier {
  AuthController();

  AuthStatus _status = AuthStatus.unknown;
  models.User? _user;

  AuthStatus get status => _status;
  models.User? get user => _user;

  bool get isLoggedIn => _status == AuthStatus.authenticated && _user != null;

  Future<void> initialize() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();
      final account = AppwriteConfig.account;
      _user = await account.get();
      _status = AuthStatus.authenticated;
    } on AppwriteException {
      _status = AuthStatus.unauthenticated;
      _user = null;
    } finally {
      notifyListeners();
    }
  }

  /// Startet den OAuth2 Flow (z.B. GitHub). Weitere Provider über Parameter.
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
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_status == AuthStatus.loading) return;
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      await AppwriteConfig.account.deleteSession(sessionId: 'current');
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated; // Fallback
    } finally {
      notifyListeners();
    }
  }
}
