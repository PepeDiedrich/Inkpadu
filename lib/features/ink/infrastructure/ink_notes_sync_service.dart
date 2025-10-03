import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/app/auth/appwrite_config.dart';

import 'package:ai_handwriting_app/features/ink/infrastructure/ink_note_dto.dart';

/// Result of a realtime sync event from Appwrite for ink notes.
sealed class InkNotesRemoteEvent {
  const InkNotesRemoteEvent();
}

/// Represents a create or update action coming from Appwrite Realtime.
class InkNotesRemoteUpsert extends InkNotesRemoteEvent {
  /// Erstellt ein Upsert-Ereignis für die angegebene [note].
  const InkNotesRemoteUpsert(this.note);

  /// Die Notiz, die erstellt oder aktualisiert wurde.
  final InkNote note;
}

/// Represents a delete action coming from Appwrite Realtime.
class InkNotesRemoteDelete extends InkNotesRemoteEvent {
  /// Erstellt ein Lösch-Ereignis für die Notiz mit [noteId].
  const InkNotesRemoteDelete(this.noteId);

  /// Die ID der gelöschten Notiz.
  final String noteId;
}

/// Wrapper around the Appwrite realtime subscription to ensure clean disposal.
class InkNotesRealtimeSubscription {
  InkNotesRealtimeSubscription(this._subscription, this._listener);

  final RealtimeSubscription? _subscription;
  final StreamSubscription<dynamic> _listener;

  /// Beendet das Realtime-Abonnement und gibt Ressourcen frei.
  Future<void> cancel() async {
    await _listener.cancel();
    _subscription?.close();
  }
}

/// Abstrakte Schnittstelle zum Synchronisieren von Notizen.
abstract class InkNotesSync {
  /// Lädt alle Notizen für einen bestimmten [userId] aus dem Backend.
  Future<List<InkNote>> fetchNotes(String userId);

  /// Erstellt oder aktualisiert eine [note] für den gegebenen [userId].
  Future<void> upsertNote(InkNote note, String userId);

  /// Löscht die Notiz mit [noteId] für den gegebenen [userId].
  Future<void> deleteNote(String noteId, String userId);

  /// Abonniert Realtime-Events für die Notizen eines Nutzers.
  InkNotesRealtimeSubscription observeUserNotes({
    required String userId,
    required void Function(InkNotesRemoteEvent event) onEvent,
  });
}

/// Handles communication with the Appwrite Databases API for syncing ink notes.
class InkNotesSyncService implements InkNotesSync {
  /// Erstellt einen neuen Service zum Synchronisieren mit Appwrite.
  InkNotesSyncService({
    Client? client,
    Databases? databases,
    Realtime? realtime,
    this.databaseId = 'inkpadu-db',
    this.collectionId = 'ink-notes',
  })  : _databases = databases ?? Databases(client ?? AppwriteConfig.client),
        _realtime = realtime ?? Realtime(client ?? AppwriteConfig.client);
  final Databases _databases;
  final Realtime _realtime;

  /// Appwrite Datenbank-ID zur Speicherung der Notizen.
  final String databaseId;

  /// Appwrite Collection-ID innerhalb der Datenbank.
  final String collectionId;

  @override
  Future<List<InkNote>> fetchNotes(String userId) async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.orderDesc('updated_at'),
        ],
      );
      return documents.documents
          .map((doc) => InkNoteDto.fromDocument(doc).toDomain())
          .toList(growable: false);
    } on AppwriteException catch (error, stackTrace) {
      debugPrint('Appwrite fetchNotes failed: ${error.message}');
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'InkNotesSyncService',
        informationCollector: () => <DiagnosticsNode>[
          DiagnosticsNode.message('fetchNotes for user $userId failed'),
        ],
      ));
      rethrow;
    }
  }

  @override
  Future<void> upsertNote(InkNote note, String userId) async {
    final dto = InkNoteDto.fromDomain(note, userId: userId);
    final data = dto.toMap();
    final permissions = [
      Permission.read(Role.user(userId)),
      Permission.update(Role.user(userId)),
      Permission.delete(Role.user(userId)),
      Permission.write(Role.user(userId)),
    ];

    try {
      await _databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: note.id,
        data: data,
        permissions: permissions,
      );
    } on AppwriteException catch (error) {
      if (error.code == 409) {
        await _databases.updateDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: note.id,
          data: data,
          permissions: permissions,
        );
      } else {
        debugPrint('Appwrite upsertNote failed: ${error.message}');
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteNote(String noteId, String userId) async {
    try {
      await _databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: noteId,
      );
    } on AppwriteException catch (error) {
      if (error.code == 404) {
        return;
      }
      debugPrint('Appwrite deleteNote failed: ${error.message}');
      rethrow;
    }
  }

  @override
  InkNotesRealtimeSubscription observeUserNotes({
    required String userId,
    required void Function(InkNotesRemoteEvent event) onEvent,
  }) {
    final subscription = _realtime.subscribe([
      'databases.$databaseId.collections.$collectionId.documents',
    ]);

    final listener = subscription.stream.listen((message) {
      if (message.payload['user_id'] != userId) {
        return;
      }

      final events = message.events;
      final isDelete = events.any((event) => event.endsWith('.delete'));

      if (isDelete) {
        final noteId = message.payload[r'$id'] as String;
        onEvent(InkNotesRemoteDelete(noteId));
        return;
      }

      final dto = InkNoteDto.fromPayload(message.payload);
      onEvent(InkNotesRemoteUpsert(dto.toDomain()));
    });

    return InkNotesRealtimeSubscription(subscription, listener);
  }
}
