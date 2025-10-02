# ai_handwriting_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## OAuth2 / Appwrite Anmeldung

Diese App integriert einen GitHub OAuth2 Login über Appwrite.

### Schritte zur Konfiguration
1. Erstelle in deiner Appwrite Instanz ein Projekt und notiere dir die Projekt-ID.
2. Aktiviere im Appwrite Console unter Auth > Settings den gewünschten Provider (z.B. GitHub) und trage Client ID / Secret ein.
3. Kopiere die vorgeschlagene Redirect URL aus dem Appwrite Modal in die Provider Developer-Einstellungen.
4. Ersetze im `AndroidManifest.xml` im `<data android:scheme="appwrite-callback-<PROJECT_ID>" />` Tag `<PROJECT_ID>` durch deine echte Projekt-ID.
5. Passe in `lib/app/auth/appwrite_config.dart` Endpoint (`https://<REGION>.cloud.appwrite.io/v1`) und Projekt-ID an.

### Nutzung
* Onboarding Seite: Button "Mit GitHub anmelden" startet OAuth Flow.
* Nach Erfolg automatische Navigation zur Hauptansicht.
* Einstellungen: "Abmelden" Eintrag beendet die aktuelle Session.

### Scopes
Scopes können in `loginWithProvider` angepasst werden (Standard: `['user:email']`).
