import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late InkNotesLocalStorage storage;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    storage = InkNotesLocalStorage();
    // Deleting the database to ensure a clean state
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/inkpadu_local.db'; // Hardcoded in InkNotesLocalStorage
    await deleteDatabase(path);
  });

  tearDown(() async {
    await storage.close();
  });

  final testNote = InkNote(
    id: 'test-note-1',
    title: 'Test Note',
    updatedAt: DateTime.now(),
    pages: [
      NotePage(strokes: []),
    ],
    paperStyle: NotePaperStyle.plain,
  );

  group('InkNotesLocalStorage', () {
    test('init creates tables', () async {
      await storage.init();
      // Verify tables exist by attempting a save operation which requires tables
      expect(storage.saveNote(testNote), completes);
    });

    group('CRUD Operations', () {
      test('saveNote and getNoteById', () async {
        await storage.saveNote(testNote);
        final retrieved = await storage.getNoteById(testNote.id);

        expect(retrieved, isNotNull);
        expect(retrieved!.id, testNote.id);
        expect(retrieved.title, testNote.title);
        expect(retrieved.paperStyle, testNote.paperStyle);
        expect(retrieved.pages.length, testNote.pages.length);
        // DateTimes might have slight precision differences due to storage
        expect(
          retrieved.updatedAt.millisecondsSinceEpoch,
          closeTo(testNote.updatedAt.millisecondsSinceEpoch, 1000),
        );
      });

      test('getAllNotes returns all saved notes', () async {
        final note2 = InkNote(
          id: 'test-note-2',
          title: 'Note 2',
          updatedAt: DateTime.now(),
          pages: [NotePage(strokes: [])],
          paperStyle: NotePaperStyle.lined,
        );

        await storage.saveNote(testNote);
        await storage.saveNote(note2);

        final allNotes = await storage.getAllNotes();
        expect(allNotes.length, 2);
        expect(allNotes.any((n) => n.id == testNote.id), true);
        expect(allNotes.any((n) => n.id == note2.id), true);
      });

      test('deleteNote removes note and adds to queue', () async {
        await storage.saveNote(testNote);
        await storage.deleteNote(testNote.id);

        final retrieved = await storage.getNoteById(testNote.id);
        expect(retrieved, isNull);

        final queueItems = await storage.fetchQueueItems();
        // Should have at least the DELETE operation.
        // Might also have UPSERT depending on previous tests state if not cleaned properly,
        // but setUp deletes DB so it should be clean.
        // Wait, saveNote adds UPSERT to queue if sync status != synced.
        // Default is pending. So we expect UPSERT then DELETE.

        final deleteOp = queueItems.firstWhere(
          (item) => item['note_id'] == testNote.id && item['operation'] == 'DELETE',
          orElse: () => {},
        );
        expect(deleteOp, isNotEmpty);
      });
    });

    group('Sync Logic', () {
      test('getPendingNotes returns only unsynced notes', () async {
        await storage.saveNote(testNote);

        final syncedNote = InkNote(
          id: 'synced-note',
          title: 'Synced',
          updatedAt: DateTime.now(),
          pages: [NotePage(strokes: [])],
          paperStyle: NotePaperStyle.plain,
        );
        await storage.saveNote(syncedNote, status: LocalSyncStatus.synced);

        final pending = await storage.getPendingNotes();
        expect(pending.length, 1);
        expect(pending.first.id, testNote.id);
      });

      test('markSynced updates status', () async {
        await storage.saveNote(testNote);
        await storage.markSynced(testNote.id);

        final pending = await storage.getPendingNotes();
        expect(pending.isEmpty, true);

        final retrieved = await storage.getNoteById(testNote.id);
        expect(retrieved, isNotNull);
      });
    });

    group('Queue Operations', () {
      test('fetchQueueItems retrieves items', () async {
        await storage.saveNote(testNote); // Adds UPSERT to queue
        final items = await storage.fetchQueueItems();
        expect(items.isNotEmpty, true);
        expect(items.first['note_id'], testNote.id);
        expect(items.first['operation'], 'UPSERT');
      });

      test('deleteQueueItemById removes item', () async {
        await storage.saveNote(testNote);
        final items = await storage.fetchQueueItems();
        final id = items.first['id'] as int;

        await storage.deleteQueueItemById(id);
        final newItems = await storage.fetchQueueItems();
        expect(newItems.any((i) => i['id'] == id), false);
      });

      test('updateQueueItem updates retry count and error', () async {
        await storage.saveNote(testNote);
        final items = await storage.fetchQueueItems();
        final id = items.first['id'] as int;

        await storage.updateQueueItem(id, retryCount: 5, lastError: 'Network Error');

        final updatedItems = await storage.fetchQueueItems();
        final updatedItem = updatedItems.firstWhere((i) => i['id'] == id);

        expect(updatedItem['retry_count'], 5);
        expect(updatedItem['last_error'], 'Network Error');
      });

      test('clearQueueForNote removes all items for a note', () async {
        await storage.saveNote(testNote); // UPSERT
        await storage.deleteNote(testNote.id); // DELETE

        final itemsBefore = await storage.fetchQueueItems();
        // Should contain UPSERT and DELETE
        expect(itemsBefore.where((i) => i['note_id'] == testNote.id).length, greaterThanOrEqualTo(2));

        await storage.clearQueueForNote(testNote.id);

        final itemsAfter = await storage.fetchQueueItems();
        expect(itemsAfter.where((i) => i['note_id'] == testNote.id).isEmpty, true);
      });
    });
  });
}
