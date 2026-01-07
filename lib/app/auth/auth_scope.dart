import 'package:flutter/widgets.dart';

import 'package:ai_handwriting_app/app/auth/auth_controller.dart';

/// Stellt den [AuthController] niedrigschwellig im Widget-Baum bereit.
class AuthScope extends InheritedNotifier<AuthController> {
  /// Erstellt einen neuen [AuthScope] mit dem gegebenen Controller und Child.
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Gibt den [AuthController] aus dem nächsten [AuthScope] im Kontext zurück.
  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found in context');
    return scope!.notifier!;
  }

  /// Gibt den [AuthController] zurück oder `null`, falls kein Scope verfügbar ist.
  static AuthController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    return scope?.notifier;
  }

  @override
  bool updateShouldNotify(covariant AuthScope oldWidget) =>
      notifier != oldWidget.notifier;
}
