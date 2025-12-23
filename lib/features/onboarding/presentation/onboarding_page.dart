import 'package:flutter/material.dart';
import 'package:appwrite/enums.dart';

import 'package:ai_handwriting_app/app/router/app_routes.dart';
import 'package:ai_handwriting_app/app/theme/app_colors.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Static onboarding screen that introduces the handwriting experience.
class OnboardingPage extends StatelessWidget {
  /// Creates a new [OnboardingPage].
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      AppColors.secondaryAccent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t.onboarding.welcome,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.t.onboarding.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t.onboarding.digitalNotebook,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.t.onboarding.digitalNotebookDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    _ActionRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActionRow extends StatefulWidget {
  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _loading = false;
  String? _error;

  Future<void> _handleLogin({
    required AuthController auth,
    required OAuthProvider provider,
    required List<String> scopes,
    required String label,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await auth.loginWithProvider(provider: provider, scopes: scopes);
      if (mounted && auth.status == AuthStatus.authenticated) {
        _openShell(context);
      }
    } catch (e) {
      setState(() => _error = context.t.errors.loginFailed(provider: label));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return Column(
      children: [
        if (_error != null) ...[
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.code),
                onPressed: _loading
                    ? null
                    : () => _handleLogin(
                        auth: auth,
                        provider: OAuthProvider.github,
                        scopes: const ['user:email'],
                        label: 'GitHub',
                      ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                label: Text(
                  _loading
                      ? context.t.onboarding.connecting
                      : context.t.onboarding.loginWithGitHub,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.g_mobiledata),
                onPressed: _loading
                    ? null
                    : () => _handleLogin(
                        auth: auth,
                        provider: OAuthProvider.google,
                        scopes: const ['email', 'profile'],
                        label: 'Google',
                      ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                label: Text(
                  _loading
                      ? context.t.onboarding.connecting
                      : context.t.onboarding.loginWithGoogle,
                ),
              ),
            ),
            // Note: "Überspringen" button intentionally removed. User must sign in.
          ],
        ),
      ],
    );
  }
}

void _openShell(BuildContext context) {
  Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
}
