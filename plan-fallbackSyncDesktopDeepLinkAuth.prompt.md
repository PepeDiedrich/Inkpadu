## Plan: Fallback Sync & Desktop Deep Link Auth

Add a desktop-friendly sync fallback (when Workmanager is absent) and switch desktop sign-in to a deep-link OAuth flow.

### Steps
1. Gate Workmanager init/registration in lib/main.dart to mobile-only; add a desktop/web flag that enables a foreground/timer-based sync path.
2. Implement a periodic foreground sync helper (connectivity-aware, runs syncAll + processQueueOnce) in lib/app/features/notes/application/ink_notes_controller.dart and wire it for desktop/web startup and app-resume.
3. Integrate deep-link OAuth for desktop using flutter_web_auth_2: launch provider URL, handle appwrite-callback-68de8b41001d59b1c2d0://auth return, and finalize session in lib/app/features/auth/application/auth_controller.dart; reuse existing onboarding triggers in lib/app/features/auth/presentation/onboarding/onboarding_page.dart.
4. Add platform URL scheme config for the callback on iOS/macOS/Linux/Windows (e.g., plist/desktop runner config) and document required Appwrite redirect entries in README.md.

### Further Considerations
1. Should desktop/web also expose a manual "Sync now" action for user-triggered retries?
No please do not fix the stuff for web i want all platforms except web to have this