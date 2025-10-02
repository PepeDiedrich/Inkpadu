import 'package:appwrite/appwrite.dart';

/// Zentraler Zugriff auf den Appwrite Client.
/// Fülle die Platzhalter `your-endpoint` und `your-project-id` aus oder
/// injiziere Werte über Umgebungs-Variablen / Build-Konstanten.
class AppwriteConfig {
  AppwriteConfig._();

  static final Client _client = Client()
    // TODO: Passe Endpoint & Projekt-ID an.
    ..setEndpoint('https://appwrite.nebulium.info/v1')
    ..setProject('68de8b41001d59b1c2d0');

  /// Gibt den global konfigurierten [Client] zurück.
  static Client get client => _client;

  /// Convenience Getter für [Account].
  static Account get account => Account(_client);
}
