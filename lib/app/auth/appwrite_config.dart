import 'package:appwrite/appwrite.dart';

/// Zentraler Zugriff auf den Appwrite Client.
/// Fülle die Platzhalter `your-endpoint` und `your-project-id` aus oder
/// injiziere Werte über Umgebungs-Variablen / Build-Konstanten.
class AppwriteConfig {
  AppwriteConfig._();

  static final Client _client = Client()
    // TODO: Passe Endpoint & Projekt-ID an.
    ..setEndpoint('https://fra.cloud.appwrite.io/v1')
    ..setProject('68de6f340030cde53747');

  /// Gibt den global konfigurierten [Client] zurück.
  static Client get client => _client;

  /// Convenience Getter für [Account].
  static Account get account => Account(_client);
}
