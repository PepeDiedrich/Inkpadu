// Package library entrypoint für `inkpadu_llm_auth`.
// Appwrite importiert `package:inkpadu_llm_auth/main.dart` und erwartet eine
// top-level `main(context)` Funktion. Wir leiten hier zum tatsächlichen
// Implementierungs-Entrypoint aus dem Paket-Root weiter, ohne uns selbst zu
// referenzieren, um Rekursionen zu vermeiden.

import 'package:inkpadu_llm_auth/src/token_function.dart' as impl;

/// Einstiegspunkt für Appwrite-Funktionen.
Future<dynamic> main(dynamic context) => impl.handleRequest(context);
