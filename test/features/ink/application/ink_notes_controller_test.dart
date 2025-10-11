import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_auth.dart';
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

class FakeInkNotesSync implements InkNotesSync {
  final Map<String, List<InkNote>> _fetchResponses = {};
  final Map<String, List<InkNote>> uploadedNotes = {};
  final Map<String, List<String>> deletedNotes = {};
  final Map<String, StreamController<InkNotesRemoteEvent>> _controllers = {};

  List<InkNote> defaultFetchResponse = const [];

  @override
  Future<List<InkNote>> fetchNotes(String userId) async =>
      _fetchResponses[userId] ?? defaultFetchResponse;

  @override
  Future<void> upsertNote(InkNote note, String userId) async {
    final list = uploadedNotes.putIfAbsent(userId, () => <InkNote>[]);
    list.add(note);
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
  group('InkNotesController sync', () {
    late FakeInkNotesAuth auth;
    late FakeInkNotesSync sync;
    late InkNotesController controller;

    setUp(() {
      auth = FakeInkNotesAuth();
      sync = FakeInkNotesSync();
      controller = InkNotesController(syncService: sync, auth: auth);
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
      await pumpEventQueue();

      expect(controller.notes.length, 0);
      final deleted = sync.deletedNotes['user-99'] ?? <String>[];
      expect(deleted, contains(note.id));
    });
  });
}
