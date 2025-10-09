// Package library entrypoint for `inkpadu_llm_auth`.
// Appwrite imports `package:inkpadu_llm_auth/main.dart` and expects a
// top-level `main(req, res)` function. This file provides a thin wrapper
// that forwards the call to the implementation at the package root.

import 'package:inkpadu_llm_auth/main.dart' as impl;

/// Forwards the Appwrite `main(context)` invocation to the implementation.
Future<dynamic> main(dynamic context) => impl.main(context);
