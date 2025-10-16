import 'dart:async';
import 'dart:math' as math;

import 'package:appwrite/appwrite.dart';
// ignore: implementation_imports
import 'package:appwrite/src/enums.dart' show HttpMethod;
import 'package:flutter/foundation.dart';

import 'package:ai_handwriting_app/app/auth/appwrite_config.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_page_codec.dart';

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
  Future<void> upsertNote(
    InkNote note,
    String userId, {
    Set<int>? changedPageIndices,
  });

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
    Realtime? realtime,
    this.databaseId = 'inkpadu-db',
    this.collectionId = 'ink-notes',
    this.pagesCollectionId = 'ink-note-pages',
  })  : _client = client ?? AppwriteConfig.client,
        _realtime = realtime ?? Realtime(client ?? AppwriteConfig.client);
  final Client _client;
  final Realtime _realtime;

  /// Appwrite Datenbank-ID zur Speicherung der Notizen.
  final String databaseId;

  /// Appwrite Collection-ID innerhalb der Datenbank.
  final String collectionId;

  /// Appwrite Collection-ID für die einzelnen Notizseiten.
  final String pagesCollectionId;

  Uri _buildPath(String collection, {String? documentId}) {
    final collectionPath = '/databases/${Uri.encodeComponent(databaseId)}/collections/${Uri.encodeComponent(collection)}';
    if (documentId == null) {
      return Uri.parse('$collectionPath/documents');
    }
    return Uri.parse('$collectionPath/documents/${Uri.encodeComponent(documentId)}');
  }

  Future<Map<String, dynamic>> _call({
    required HttpMethod method,
    required Uri uri,
    Map<String, dynamic>? params,
  }) async {
    final response = await _client.call(
      method,
      path: uri.toString(),
      params: params ?? const <String, dynamic>{},
    );
    final raw = response.data;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _extractData(Map<String, dynamic> document) {
    final result = <String, dynamic>{};
    document.forEach((key, value) {
      if (!key.startsWith(r'$')) {
        result[key] = value;
      }
    });
    return result;
  }

  /// Lädt und konvertiert alle Notizen für den angegebenen Nutzer aus Appwrite.
  @override
  Future<List<InkNote>> fetchNotes(String userId) async {
    final queries = <String>[
      Query.equal('user_id', userId),
      Query.orderDesc('updated_at'),
      Query.limit(200),
    ];

    try {
      final response = await _call(
        method: HttpMethod.get,
        uri: _buildPath(collectionId),
        params: <String, dynamic>{
          if (queries.isNotEmpty) 'queries': queries,
        },
      );

      final documents = (response['documents'] as List?) ?? const <dynamic>[];
      final futures = documents.map(
        (dynamic raw) => _buildNoteFromDocument(
          Map<String, dynamic>.from(raw as Map),
          expectedUserId: userId,
        ),
      );
      final notes = await Future.wait<InkNote?>(futures);

      return notes.whereType<InkNote>().toList(growable: false);
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
    } catch (error, stackTrace) {
      debugPrint('InkNotesSyncService: unexpected error during fetchNotes: $error');
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'InkNotesSyncService',
        informationCollector: () => <DiagnosticsNode>[
          DiagnosticsNode.message('unexpected fetchNotes failure for user $userId'),
        ],
      ));
      return const <InkNote>[];
    }
  }

  int _resolveFlexiblePageIndex(
    Object? raw, {
    required int pagesLength,
    required int fallback,
  }) {
    int? value;
    if (raw is int) {
      value = raw;
    } else if (raw is num) {
      value = raw.toInt();
    } else if (raw is String) {
      value = int.tryParse(raw);
    }
    if (value == null) return fallback;
    // Erst 0-basiert (Bestand), dann 1-basiert (neu)
    if (pagesLength > 0 && value >= 0 && value < pagesLength) {
      return value;
    }
    if (pagesLength > 0 && value >= 1 && value <= pagesLength) {
      return value - 1; // 1-basiert -> 0-basiert
    }
    if (pagesLength <= 0) return 0;
    return value.clamp(0, pagesLength - 1).toInt();
  }

  /// Speichert eine Notiz in Appwrite oder aktualisiert sie bei Bedarf.
  @override
  Future<void> upsertNote(
    InkNote note,
    String userId, {
    Set<int>? changedPageIndices,
  }) async {
    final metadata = _buildMetadataPayload(note, userId);
    final permissions = _buildPermissions(userId);

    await _createOrUpdateDocument(
      collection: collectionId,
      documentId: note.id,
      data: metadata,
      permissions: permissions,
    );

    final Set<int> pagesToUpload = _resolvePagesToUpload(
      note,
      changedPageIndices,
    );

    for (final index in pagesToUpload) {
      final payload = _buildPagePayload(
        note: note,
        pageIndex: index,
        userId: userId,
      );
      await _createOrUpdateDocument(
        collection: pagesCollectionId,
        documentId: _pageDocumentId(note.id, index),
        data: payload,
        permissions: permissions,
      );
    }

    if (changedPageIndices == null) {
      await _deletePagesBeyond(note.id, note.pages.length);
    }
  }

  /// Entfernt eine Notiz aus Appwrite für den angegebenen Nutzer.
  @override
  Future<void> deleteNote(String noteId, String userId) async {
    await _deleteAllPages(noteId);
    try {
      await _call(
        method: HttpMethod.delete,
        uri: _buildPath(collectionId, documentId: noteId),
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
      'databases.$databaseId.collections.$pagesCollectionId.documents',
    ]);

    final listener = subscription.stream.listen((message) async {
      final payload = message.payload;
      final String? payloadUserId = payload['user_id'] as String?;
      if (payloadUserId != null && payloadUserId != userId) {
        return;
      }

      final bool isDelete = message.events.any(
        (event) => event.endsWith('.delete'),
      );
      final bool isPageEvent = message.events.any(
        (event) => event.contains('.collections.$pagesCollectionId.'),
      );

      final String? noteId = isPageEvent
          ? payload['note_id'] as String?
          : payload[r'$id'] as String?;

      if (noteId == null) {
        return;
      }

      if (isDelete && !isPageEvent) {
        onEvent(InkNotesRemoteDelete(noteId));
        return;
      }

      final InkNote? note = await _tryFetchNote(noteId, userId: userId);
      if (note != null) {
        onEvent(InkNotesRemoteUpsert(note));
      }
    });

    return InkNotesRealtimeSubscription(subscription, listener);
  }

  Future<InkNote?> _buildNoteFromDocument(
    Map<String, dynamic> rawDoc, {
    required String expectedUserId,
  }) async {
    try {
      final data = _extractData(rawDoc);
      final String? ownerId = data['user_id'] as String?;
      if (ownerId != expectedUserId) {
        return null;
      }

      final String title = (data['title'] as String?) ?? InkNote.generateTitle();
      final String? paperStyleRaw = data['paper_style'] as String?;
      final Object? lastOpenedRaw = data['last_opened_page'];
      final int pageCount = _parseInt(data['page_count']) ?? 1;
      final DateTime updatedAt = _parseDateTime(
        data['updated_at'],
        fallback: rawDoc[r'$updatedAt'],
      );

      final List<NotePage> pages = await _fetchPagesForNote(
        rawDoc[r'$id'] as String,
        expectedCount: pageCount,
      );

      final int lastOpenedIndex = _resolveFlexiblePageIndex(
        lastOpenedRaw,
        pagesLength: pages.length,
        fallback: 0,
      );

      return InkNote(
  id: rawDoc[r'$id'] as String,
        title: title,
        updatedAt: updatedAt.toLocal(),
        pages: pages.isEmpty
            ? List<NotePage>.unmodifiable(
                <NotePage>[NotePage(strokes: const <Stroke>[])],
              )
            : pages,
        lastOpenedPageIndex: pages.isEmpty ? 0 : lastOpenedIndex,
        paperStyle: _parsePaperStyle(paperStyleRaw),
      );
    } catch (error, stackTrace) {
      debugPrint('InkNotesSyncService: Failed to build note ${rawDoc[r'$id']}: $error');
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'InkNotesSyncService',
        informationCollector: () => <DiagnosticsNode>[
          DiagnosticsNode.message('Error while building note ${rawDoc[r'$id']}'),
        ],
      ));
      return null;
    }
  }

  Future<List<NotePage>> _fetchPagesForNote(
    String noteId, {
    required int expectedCount,
  }) async {
    final Map<int, NotePage> decodedPages = <int, NotePage>{};
    try {
      final response = await _call(
        method: HttpMethod.get,
        uri: _buildPath(pagesCollectionId),
        params: <String, dynamic>{
          'queries': <String>[
            Query.equal('note_id', noteId),
            Query.orderAsc('page_index'),
            Query.limit(500),
          ],
        },
      );

      final documents = (response['documents'] as List?) ?? const <dynamic>[];
      for (final dynamic raw in documents) {
        final map = Map<String, dynamic>.from(raw as Map);
        final data = _extractData(map);
        final int? index = _parseInt(data['page_index']);
        if (index == null || index < 0) {
          continue;
        }
        final String payload = data['payload'] as String? ?? '';
        decodedPages[index] = InkNotePageCodec.decodeSingle(payload);
      }
    } on AppwriteException catch (error, stackTrace) {
      debugPrint('InkNotesSyncService: Failed to fetch pages for $noteId: ${error.message}');
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'InkNotesSyncService',
        informationCollector: () => <DiagnosticsNode>[
          DiagnosticsNode.message('fetchPages failed for note $noteId'),
        ],
      ));
    } catch (error, stackTrace) {
      debugPrint('InkNotesSyncService: Unexpected error fetching pages for $noteId: $error');
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'InkNotesSyncService',
        informationCollector: () => <DiagnosticsNode>[
          DiagnosticsNode.message('unexpected fetchPages error for note $noteId'),
        ],
      ));
    }

    final int highestIndex = decodedPages.isEmpty
        ? -1
        : decodedPages.keys.reduce(math.max);
    final int targetLength = math.max(expectedCount, highestIndex + 1);
    final List<NotePage> pages = List<NotePage>.generate(
      math.max(targetLength, 1),
      (index) => decodedPages[index] ?? NotePage(strokes: const <Stroke>[]),
      growable: false,
    );

    return List<NotePage>.unmodifiable(pages);
  }

  Future<void> _createOrUpdateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    required List<String> permissions,
  }) async {
    try {
      await _call(
        method: HttpMethod.post,
        uri: _buildPath(collection),
        params: <String, dynamic>{
          'documentId': documentId,
          'data': data,
          'permissions': permissions,
        },
      );
    } on AppwriteException catch (error) {
      if (error.code == 409) {
        await _call(
          method: HttpMethod.patch,
          uri: _buildPath(collection, documentId: documentId),
          params: <String, dynamic>{
            'data': data,
            'permissions': permissions,
          },
        );
      } else {
        debugPrint('InkNotesSyncService: create/update failed for $documentId: ${error.message}');
        rethrow;
      }
    }
  }

  Map<String, dynamic> _buildMetadataPayload(InkNote note, String userId) {
    final DateTime updatedUtc = note.updatedAt.toUtc();
    return <String, dynamic>{
      'user_id': userId,
      'title': note.title,
      'paper_style': note.paperStyle.name,
      'page_count': note.pages.length,
      'last_opened_page': note.lastOpenedPageIndex + 1,
      'updated_at': updatedUtc.toIso8601String(),
      'created_at': updatedUtc.toIso8601String(),
    };
  }

  String _pageDocumentId(String noteId, int pageIndex) => '${noteId}_$pageIndex';

  Map<String, dynamic> _buildPagePayload({
    required InkNote note,
    required int pageIndex,
    required String userId,
  }) {
    final DateTime updatedUtc = note.updatedAt.toUtc();
    final NotePage page =
        (pageIndex >= 0 && pageIndex < note.pages.length)
            ? note.pages[pageIndex]
            : NotePage(strokes: const <Stroke>[]);
    return <String, dynamic>{
      'note_id': note.id,
      'user_id': userId,
      'page_index': pageIndex,
      'payload': InkNotePageCodec.encodeSingle(page),
      'updated_at': updatedUtc.toIso8601String(),
      'created_at': updatedUtc.toIso8601String(),
    };
  }

  List<String> _buildPermissions(String userId) => <String>[
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
        Permission.write(Role.user(userId)),
      ];

  Set<int> _resolvePagesToUpload(
    InkNote note,
    Set<int>? changedPageIndices,
  ) {
    if (note.pages.isEmpty) {
      return const <int>{};
    }
    if (changedPageIndices == null || changedPageIndices.isEmpty) {
      return Set<int>.from(
        Iterable<int>.generate(note.pages.length),
      );
    }

    return changedPageIndices
        .where((index) => index >= 0 && index < note.pages.length)
        .toSet();
  }

  Future<void> _deletePagesBeyond(String noteId, int pageCount) async {
    try {
      final response = await _call(
        method: HttpMethod.get,
        uri: _buildPath(pagesCollectionId),
        params: <String, dynamic>{
          'queries': <String>[
            Query.equal('note_id', noteId),
            Query.greaterThanEqual('page_index', pageCount),
            Query.limit(500),
          ],
        },
      );

      final documents = (response['documents'] as List?) ?? const <dynamic>[];
      for (final dynamic raw in documents) {
        final map = Map<String, dynamic>.from(raw as Map);
        final String? pageId = map[r'$id'] as String?;
        if (pageId == null) {
          continue;
        }
        await _call(
          method: HttpMethod.delete,
          uri: _buildPath(pagesCollectionId, documentId: pageId),
        );
      }
    } on AppwriteException catch (error) {
      if (error.code == 404) {
        return;
      }
      debugPrint('InkNotesSyncService: Failed to delete stale pages for $noteId: ${error.message}');
    }
  }

  Future<void> _deleteAllPages(String noteId) async {
    try {
      final response = await _call(
        method: HttpMethod.get,
        uri: _buildPath(pagesCollectionId),
        params: <String, dynamic>{
          'queries': <String>[
            Query.equal('note_id', noteId),
            Query.limit(500),
          ],
        },
      );

      final documents = (response['documents'] as List?) ?? const <dynamic>[];
      for (final dynamic raw in documents) {
        final map = Map<String, dynamic>.from(raw as Map);
        final String? pageId = map[r'$id'] as String?;
        if (pageId == null) {
          continue;
        }
        await _call(
          method: HttpMethod.delete,
          uri: _buildPath(pagesCollectionId, documentId: pageId),
        );
      }
    } catch (error) {
      // Falls einzelne Seiten bereits entfernt wurden, ignorieren wir dies.
    }
  }

  Future<InkNote?> _tryFetchNote(
    String noteId, {
    required String userId,
  }) async {
    try {
      final response = await _call(
        method: HttpMethod.get,
        uri: _buildPath(collectionId, documentId: noteId),
      );
      return _buildNoteFromDocument(
        Map<String, dynamic>.from(response),
        expectedUserId: userId,
      );
    } on AppwriteException catch (error) {
      if (error.code == 404) {
        return null;
      }
      debugPrint('InkNotesSyncService: Failed to fetch note $noteId: ${error.message}');
      return null;
    }
  }

  int? _parseInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  DateTime _parseDateTime(Object? value, {Object? fallback}) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed.toUtc();
      }
    } else if (value is DateTime) {
      return value.toUtc();
    }

    if (fallback is String) {
      final parsed = DateTime.tryParse(fallback);
      if (parsed != null) {
        return parsed.toUtc();
      }
    } else if (fallback is DateTime) {
      return fallback.toUtc();
    }

    return DateTime.now().toUtc();
  }

  NotePaperStyle _parsePaperStyle(String? raw) {
    if (raw == null) {
      return NotePaperStyle.plain;
    }
    try {
      return NotePaperStyle.values.byName(raw);
    } catch (_) {
      return NotePaperStyle.plain;
    }
  }
}
