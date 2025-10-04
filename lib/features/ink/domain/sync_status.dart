/// Status einer Notiz im Synchronisations-Prozess.
///
/// Wird verwendet, um UI-Feedback über den Sync-Zustand zu geben.
enum SyncStatus {
  /// Notiz ist synchronisiert und es gibt keine ausstehenden Änderungen.
  idle,

  /// Notiz wartet auf Synchronisation (debounce-Phase).
  pending,

  /// Notiz wird gerade synchronisiert.
  syncing,

  /// Notiz wurde erfolgreich synchronisiert.
  synced,

  /// Fehler beim Synchronisieren der Notiz.
  error,
}
