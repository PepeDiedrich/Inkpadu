import 'package:appwrite/appwrite.dart';

/// Zentraler Zugriff auf den Appwrite Client.
/// Fülle die Platzhalter `your-endpoint` und `your-project-id` aus oder
/// injiziere Werte über Umgebungs-Variablen / Build-Konstanten.
class AppwriteConfig {
  AppwriteConfig._();

  /// Globale Endpoint-URL für Appwrite.
  /// Must be supplied for a configured backend through
  /// --dart-define=APPWRITE_ENDPOINT=....
  static const String endpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: 'https://cloud.appwrite.io/v1',
  );

  /// Globale Projekt-ID für Appwrite.
  /// Must be supplied for a configured backend through
  /// --dart-define=APPWRITE_PROJECT_ID=....
  static const String projectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: 'your-project-id',
  );

  /// Appwrite Function responsible for the AI lasso workflow.
  static const String aiFunctionId = String.fromEnvironment(
    'APPWRITE_AI_FUNCTION_ID',
    defaultValue: 'your-ai-function-id',
  );

  /// Storage Bucket-ID für PDF-Hintergrunddateien.
  static const String pdfBucketId = 'note-pdfs';

  /// Callback-Scheme für OAuth-Redirects (http, damit ein lokaler Redirect-Server genutzt werden kann).
  static const String callbackScheme = 'http';

  /// Callback-Host; Appwrite akzeptiert `localhost` und `appwrite.nebulium.info`.
  static const String callbackHost = 'localhost';

  /// Fester Port für den lokalen Redirect.
  static const int callbackPort = 8350;

  /// Callback-Pfad für Desktop-Redirects.
  static const String callbackPath = '/auth-desktop';

  /// Vollständige Callback-URL für OAuth-Redirects auf Desktop.
  static const String callbackUrl =
      '$callbackScheme://$callbackHost:$callbackPort$callbackPath';

  static final Client _client = Client()
    ..setEndpoint(endpoint)
    ..setProject(projectId);

  /// Gibt den global konfigurierten [Client] zurück.
  static Client get client => _client;

  /// Convenience Getter für [Account].
  static Account get account => Account(_client);

  /// Convenience Getter für [Storage].
  static Storage get storage => Storage(_client);
}
