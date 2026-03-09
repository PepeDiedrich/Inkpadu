import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_sync_service.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_auth.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';

import '../../helpers/sqflite_test_util.dart';

class FakeSync implements InkNotesSync {
  final List<InkNote> upserts = [];
  final List<String> deletes = [];

  @override
  Future<List<InkNote>> fetchNotes(String userId) async => [];

  @override
  Future<void> deleteNote(String noteId, String userId) async {
    deletes.add(noteId);
  }

  @override
  Future<void> upsertNote(
    InkNote note,
    String userId, {
    Set<int>? changedPageIndices,
  }) async {
    upserts.add(note);
  }

  @override
  InkNotesRealtimeSubscription observeUserNotes({
    required String userId,
    required void Function(InkNotesRemoteEvent event) onEvent,
  }) {
    final sc = StreamController<dynamic>();
    return InkNotesRealtimeSubscription(null, sc.stream.listen((_) {}));
  }
}

class FakeAuth implements InkNotesAuth {
  final String uid;
  final String mail;
  final List<VoidCallback> _listeners = <VoidCallback>[];
  FakeAuth({required this.uid, required this.mail});

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
    listener();
  }

  @override
  String? get email => mail;

  @override
  String? get userId => uid;

  @override
  bool get isLoggedIn => true;

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ensureTestDatabaseFactory();
  });

  setUp(() async {
    await resetTestDatabase();
  });

  tearDownAll(() async {
    await disposeTestDatabase();
  });

  test('debounces rapid upserts to keep the latest payload', () async {
    final sync = FakeSync();
    final auth = FakeAuth(uid: 'user-1', mail: 'u@x.test');

    // We'll use a short debounce duration to make the test fast.
    final controller = InkNotesController(
      syncService: sync,
      auth: auth,
      debounceDuration: const Duration(milliseconds: 200),
      enableConnectivityMonitoring: false,
    );

    final note = InkNote.empty(id: 'n1');

    // Rapid updates
    controller.upsert(note.copyWith(title: 'a', updatedAt: DateTime.now()));
    controller.upsert(
      note.copyWith(
        title: 'b',
        updatedAt: DateTime.now().add(const Duration(milliseconds: 1)),
      ),
    );
    controller.upsert(
      note.copyWith(
        title: 'c',
        updatedAt: DateTime.now().add(const Duration(milliseconds: 2)),
      ),
    );

    // Warte länger als debounceDuration
    await Future<void>.delayed(const Duration(milliseconds: 350));

    // Stelle sicher, dass das letzte Remote-Update den finalen Stand enthält
    expect(sync.upserts, isNotEmpty);
    expect(sync.upserts.last.title, 'c');

    controller.dispose();
  });

  test('delete is cancelled by subsequent upsert for same id', () async {
    final sync = FakeSync();
    final auth = FakeAuth(uid: 'user-1', mail: 'u@x.test');

    final controller = InkNotesController(
      syncService: sync,
      auth: auth,
      debounceDuration: const Duration(milliseconds: 200),
      enableConnectivityMonitoring: false,
    );

    final note = InkNote.empty(id: 'n2');

    controller.delete('n2');
    // Immediately recreate/update the same note
    controller.upsert(
      note.copyWith(title: 'restored', updatedAt: DateTime.now()),
    );

    await Future<void>.delayed(const Duration(milliseconds: 350));

    // deleteNote should NOT be called because upsert happened before debounce elapsed
    expect(sync.deletes, isEmpty);
    expect(sync.upserts, isNotEmpty);
    expect(sync.upserts.last.title, 'restored');

    controller.dispose();
  });
}
