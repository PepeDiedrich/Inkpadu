import 'dart:async';

import 'package:workmanager/workmanager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_local_storage.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_repository.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_sync_service.dart';

/// Der Bezeichner für den Workmanager-Task zur Hintergrundsynchronisation.
const String backgroundSyncTask = 'inkpadu_background_sync';

/// Callback-Funktion für Workmanager, die Hintergrundsynchronisation der Notizen durchführt.
/// Diese Funktion wird von der Plattform aufgerufen, um ausstehende Synchronisationen zu verarbeiten.
/// Sie lädt gecachte Benutzerdaten, initialisiert das Repository und führt Synchronisation durch.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == backgroundSyncTask) {
      try {
        // [SENTINEL] Use SecureStorage to retrieve user ID (PII) instead of SharedPreferences
        // This also fixes a bug where background sync failed for migrated users.
        const secureStorage = FlutterSecureStorage();
        final cachedUserId = await secureStorage.read(
          key: 'inkpadu_cached_user_id',
        );
        if (cachedUserId == null) return Future.value(true);

        final localStorage = InkNotesLocalStorage();
        await localStorage.init();
        final syncService = InkNotesSyncService();
        final repository = InkNotesRepository(
          localStorage: localStorage,
          syncService: syncService,
        );

        // process pending queue items once
        await repository.processQueueOnce(userId: cachedUserId);
        // also try full sync
        await repository.syncAll(userId: cachedUserId);
      } catch (e) {
        // In background we should swallow errors and report success so platform can schedule again.
      }
    }
    return Future.value(true);
  });
}
