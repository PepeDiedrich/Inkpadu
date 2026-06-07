import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:inkpadu/features/ink/infrastructure/ink_notes_local_storage.dart';
import 'package:inkpadu/features/ink/infrastructure/ink_notes_repository.dart';
import 'package:inkpadu/features/ink/infrastructure/ink_notes_sync_service.dart';

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
        // We log in debug mode to facilitate diagnosis.
        if (kDebugMode) {
          debugPrint(
            '[BackgroundSync] Error: $e',
          );
        }
      }
    }
    return Future.value(true);
  });
}
