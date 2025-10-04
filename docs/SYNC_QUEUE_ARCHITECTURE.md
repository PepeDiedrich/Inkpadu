# Sync Queue Architecture

## Übersicht

Die Sync Queue ist eine zentrale Komponente, die die Synchronisation von Notizen zwischen dem lokalen Gerät und dem Appwrite-Backend verwaltet. Sie implementiert fortgeschrittene Features wie Debouncing, Retry-Logik mit exponential backoff, Offline-Queue mit lokaler Persistenz und automatische Netzwerk-Erkennung.

## Architektur

```
DrawingNoteController
    ↓
InkNotesController
    ↓
InkNoteSyncQueue (NEU)
    ↓ (mit Retry)
InkNotesSyncService
    ↓
Appwrite Backend
```

## Komponenten

### 1. SyncStatus (`lib/features/ink/domain/sync_status.dart`)

Ein Enum zur Darstellung des Sync-Status einer Notiz:

- `idle` - Notiz ist synchronisiert, keine ausstehenden Änderungen
- `pending` - Notiz wartet auf Synchronisation (debounce-Phase)
- `syncing` - Notiz wird gerade synchronisiert
- `synced` - Notiz wurde erfolgreich synchronisiert
- `error` - Fehler beim Synchronisieren

### 2. SyncQueueRepository (`lib/features/ink/infrastructure/sync_queue_repository.dart`)

Verwaltet die lokale Persistenz der Offline-Queue mit SharedPreferences:

- **saveQueue/loadQueue**: Speichert/lädt ausstehende Notizen
- **saveDeleteQueue/loadDeleteQueue**: Speichert/lädt zu löschende Notiz-IDs
- **clearQueue/clearDeleteQueue**: Löscht gespeicherte Queues

### 3. InkNoteSyncQueue (`lib/features/ink/infrastructure/ink_note_sync_queue.dart`)

Zentrale Komponente mit folgenden Features:

#### Debouncing
- Standardverzögerung: 2 Sekunden (konfigurierbar)
- Bei neuer Änderung: Timer wird zurückgesetzt
- Bei dispose/Seite verlassen: Sofort syncen via `flush()`

#### Retry-Logik
- Exponential Backoff: 1s → 2s → 4s → 8s → 16s
- Max. Versuche: 5
- Bei Network-Error: In Offline-Queue verschieben
- Bei Auth-Error (401, 403): Keine Retries

#### Offline-Queue
- Speichert Notizen lokal bei Sync-Fehler
- Lädt Queue bei App-Start automatisch
- Versucht periodisch zu syncen (alle 30s)
- Entfernt Notizen nach erfolgreichem Sync

#### Connectivity-Check
- Beobachtet Netzwerk-Status via `connectivity_plus`
- Startet Queue-Verarbeitung automatisch bei Verbindung
- Unterstützt alle Connectivity-Typen (WiFi, Mobile, Ethernet, etc.)

### 4. InkNotesController (Angepasst)

Integration der SyncQueue:
- Ersetzt direkte Sync-Calls durch `enqueueUpsert()` und `enqueueDelete()`
- Setzt User-ID bei Auth-Änderungen
- Disposed Queue ordnungsgemäß

### 5. UI-Komponenten

#### SyncStatusIndicator (`lib/features/ink/presentation/widgets/sync_status_indicator.dart`)

Widget zur Anzeige des Sync-Status:
- ⏰ Pending (Orange): Wartet auf Sync
- ⏳ Syncing (Blau): Wird synchronisiert
- ✓ Synced (Grün): Erfolgreich synchronisiert
- ⚠️ Error (Rot): Synchronisationsfehler

Wird in der DrawingNotePage neben dem Notiz-Titel angezeigt.

## Verwendung

### Initialisierung

In `main.dart`:

```dart
final syncQueue = InkNoteSyncQueue(syncService: notesSyncService);
final notesController = InkNotesController(
  syncService: notesSyncService,
  auth: authBridge,
  syncQueue: syncQueue,
);
```

### Zugriff auf Sync-Status

```dart
final notesController = InkNotesScope.of(context);
final syncQueue = notesController.syncQueue;

// Status abrufen
final status = syncQueue?.getStatus(noteId);

// Status-Stream beobachten
syncQueue?.statusStream.listen((statuses) {
  final status = statuses[noteId];
  // UI aktualisieren
});
```

### Manuelles Flush

```dart
// Vor dispose oder bei kritischen Operationen
await syncQueue.flush();
```

## Konfiguration

### Debounce-Dauer anpassen

```dart
InkNoteSyncQueue(
  syncService: notesSyncService,
  debounceDuration: Duration(seconds: 3), // Standard: 2s
);
```

### Periodic-Sync-Intervall anpassen

```dart
InkNoteSyncQueue(
  syncService: notesSyncService,
  periodicSyncInterval: Duration(seconds: 60), // Standard: 30s
);
```

## Testing

Umfassende Tests befinden sich in:
- `test/features/ink/infrastructure/sync_queue_repository_test.dart`
- `test/features/ink/infrastructure/ink_note_sync_queue_test.dart`

### Test-Coverage

- ✅ Debouncing-Logik
- ✅ Retry mit Exponential Backoff
- ✅ Offline-Queue Persistenz
- ✅ Connectivity-Monitoring
- ✅ Status-Tracking und Stream-Updates
- ✅ Queue-Verarbeitung und Flush

## Vorteile

1. **Bessere UX**: Sofortiges Feedback, keine blockierenden Sync-Operationen
2. **Zuverlässigkeit**: Automatische Retries und Offline-Unterstützung
3. **Performance**: Debouncing verhindert unnötige Netzwerk-Anfragen
4. **Transparenz**: Nutzer sehen immer den aktuellen Sync-Status
5. **Robustheit**: Fehlerbehandlung und automatische Wiederherstellung

## Zukünftige Erweiterungen

- Konflikte-Auflösung bei gleichzeitigen Änderungen
- Prioritäts-Queue für wichtige Notizen
- Batch-Sync für mehrere Notizen gleichzeitig
- Optimistische UI-Updates mit Rollback
- Detaillierte Fehler-Logs und Analytics
