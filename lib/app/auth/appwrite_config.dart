import 'package:appwrite/appwrite.dart';

/// Zentraler Zugriff auf den Appwrite Client.
/// Fülle die Platzhalter `your-endpoint` und `your-project-id` aus oder
/// injiziere Werte über Umgebungs-Variablen / Build-Konstanten.
class AppwriteConfig {
  AppwriteConfig._();

  /// Globale Endpoint-URL für Appwrite.
  /// Standardwert ist der Prod-Endpoint, kann via --dart-define=APPWRITE_ENDPOINT=... überschrieben werden.
  static const String endpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: 'https://appwrite.nebulium.info/v1',
  );

  /// Globale Projekt-ID für Appwrite.
  /// Standardwert ist die Prod-ID, kann via --dart-define=APPWRITE_PROJECT_ID=... überschrieben werden.
  static const String projectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: '68de8b41001d59b1c2d0',
  );

  /// Callback-Scheme für OAuth-Redirects (http, damit ein lokaler Redirect-Server genutzt werden kann).
  static const String callbackScheme = 'http';

  /// Callback-Host; Appwrite akzeptiert `localhost` und `appwrite.nebulium.info`.
  static const String callbackHost = 'localhost';

  /// Fester Port für den lokalen Redirect.
  static const int callbackPort = 8350;

  /// Callback-Pfad für Desktop-Redirects.
  static const String callbackPath = '/auth-desktop';

  /// Vollständige Callback-URL für OAuth-Redirects auf Desktop.
  static const String callbackUrl = '$callbackScheme://$callbackHost:$callbackPort$callbackPath';

  static final Client _client = Client()
    ..setEndpoint(endpoint)
    ..setProject(projectId);

  /// Gibt den global konfigurierten [Client] zurück.
  static Client get client => _client;

  /// Convenience Getter für [Account].
  static Account get account => Account(_client);
}
