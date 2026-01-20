import 'package:flutter/foundation.dart';

import 'package:ai_handwriting_app/app/auth/auth_controller.dart';

/// Abstrakte Repräsentation des Authentifizierungszustands für die Notiz-Synchronisierung.
abstract class InkNotesAuth {
  /// Gibt `true` zurück, wenn ein Benutzer angemeldet ist.
  bool get isLoggedIn;

  /// Liefert die eindeutige Benutzer-ID oder `null`, wenn kein Benutzer angemeldet ist.
  String? get userId;

  /// Gibt die E-Mail-Adresse des angemeldeten Benutzers zurück.
  String? get email;

  /// Fügt einen Listener hinzu, der bei Zustandsänderungen aufgerufen wird.
  void addListener(VoidCallback listener);

  /// Entfernt einen zuvor hinzugefügten Listener.
  void removeListener(VoidCallback listener);
}

/// Adapter, der den [AuthController] auf die [InkNotesAuth]-Schnittstelle abbildet.
class AuthControllerInkNotesAuth implements InkNotesAuth {
  /// Erstellt einen Adapter für den übergebenen [AuthController].
  AuthControllerInkNotesAuth(this._authController);

  final AuthController _authController;

  @override
  bool get isLoggedIn => _authController.isLoggedIn;

  @override
  String? get userId => _authController.userId;

  @override
  String? get email => _authController.email;

  @override
  void addListener(VoidCallback listener) =>
      _authController.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _authController.removeListener(listener);
}
