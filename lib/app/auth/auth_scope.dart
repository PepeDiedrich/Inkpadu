import 'package:flutter/widgets.dart';

import 'auth_controller.dart';

/// Stellt den [AuthController] niedrigschwellig im Widget-Baum bereit.
class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({super.key, required AuthController controller, required Widget child})
      : super(notifier: controller, child: child);

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
  bool updateShouldNotify(covariant AuthScope oldWidget) => notifier != oldWidget.notifier;
}
