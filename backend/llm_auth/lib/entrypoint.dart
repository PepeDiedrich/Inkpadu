// Entrypoint library for the package. Appwrite's server looks for a
// top-level `main` symbol when importing the package. We re-expose the
// function here so consumers can import `package:inkpadu_llm_auth/main.dart`.

export '../main.dart' show main;
