// Appwrite Dart Function: Fordert einen temporären Azure OAuth2-Token an
// und gibt ihn an den Client zurück. Die Azure-Credentials werden über
// Umgebungsvariablen bereitgestellt und NICHT im Code gespeichert.

import 'dart:async';
import 'package:inkpadu_llm_auth/src/token_function.dart' as impl;

/// Appwrite entrypoint
///
/// Erwartet die folgenden Umgebungsvariablen (in Appwrite Funktion setzen):
/// - AZURE_TENANT_ID
/// - AZURE_CLIENT_ID
/// - AZURE_CLIENT_SECRET
///
/// Sicherheit:
/// - Prüft, ob die Anfrage von einem angemeldeten Appwrite-User kommt
///   (Header: `x-appwrite-user-id`).
Future<dynamic> main(dynamic context) => impl.handleRequest(context);

