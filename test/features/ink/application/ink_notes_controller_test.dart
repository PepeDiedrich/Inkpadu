import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_auth.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_local_storage.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_repository.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_sync_service.dart';

Future<void> pumpEventQueue([int iterations = 5]) async {
  for (int i = 0; i < iterations; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class FakeInkNotesAuth extends ChangeNotifier implements InkNotesAuth {
  bool _loggedIn = false;
  String? _userId;
  String? _email;

  @override
  bool get isLoggedIn => _loggedIn;

  @override
  String? get userId => _userId;

  @override
  String? get email => _email;

  void setSession({String? userId, String? email}) {
    _userId = userId;
    _email = email;
    _loggedIn = userId != null;
    notifyListeners();
  }

}

class FakeInkNotesLocalStorage extends InkNotesLocalStorage {
  final Map<String, _StoredNote> _notes = <String, _StoredNote>{};
  final List<Map<String, Object?>> _queue = <Map<String, Object?>>[];
  int _queueAutoId = 0;

  @override
  Future<void> init() async {}

  @override
  Future<List<InkNote>> getAllNotes() async =>
      _notes.values.map((entry) => entry.note).toList(growable: false);

  @override
  Future<List<InkNote>> getPendingNotes() async => _notes.values
      .where((entry) => entry.status != LocalSyncStatus.synced)
      .map((entry) => entry.note)
      .toList(growable: false);

  @override
  Future<InkNote?> getNoteById(String id) async => _notes[id]?.note;

  @override
  Future<void> saveNote(
    InkNote note, {
    LocalSyncStatus status = LocalSyncStatus.pending,
    String? userId,
    Set<int>? changedPageIndices,
  }) async {
    _notes[note.id] = _StoredNote(note: note, status: status);
    if (status != LocalSyncStatus.synced) {
      await _enqueue(
        note.id,
        'UPSERT',
        changedPageIndices: changedPageIndices,
      );
    }
  }

  @override
  Future<void> saveNoteLocalOnly(InkNote note, {String? userId}) async {
    final stored = _notes[note.id];
    final LocalSyncStatus status = stored?.status ?? LocalSyncStatus.pending;
    _notes[note.id] = _StoredNote(note: note, status: status);
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.remove(id);
    await _enqueue(id, 'DELETE');
  }

  @override
  Future<void> markSynced(String id, {DateTime? remoteUpdatedAt}) async {
    final stored = _notes[id];
    if (stored != null) {
      _notes[id] = _StoredNote(note: stored.note, status: LocalSyncStatus.synced);
    }
    _queue.removeWhere((row) => row['note_id'] == id && row['operation'] == 'UPSERT');
  }

  @override
  Future<List<Map<String, Object?>>> fetchQueueItems({int limit = 100}) async =>
      _queue.take(limit).map((row) => Map<String, Object?>.from(row)).toList(growable: false);

  @override
  Future<void> deleteQueueItemById(int id) async {
    _queue.removeWhere((row) => row['id'] == id);
  }

  @override
  Future<void> updateQueueItem(int id, {int? retryCount, String? lastError}) async {
  final Map<String, Object?> row =
    _queue.firstWhere((element) => element['id'] == id, orElse: () => <String, Object?>{});
  if (row.isEmpty) {
      return;
    }
    if (retryCount != null) {
      row['retry_count'] = retryCount;
    }
    if (lastError != null) {
      row['last_error'] = lastError;
    }
  }

  @override
  Set<int>? extractChangedPages(Map<String, Object?> row) {
    final Object? direct = row['__pages'];
    if (direct is Set<int>) {
      return direct;
    }
    if (direct is Iterable) {
      return direct.map<int>((dynamic entry) => (entry as num).toInt()).toSet();
    }
    final Object? raw = row['changed_pages'];
    if (raw is Iterable) {
      return raw.map<int>((dynamic entry) => (entry as num).toInt()).toSet();
    }
    return null;
  }

  @override
  Future<void> clearQueueForNote(String noteId) async {
    _queue.removeWhere((row) => row['note_id'] == noteId);
  }

  Future<void> _enqueue(
    String noteId,
    String operation, {
    Set<int>? changedPageIndices,
  }) async {
    _queueAutoId += 1;
    _queue.add(<String, Object?>{
      'id': _queueAutoId,
      'note_id': noteId,
      'operation': operation,
      'retry_count': 0,
      'changed_pages': changedPageIndices?.toList(),
      '__pages': changedPageIndices?.toSet(),
    });
  }
}

class _StoredNote {
  const _StoredNote({required this.note, required this.status});

  final InkNote note;
  final LocalSyncStatus status;
}

class FakeInkNotesSync implements InkNotesSync {
  final Map<String, List<InkNote>> _fetchResponses = {};
  final Map<String, List<InkNote>> uploadedNotes = {};
  final Map<String, List<Set<int>?>> uploadedPageChanges = {};
  final Map<String, List<String>> deletedNotes = {};
  final Map<String, StreamController<InkNotesRemoteEvent>> _controllers = {};

  List<InkNote> defaultFetchResponse = const [];

  @override
  Future<List<InkNote>> fetchNotes(String userId) async =>
      _fetchResponses[userId] ?? defaultFetchResponse;

  @override
  Future<void> upsertNote(
    InkNote note,
    String userId, {
    Set<int>? changedPageIndices,
  }) async {
    final list = uploadedNotes.putIfAbsent(userId, () => <InkNote>[]);
    list.add(note);
    final changes = uploadedPageChanges.putIfAbsent(userId, () => <Set<int>?>[]);
    changes.add(
      changedPageIndices == null
          ? null
          : Set<int>.from(changedPageIndices),
    );
  }

  @override
  Future<void> deleteNote(String noteId, String userId) async {
    final list = deletedNotes.putIfAbsent(userId, () => <String>[]);
    list.add(noteId);
  }

  @override
  InkNotesRealtimeSubscription observeUserNotes({
    required String userId,
    required void Function(InkNotesRemoteEvent event) onEvent,
  }) {
    final controller =
        _controllers.putIfAbsent(userId, () => StreamController.broadcast());
    final subscription = controller.stream.listen(onEvent);
    return InkNotesRealtimeSubscription(null, subscription);
  }

  void setFetchResponse(String userId, List<InkNote> notes) {
    _fetchResponses[userId] = notes;
  }

  void emit(String userId, InkNotesRemoteEvent event) {
    final controller = _controllers[userId];
    controller?.add(event);
  }

  Future<void> dispose() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InkNotesController sync', () {
    late FakeInkNotesAuth auth;
    late FakeInkNotesSync sync;
    late FakeInkNotesLocalStorage localStorage;
    late InkNotesController controller;

    setUp(() {
      auth = FakeInkNotesAuth();
      sync = FakeInkNotesSync();
      localStorage = FakeInkNotesLocalStorage();
      controller = InkNotesController(
        repository: InkNotesRepository(localStorage: localStorage, syncService: sync),
        syncService: sync,
        auth: auth,
        debounceDuration: const Duration(milliseconds: 100),
        enableConnectivityMonitoring: false,
      );
    });

    tearDown(() async {
      controller.dispose();
      await sync.dispose();
    });

    test('lädt Appwrite-Notizen und lädt lokale Entwürfe hoch', () async {
      final offlineNote = InkNote.empty(title: 'Offline');
      controller.upsert(offlineNote);

      final remoteNote = InkNote(
        id: 'remote-1',
        title: 'Remote',
        updatedAt: offlineNote.updatedAt.add(const Duration(minutes: 10)),
        pages: offlineNote.pages,
        paperStyle: NotePaperStyle.grid,
      );
      sync.setFetchResponse('user-1', [remoteNote]);

      auth.setSession(userId: 'user-1', email: 'sync@example.com');
      await pumpEventQueue();

      expect(controller.notes.length, 2);
      expect(controller.notes.first.id, equals('remote-1'));
      final uploaded = sync.uploadedNotes['user-1'] ?? <InkNote>[];
      expect(uploaded.map((n) => n.id), contains(offlineNote.id));
    });

    test('reagiert auf Echtzeit-Updates', () async {
      auth.setSession(userId: 'user-42', email: 'user@inkpadu.app');
      await pumpEventQueue();

      final realtimeNote = InkNote(
        id: 'remote-live',
        title: 'Live',
        updatedAt: DateTime.now(),
        pages: InkNote.empty().pages,
        paperStyle: NotePaperStyle.plain,
      );

      sync.emit('user-42', InkNotesRemoteUpsert(realtimeNote));
      await pumpEventQueue();

      expect(controller.notes.map((n) => n.id), contains('remote-live'));
    });

    test('löscht Notiz und synchronisiert mit Backend', () async {
      auth.setSession(userId: 'user-99', email: 'delete@example.com');
      await pumpEventQueue();

      final note = InkNote.empty(title: 'Zu löschen');
      controller.upsert(note);
      await pumpEventQueue();

      expect(controller.notes.length, 1);

      controller.delete(note.id);
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(controller.notes.length, 0);
      final deleted = sync.deletedNotes['user-99'] ?? <String>[];
      expect(deleted, contains(note.id));
    });

    test('führt Seitenänderungen über Debounce zusammen', () async {
      auth.setSession(userId: 'user-merge', email: 'merge@example.com');
      await pumpEventQueue();

      final base = InkNote.empty(id: 'merge-note');
      controller.upsert(
        base.copyWith(updatedAt: DateTime.now()),
        changedPageIndices: {0},
      );
      controller.upsert(
        base.copyWith(updatedAt: DateTime.now().add(const Duration(milliseconds: 1))),
        changedPageIndices: const <int>{},
      );

      await Future<void>.delayed(const Duration(milliseconds: 200));

      final recorded = sync.uploadedPageChanges['user-merge'] ?? <Set<int>?>[];
      expect(recorded, isNotEmpty);
      expect(recorded.last, equals({0}));
    });

    test('Metadatenänderung synchronisiert ohne Seitenpayload', () async {
      auth.setSession(userId: 'user-meta', email: 'meta@example.com');
      await pumpEventQueue();

      final note = InkNote.empty(id: 'meta-note');
      controller.upsert(
        note.copyWith(title: 'Meta', updatedAt: DateTime.now()),
        changedPageIndices: const <int>{},
      );

      await Future<void>.delayed(const Duration(milliseconds: 200));

      final recorded = sync.uploadedPageChanges['user-meta'] ?? <Set<int>?>[];
      expect(recorded, isNotEmpty);
      expect(recorded.last, isEmpty);
    });
  });
}
