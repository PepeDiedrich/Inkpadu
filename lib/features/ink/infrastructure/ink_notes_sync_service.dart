import 'dart:async';

import 'package:appwrite/appwrite.dart';
// ignore: implementation_imports
import 'package:appwrite/src/enums.dart' show HttpMethod;
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
    /// Erstellt ein Realtime-Abonnement mit optionalem [RealtimeSubscription].
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

/// Service zur Synchronisation von handschriftlichen Notizen mit Appwrite Databases API.
/// Verwaltet das Laden, Speichern und Löschen von Notizen sowie Realtime-Updates.
/// Implementiert die [InkNotesSync] Schnittstelle für die Kommunikation mit Appwrite.
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

  /// Lädt und konvertiert alle Notizen für den angegebenen Nutzer aus Appwrite.
  @override
  Future<List<InkNote>> fetchNotes(String userId) async {
    final queries = <String>[
      Query.equal('user_id', userId),
      Query.orderDesc('updated_at'),
    ];

    try {
      final documents = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: queries,
      );
      return documents.documents
          .map((doc) => InkNoteDto.fromDocument(doc).toDomain())
          .toList(growable: false);
    } on TypeError catch (error, stackTrace) {
      // TypeError kommt z.B. wenn das SDK versucht, null in ein int zu casten
      debugPrint('Appwrite fetchNotes parsing error: $error');
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'InkNotesSyncService',
        informationCollector: () => <DiagnosticsNode>[
          DiagnosticsNode.message(
            'Fallback auf roh geladene Dokumente für user $userId aktiviert',
          ),
        ],
      ));

      return _fetchNotesWithRawDocuments(userId: userId, queries: queries);
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

  Future<List<InkNote>> _fetchNotesWithRawDocuments({
    required String userId,
    required List<String> queries,
  }) async {
    try {
      final response = await _databases.client.call(
        HttpMethod.get,
        path:
            '/databases/${Uri.encodeComponent(databaseId)}/collections/${Uri.encodeComponent(collectionId)}/documents',
        params: <String, dynamic>{'queries': queries},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        debugPrint('InkNotesSyncService: Unerwartetes Antwortformat ${data.runtimeType}');
        return const <InkNote>[];
      }

      final documents = data['documents'];
      if (documents is! List) {
        debugPrint('InkNotesSyncService: "documents" fehlt oder ist kein Listentyp.');
        return const <InkNote>[];
      }

      final notes = <InkNote>[];
      for (var index = 0; index < documents.length; index++) {
        final rawDoc = documents[index];
        if (rawDoc is! Map) {
          debugPrint('InkNotesSyncService: Dokument an Index $index ist kein Map und wird übersprungen.');
          continue;
        }

        final normalized = _normalizeRawDocument(
          rawDoc.map((key, value) => MapEntry(key.toString(), value)),
          index,
        );

        final note = _tryBuildInkNoteFromRaw(normalized);
        if (note != null) {
          notes.add(note);
        }
      }

      return notes.toList(growable: false);
    } on AppwriteException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('InkNotesSyncService: Fehler beim Rohabruf der Dokumente: $error');
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'InkNotesSyncService',
        informationCollector: () => <DiagnosticsNode>[
          DiagnosticsNode.message('Fehler beim Rohabruf der Dokumente für user $userId'),
        ],
      ));
      return const <InkNote>[];
    }
  }

  Map<String, dynamic> _normalizeRawDocument(
    Map<String, dynamic> doc,
    int fallbackSequence,
  ) {
    final normalized = Map<String, dynamic>.from(doc);

    normalized[r'$sequence'] = _resolveSequence(doc[r'$sequence'], fallbackSequence);

    final permissions = doc[r'$permissions'];
    if (permissions is List) {
      normalized[r'$permissions'] =
          permissions.whereType<String>().toList(growable: false);
    } else {
      normalized[r'$permissions'] = const <String>[];
    }

    normalized[r'$createdAt'] ??= DateTime.now().toUtc().toIso8601String();
    normalized[r'$updatedAt'] ??= normalized[r'$createdAt'];
    return normalized;
  }

  int _resolveSequence(Object? value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return fallback;
  }

  InkNote? _tryBuildInkNoteFromRaw(Map<String, dynamic> doc) {
    final id = doc[r'$id']?.toString();
    final userId = doc['user_id'];
    final title = doc['title'];
    final paperStyle = doc['paper_style'];
    final pageData = doc['page_data'];
    final updatedAtRaw = doc['updated_at'];

    if (id == null ||
        userId is! String ||
        title is! String ||
        paperStyle is! String ||
        pageData is! String ||
        updatedAtRaw is! String) {
      debugPrint(
        'InkNotesSyncService: Dokument ${doc[r'$id']} übersprungen (fehlende oder invalide Felder).',
      );
      return null;
    }

    final updatedAt = DateTime.tryParse(updatedAtRaw);
    if (updatedAt == null) {
      debugPrint('InkNotesSyncService: Dokument $id hat ungültiges Datum "$updatedAtRaw".');
      return null;
    }

    try {
      return InkNoteDto(
        id: id,
        userId: userId,
        title: title,
        paperStyle: paperStyle,
        pageData: pageData,
        updatedAt: updatedAt.toUtc(),
      ).toDomain();
    } catch (error, stackTrace) {
      debugPrint('InkNotesSyncService: Fehler beim Konvertieren von Dokument $id: $error');
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'InkNotesSyncService',
        informationCollector: () => <DiagnosticsNode>[
          DiagnosticsNode.message('Fehler beim Konvertieren des Rohdokuments $id'),
        ],
      ));
      return null;
    }
  }

  /// Speichert eine Notiz in Appwrite oder aktualisiert sie bei Bedarf.
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

  /// Entfernt eine Notiz aus Appwrite für den angegebenen Nutzer.
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

  /// Beobachtet Realtime-Events für einen Nutzer und meldet Änderungen.
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
