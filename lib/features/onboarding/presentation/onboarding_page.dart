import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/app/router/app_routes.dart';
import 'package:ai_handwriting_app/app/theme/app_colors.dart';

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
                    child: const Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Willkommen bei Inkpadu',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.lightText,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Skizziere Ideen, schreibe Notizen und organisiere deine Gedanken mit natürlicher Handschrift.',
                              style: TextStyle(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dein digitales Notizbuch',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Eine handschriftliche Erfahrung, optimiert für Kreativität und Fokus – ganz ohne Ablenkung.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _openShell(context),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Los geht’s'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: () => _openShell(context),
                            child: const Text('Überspringen'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

void _openShell(BuildContext context) {
  Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
}
