/// Unterstützte Aktionen, die der Assistent auslösen kann.
enum AssistantRequestType {
  /// Liefert einen kurzen Hinweis ohne die Lösung zu verraten.
  tip,

  /// Generiert eine ausführliche Hilfestellung mit Erklärungen.
  help,

  /// Prüft die aktuelle Lösung auf Fehler oder bestätigt sie.
  review,

  /// Extrahiert Text aus einem PDF-Seitenbild ohne Interpretation.
  pdfExtract,
}
