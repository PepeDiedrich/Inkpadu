import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_local_storage.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_repository.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_sync_service.dart';

class MockInkNotesLocalStorage extends Mock implements InkNotesLocalStorage {}

class MockInkNotesSync extends Mock implements InkNotesSync {}

void main() {
  late MockInkNotesLocalStorage mockLocalStorage;
  late MockInkNotesSync mockSyncService;
  late InkNotesRepository repository;

  setUpAll(() {
    registerFallbackValue(InkNote.empty());
    registerFallbackValue(LocalSyncStatus.pending);
  });

  setUp(() {
    mockLocalStorage = MockInkNotesLocalStorage();
    mockSyncService = MockInkNotesSync();

    // Default stubs
    when(() => mockLocalStorage.init()).thenAnswer((_) async {});
    when(() => mockLocalStorage.saveNote(
          any(),
          status: any(named: 'status'),
          userId: any(named: 'userId'),
          changedPageIndices: any(named: 'changedPageIndices'),
        )).thenAnswer((_) async {});
    when(() => mockLocalStorage.deleteNote(any())).thenAnswer((_) async {});
    when(() => mockLocalStorage.markSynced(any(), remoteUpdatedAt: any(named: 'remoteUpdatedAt')))
        .thenAnswer((_) async {});
  });

  group('InkNotesRepository', () {
    test('init calls localStorage.init', () async {
      repository = InkNotesRepository(
        localStorage: mockLocalStorage,
        syncService: mockSyncService,
      );
      await repository.init();
      verify(() => mockLocalStorage.init()).called(1);
    });

    test('getLocalNotes calls localStorage.getAllNotes', () async {
      repository = InkNotesRepository(
        localStorage: mockLocalStorage,
        syncService: mockSyncService,
      );
      final notes = [InkNote.empty()];
      when(() => mockLocalStorage.getAllNotes()).thenAnswer((_) async => notes);

      final result = await repository.getLocalNotes();

      expect(result, notes);
      verify(() => mockLocalStorage.getAllNotes()).called(1);
    });

    group('upsertNote', () {
      test('saves note locally and tries to sync', () async {
        repository = InkNotesRepository(
          localStorage: mockLocalStorage,
          syncService: mockSyncService,
        );
        final note = InkNote.empty();
        final userId = 'user1';

        when(() => mockSyncService.upsertNote(any(), any(), changedPageIndices: any(named: 'changedPageIndices')))
            .thenAnswer((_) async {});

        await repository.upsertNote(note, userId: userId);

        verify(() => mockLocalStorage.saveNote(
          note,
          userId: userId,
          changedPageIndices: any(named: 'changedPageIndices'),
        )).called(1);
        verify(() => mockSyncService.upsertNote(note, userId, changedPageIndices: any(named: 'changedPageIndices'))).called(1);
        verify(() => mockLocalStorage.markSynced(note.id, remoteUpdatedAt: any(named: 'remoteUpdatedAt'))).called(1);
      });

      test('swallows sync error but saves locally', () async {
        repository = InkNotesRepository(
          localStorage: mockLocalStorage,
          syncService: mockSyncService,
        );
        final note = InkNote.empty();
        final userId = 'user1';

        when(() => mockSyncService.upsertNote(any(), any(), changedPageIndices: any(named: 'changedPageIndices')))
            .thenThrow(Exception('Sync failed'));

        await repository.upsertNote(note, userId: userId);

        verify(() => mockLocalStorage.saveNote(
          note,
          userId: userId,
          changedPageIndices: any(named: 'changedPageIndices'),
        )).called(1);
        verify(() => mockSyncService.upsertNote(note, userId, changedPageIndices: any(named: 'changedPageIndices'))).called(1);
        // Should NOT mark as synced
        verifyNever(() => mockLocalStorage.markSynced(note.id, remoteUpdatedAt: any(named: 'remoteUpdatedAt')));
      });

      test('does not sync if syncService is null', () async {
         repository = InkNotesRepository(
          localStorage: mockLocalStorage,
          syncService: null,
        );
        final note = InkNote.empty();
        final userId = 'user1';

        await repository.upsertNote(note, userId: userId);

        verify(() => mockLocalStorage.saveNote(
          note,
          userId: userId,
          changedPageIndices: any(named: 'changedPageIndices'),
        )).called(1);
      });
    });

    group('deleteNote', () {
      test('deletes locally and tries to sync', () async {
        repository = InkNotesRepository(
          localStorage: mockLocalStorage,
          syncService: mockSyncService,
        );
        final noteId = '123';
        final userId = 'user1';

        when(() => mockSyncService.deleteNote(any(), any())).thenAnswer((_) async {});

        await repository.deleteNote(noteId, userId: userId);

        verify(() => mockLocalStorage.deleteNote(noteId)).called(1);
        verify(() => mockSyncService.deleteNote(noteId, userId)).called(1);
        verify(() => mockLocalStorage.markSynced(noteId)).called(1);
      });

      test('swallows sync error but deletes locally', () async {
        repository = InkNotesRepository(
          localStorage: mockLocalStorage,
          syncService: mockSyncService,
        );
        final noteId = '123';
        final userId = 'user1';

        when(() => mockSyncService.deleteNote(any(), any())).thenThrow(Exception('Sync failed'));

        await repository.deleteNote(noteId, userId: userId);

        verify(() => mockLocalStorage.deleteNote(noteId)).called(1);
        verify(() => mockSyncService.deleteNote(noteId, userId)).called(1);
        // Should NOT mark as synced (if exception thrown)
        verifyNever(() => mockLocalStorage.markSynced(noteId));
      });
    });

    group('processQueueOnce', () {
      test('processes UPSERT queue item', () async {
        repository = InkNotesRepository(
          localStorage: mockLocalStorage,
          syncService: mockSyncService,
        );
        final userId = 'user1';
        final noteId = 'note1';
        final queueItem = {
          'id': 1,
          'note_id': noteId,
          'operation': 'UPSERT',
          'retry_count': 0,
        };
        final note = InkNote.empty(id: noteId);

        when(() => mockLocalStorage.fetchQueueItems(limit: any(named: 'limit')))
            .thenAnswer((_) async => [queueItem]);
        when(() => mockLocalStorage.getNoteById(noteId)).thenAnswer((_) async => note);
        when(() => mockLocalStorage.extractChangedPages(any())).thenReturn(null);
        when(() => mockSyncService.upsertNote(any(), any(), changedPageIndices: any(named: 'changedPageIndices')))
            .thenAnswer((_) async {});
        when(() => mockLocalStorage.deleteQueueItemById(any())).thenAnswer((_) async {});

        await repository.processQueueOnce(userId: userId);

        verify(() => mockLocalStorage.fetchQueueItems(limit: any(named: 'limit'))).called(1);
        verify(() => mockSyncService.upsertNote(note, userId, changedPageIndices: any(named: 'changedPageIndices'))).called(1);
        verify(() => mockLocalStorage.markSynced(noteId, remoteUpdatedAt: any(named: 'remoteUpdatedAt'))).called(1);
        verify(() => mockLocalStorage.deleteQueueItemById(1)).called(1);
      });

      test('processes DELETE queue item', () async {
        repository = InkNotesRepository(
          localStorage: mockLocalStorage,
          syncService: mockSyncService,
        );
        final userId = 'user1';
        final noteId = 'note1';
        final queueItem = {
          'id': 1,
          'note_id': noteId,
          'operation': 'DELETE',
          'retry_count': 0,
        };

        when(() => mockLocalStorage.fetchQueueItems(limit: any(named: 'limit')))
            .thenAnswer((_) async => [queueItem]);
        when(() => mockSyncService.deleteNote(any(), any())).thenAnswer((_) async {});
        when(() => mockLocalStorage.deleteQueueItemById(any())).thenAnswer((_) async {});

        await repository.processQueueOnce(userId: userId);

        verify(() => mockLocalStorage.fetchQueueItems(limit: any(named: 'limit'))).called(1);
        verify(() => mockSyncService.deleteNote(noteId, userId)).called(1);
        verify(() => mockLocalStorage.deleteQueueItemById(1)).called(1);
      });

      test('handles errors by updating retry count', () async {
        repository = InkNotesRepository(
          localStorage: mockLocalStorage,
          syncService: mockSyncService,
        );
        final userId = 'user1';
        final noteId = 'note1';
        final queueItem = {
          'id': 1,
          'note_id': noteId,
          'operation': 'DELETE',
          'retry_count': 0,
        };

        when(() => mockLocalStorage.fetchQueueItems(limit: any(named: 'limit')))
            .thenAnswer((_) async => [queueItem]);
        when(() => mockSyncService.deleteNote(any(), any())).thenThrow(Exception('Fail'));
        when(() => mockLocalStorage.updateQueueItem(any(), retryCount: any(named: 'retryCount'), lastError: any(named: 'lastError')))
            .thenAnswer((_) async {});

        await repository.processQueueOnce(userId: userId);

        verify(() => mockSyncService.deleteNote(noteId, userId)).called(1);
        verifyNever(() => mockLocalStorage.deleteQueueItemById(1));
        verify(() => mockLocalStorage.updateQueueItem(1, retryCount: 1, lastError: any(named: 'lastError'))).called(1);
      });
    });
  });
}
