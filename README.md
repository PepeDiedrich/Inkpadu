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

## KI-Assistent

* Antworten werden jetzt live gestreamt, sobald das Azure OpenAI Deployment Tokens liefert. Während der Übertragung siehst du den wachsenden Text direkt im Panel.
* Mathematische Ausgaben sollten als LaTeX (`$…$` oder `$$…$$`) formatiert werden. Der Client rendert sie mit `flutter_math_fork` und sorgt so für deutlich bessere Lesbarkeit komplexer Formeln.
* Nutzer:innen interagieren ausschließlich über die Buttons **Tipp**, **Hilfe** und **Überprüfen**. Frei eingegebene Fragen sind deaktiviert. Jeder Button sendet eine passende Anweisung an das LLM (z. B. nur Hinweise, ausführliche Erklärungen oder eine Korrekturprüfung).
* Debug-Infos (Payload, Token-Schätzung, Snapshots) bleiben weiterhin im Debug-Modus verfügbar und aktualisieren sich auch während eines Streams.

## OAuth2 / Appwrite Anmeldung

Diese App integriert GitHub und Google OAuth2 Login über Appwrite.

### Schritte zur Konfiguration (GitHub & Google)
1. Projekt in Appwrite anlegen (Projekt-ID notieren) und Endpoint kennen.
2. In der Appwrite Console: Auth > Settings
	- GitHub aktivieren, Client ID & Secret (GitHub Developer Settings > OAuth Apps) hinterlegen.
	- Google aktivieren, Client ID & Secret (Google Cloud Console > Credentials > OAuth Client) hinterlegen.
3. Die von Appwrite angezeigten Redirect URLs jeweils in den Provider-Konfigurationen eintragen.
4. Android: In `android/app/src/main/AndroidManifest.xml` sicherstellen, dass `<data android:scheme="appwrite-callback-<PROJECT_ID>" />` zur Projekt-ID passt.
	*iOS / macOS / Desktop:* Verwende die Callback-URL `http://localhost:8350/auth-desktop` (Host `localhost` ist von Appwrite erlaubt). Web wird nicht unterstützt.
5. `lib/app/auth/appwrite_config.dart` mit Endpoint & Projekt-ID anpassen.
6. (Optional) Scopes anpassen: In der Onboarding Page beim Aufruf von `loginWithProvider`.

### Desktop-Login (Linux/Windows/macOS)
* OAuth startet über den Default-Browser via `flutter_web_auth_2` und kommt über `http://localhost:8350/auth-desktop` zurück.
* Stelle sicher, dass dieses Redirect in der Appwrite Console für GitHub und Google hinterlegt ist (Host `localhost` ist erlaubt; Port 8350 muss mit der App übereinstimmen).

### Hintergrundsynchronisation
* Mobile (Android/iOS): Workmanager-Task `inkpadu_periodic_sync` läuft alle 15 Minuten.
* Desktop (Linux/Windows/macOS): Fallback-Foreground-Sync läuft im aktiven App-Fenster alle 5 Minuten.

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

## Ink-Datenformat & Synchronisation

* Handschriftliche Seiten werden jetzt platzsparend serialisiert, bevor sie lokal oder in Appwrite gespeichert werden.
* Der erste Punkt eines Strichs wird in Ganzzahlen (Skalierung ×1000) gespeichert, alle weiteren Punkte nutzen Delta-Kodierung.
* Negative Deltas werden per ZigZag kodiert und als VarInts geschrieben, ehe der komplette Stream gzip-komprimiert und Base64-kodiert wird.
* Strich-Metadaten (Farbe, Basisbreite, Marker-Flag) bleiben lesbar in JSON erhalten, lediglich die Punktliste liegt komprimiert vor.
* Beim Dekodieren akzeptiert der Codec weiterhin alte JSON-Strukturen – hilfreich für Altdaten oder Debug Dumps.
* Die Appwrite-Collection `ink-notes` enthält aktuell keine produktiven Dokumente; neue Einträge werden automatisch im neuen Format abgelegt.
