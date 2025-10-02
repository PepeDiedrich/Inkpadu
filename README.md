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

Diese App integriert GitHub und Google OAuth2 Login über Appwrite.

### Schritte zur Konfiguration (GitHub & Google)
1. Projekt in Appwrite anlegen (Projekt-ID notieren) und Endpoint kennen.
2. In der Appwrite Console: Auth > Settings
	- GitHub aktivieren, Client ID & Secret (GitHub Developer Settings > OAuth Apps) hinterlegen.
	- Google aktivieren, Client ID & Secret (Google Cloud Console > Credentials > OAuth Client) hinterlegen.
3. Die von Appwrite angezeigten Redirect URLs jeweils in den Provider-Konfigurationen eintragen.
4. Android: In `android/app/src/main/AndroidManifest.xml` sicherstellen, dass `<data android:scheme="appwrite-callback-<PROJECT_ID>" />` zur Projekt-ID passt.
	*iOS / Web:* Appwrite generiert passende Callback URLs automatisch; stelle sicher, dass sie bei den Providern registriert sind.
5. `lib/app/auth/appwrite_config.dart` mit Endpoint & Projekt-ID anpassen.
6. (Optional) Scopes anpassen: In der Onboarding Page beim Aufruf von `loginWithProvider`.

### Nutzung
* Onboarding Seite: Buttons "Mit GitHub anmelden" und "Mit Google anmelden" starten jeweils den OAuth Flow.
* Nach Erfolg: automatische Navigation zur Hauptansicht.
* Einstellungen: "Abmelden" beendet die aktuelle Session.

### Scopes
* GitHub Standard in diesem Projekt: `['user:email']`
* Google Beispiel: `['email', 'profile']`
Scopes können pro Provider im Aufruf von `_handleLogin` (Onboarding) angepasst werden.

### Fehlerbehandlung
Bei Fehlschlag erscheint eine kurze Fehlermeldung unter den Buttons (z.B. `Login (Google) fehlgeschlagen`). Logs können über `flutter run -v` weiter analysiert werden.
