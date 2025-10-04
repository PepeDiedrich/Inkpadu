import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/sync_status.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_note_sync_queue.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_sync_service.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/sync_queue_repository.dart';

Future<void> pumpEventQueue([int iterations = 10]) async {
  for (int i = 0; i < iterations; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class FakeInkNotesSync implements InkNotesSync {
  final List<InkNote> uploadedNotes = [];
  final List<String> deletedNoteIds = [];
  bool shouldFail = false;
  int failCount = 0;

  @override
  Future<List<InkNote>> fetchNotes(String userId) async => const [];

  @override
  Future<void> upsertNote(InkNote note, String userId) async {
    if (shouldFail && failCount > 0) {
      failCount--;
      throw Exception('Network error');
    }
    uploadedNotes.add(note);
  }

  @override
  Future<void> deleteNote(String noteId, String userId) async {
    if (shouldFail && failCount > 0) {
      failCount--;
      throw Exception('Network error');
    }
    deletedNoteIds.add(noteId);
  }

  @override
  InkNotesRealtimeSubscription observeUserNotes({
    required String userId,
    required void Function(InkNotesRemoteEvent event) onEvent,
  }) {
    final controller = StreamController<InkNotesRemoteEvent>.broadcast();
    final subscription = controller.stream.listen(onEvent);
    return InkNotesRealtimeSubscription(null, subscription);
  }
}

class FakeConnectivity extends Connectivity {
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  void emitConnectivity(List<ConnectivityResult> results) {
    _controller.add(results);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  group('InkNoteSyncQueue', () {
    late FakeInkNotesSync syncService;
    late SyncQueueRepository repository;
    late FakeConnectivity connectivity;
    late InkNoteSyncQueue syncQueue;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      syncService = FakeInkNotesSync();
      repository = SyncQueueRepository(prefs: prefs);
      connectivity = FakeConnectivity();
      syncQueue = InkNoteSyncQueue(
        syncService: syncService,
        repository: repository,
        connectivity: connectivity,
        debounceDuration: const Duration(milliseconds: 50),
        periodicSyncInterval: const Duration(seconds: 60),
      );
    });

    tearDown(() async {
      await syncQueue.dispose();
      await connectivity.dispose();
    });

    test('enqueued note wird nach debounce synchronisiert', () async {
      syncQueue.setUserId('user-1');
      final note = InkNote.empty(title: 'Test Note');

      syncQueue.enqueueUpsert(note);
      expect(syncQueue.getStatus(note.id), equals(SyncStatus.pending));

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await pumpEventQueue();

      expect(syncService.uploadedNotes.length, equals(1));
      expect(syncService.uploadedNotes[0].id, equals(note.id));
      expect(syncQueue.getStatus(note.id), equals(SyncStatus.synced));
    });

    test('mehrfaches Enqueue resettet Debounce-Timer', () async {
      syncQueue.setUserId('user-1');
      final note1 = InkNote.empty(title: 'Note 1');
      final note2 = note1.copyWith(title: 'Note 1 Updated');

      syncQueue.enqueueUpsert(note1);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      
      syncQueue.enqueueUpsert(note2);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      
      // Sollte noch nicht synchronisiert sein
      expect(syncService.uploadedNotes, isEmpty);

      await Future<void>.delayed(const Duration(milliseconds: 40));
      await pumpEventQueue();

      // Jetzt sollte nur die letzte Version synchronisiert sein
      expect(syncService.uploadedNotes.length, equals(1));
      expect(syncService.uploadedNotes[0].title, equals('Note 1 Updated'));
    });

    test('Delete wird nach debounce synchronisiert', () async {
      syncQueue.setUserId('user-1');
      const noteId = 'note-to-delete';

      syncQueue.enqueueDelete(noteId);
      expect(syncQueue.getStatus(noteId), equals(SyncStatus.pending));

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await pumpEventQueue();

      expect(syncService.deletedNoteIds.length, equals(1));
      expect(syncService.deletedNoteIds[0], equals(noteId));
    });

    test('flush synchronisiert sofort ohne debounce', () async {
      syncQueue.setUserId('user-1');
      final note = InkNote.empty(title: 'Flush Note');

      syncQueue.enqueueUpsert(note);
      await syncQueue.flush();

      expect(syncService.uploadedNotes.length, equals(1));
      expect(syncService.uploadedNotes[0].id, equals(note.id));
    });

    test('Queue funktioniert ohne userId nicht', () async {
      final note = InkNote.empty(title: 'No User');

      syncQueue.enqueueUpsert(note);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await pumpEventQueue();

      expect(syncService.uploadedNotes, isEmpty);
    });

    test('Status-Stream benachrichtigt über Änderungen', () async {
      syncQueue.setUserId('user-1');
      final note = InkNote.empty(title: 'Status Test');

      final statuses = <SyncStatus>[];
      final subscription = syncQueue.statusStream.listen((statusMap) {
        final status = statusMap[note.id];
        if (status != null) {
          statuses.add(status);
        }
      });

      syncQueue.enqueueUpsert(note);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await pumpEventQueue();

      await subscription.cancel();

      expect(statuses, contains(SyncStatus.pending));
      expect(statuses, contains(SyncStatus.syncing));
      expect(statuses, contains(SyncStatus.synced));
    });

    test('Fehler beim Sync führt zu Retry mit Backoff', () async {
      syncService.shouldFail = true;
      syncService.failCount = 2;
      
      syncQueue.setUserId('user-1');
      final note = InkNote.empty(title: 'Retry Note');

      syncQueue.enqueueUpsert(note);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await pumpEventQueue();

      // Nach ersten Fehlversuch sollte es pending sein
      expect(syncQueue.getStatus(note.id), equals(SyncStatus.pending));

      // Warte auf Retry
      await Future<void>.delayed(const Duration(seconds: 3));
      await pumpEventQueue();

      // Nach erfolgreichem Retry sollte es synced sein
      expect(syncService.uploadedNotes.length, equals(1));
      expect(syncQueue.getStatus(note.id), equals(SyncStatus.synced));
    });

    test('Netzwerk-Wiederherstellung startet Queue-Verarbeitung', () async {
      syncQueue.setUserId('user-1');
      final note = InkNote.empty(title: 'Offline Note');

      // Simuliere Offline
      connectivity.emitConnectivity([ConnectivityResult.none]);
      await pumpEventQueue();

      syncQueue.enqueueUpsert(note);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await pumpEventQueue();

      expect(syncService.uploadedNotes, isEmpty);

      // Simuliere Online
      connectivity.emitConnectivity([ConnectivityResult.wifi]);
      await pumpEventQueue();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await pumpEventQueue();

      expect(syncService.uploadedNotes.length, equals(1));
    });

    test('Persistiert Queue in Repository', () async {
      final note = InkNote.empty(title: 'Persist Note');
      
      syncQueue.enqueueUpsert(note);
      await pumpEventQueue();

      final loaded = await repository.loadQueue();
      expect(loaded.length, equals(1));
      expect(loaded[0].id, equals(note.id));
    });

    test('Lädt Queue aus Repository beim Start', () async {
      final note = InkNote.empty(title: 'Preloaded Note');
      await repository.saveQueue([note]);

      final newSyncQueue = InkNoteSyncQueue(
        syncService: syncService,
        repository: repository,
        connectivity: connectivity,
        debounceDuration: const Duration(milliseconds: 50),
      );

      await pumpEventQueue();

      expect(newSyncQueue.getStatus(note.id), equals(SyncStatus.pending));

      await newSyncQueue.dispose();
    });

    test('Entfernt Note aus Queue nach erfolgreichem Sync', () async {
      syncQueue.setUserId('user-1');
      final note = InkNote.empty(title: 'Remove After Sync');

      syncQueue.enqueueUpsert(note);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await pumpEventQueue();

      final loaded = await repository.loadQueue();
      expect(loaded, isEmpty);
    });

    test('Status wechselt zu idle nach synced', () async {
      syncQueue.setUserId('user-1');
      final note = InkNote.empty(title: 'Idle Test');

      syncQueue.enqueueUpsert(note);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await pumpEventQueue();

      expect(syncQueue.getStatus(note.id), equals(SyncStatus.synced));

      await Future<void>.delayed(const Duration(milliseconds: 2100));
      await pumpEventQueue();

      expect(syncQueue.getStatus(note.id), equals(SyncStatus.idle));
    });
  });
}
