import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/sync_queue_repository.dart';

void main() {
  group('SyncQueueRepository', () {
    late SyncQueueRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = SyncQueueRepository(prefs: prefs);
    });

    test('speichert und lädt Queue erfolgreich', () async {
      final note1 = InkNote.empty(title: 'Test Note 1');
      final note2 = InkNote.empty(title: 'Test Note 2');
      final notes = [note1, note2];

      await repository.saveQueue(notes);
      final loaded = await repository.loadQueue();

      expect(loaded.length, equals(2));
      expect(loaded[0].id, equals(note1.id));
      expect(loaded[0].title, equals('Test Note 1'));
      expect(loaded[1].id, equals(note2.id));
      expect(loaded[1].title, equals('Test Note 2'));
    });

    test('gibt leere Liste zurück wenn keine Queue gespeichert', () async {
      final loaded = await repository.loadQueue();
      expect(loaded, isEmpty);
    });

    test('löscht Queue erfolgreich', () async {
      final note = InkNote.empty(title: 'To Delete');
      await repository.saveQueue([note]);

      await repository.clearQueue();
      final loaded = await repository.loadQueue();

      expect(loaded, isEmpty);
    });

    test('speichert und lädt Delete-Queue erfolgreich', () async {
      final noteIds = ['note-1', 'note-2', 'note-3'];

      await repository.saveDeleteQueue(noteIds);
      final loaded = await repository.loadDeleteQueue();

      expect(loaded.length, equals(3));
      expect(loaded, containsAll(noteIds));
    });

    test('gibt leere Liste zurück wenn keine Delete-Queue gespeichert', () async {
      final loaded = await repository.loadDeleteQueue();
      expect(loaded, isEmpty);
    });

    test('löscht Delete-Queue erfolgreich', () async {
      await repository.saveDeleteQueue(['note-1', 'note-2']);

      await repository.clearDeleteQueue();
      final loaded = await repository.loadDeleteQueue();

      expect(loaded, isEmpty);
    });

    test('behält Notiz-Metadaten bei Persistierung', () async {
      final note = InkNote(
        id: 'custom-id',
        title: 'Custom Title',
        updatedAt: DateTime(2024, 1, 15, 10, 30),
        page: InkNote.empty().page,
        paperStyle: NotePaperStyle.grid,
      );

      await repository.saveQueue([note]);
      final loaded = await repository.loadQueue();

      expect(loaded.length, equals(1));
      final loadedNote = loaded[0];
      expect(loadedNote.id, equals('custom-id'));
      expect(loadedNote.title, equals('Custom Title'));
      expect(loadedNote.paperStyle, equals(NotePaperStyle.grid));
    });

    test('überschreibt alte Queue beim Speichern', () async {
      final note1 = InkNote.empty(title: 'First');
      await repository.saveQueue([note1]);

      final note2 = InkNote.empty(title: 'Second');
      await repository.saveQueue([note2]);

      final loaded = await repository.loadQueue();
      expect(loaded.length, equals(1));
      expect(loaded[0].title, equals('Second'));
    });
  });
}
