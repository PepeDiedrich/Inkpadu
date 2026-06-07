import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:inkpadu/features/ink/domain/ink_note.dart';
import 'package:inkpadu/features/ink/infrastructure/ink_note_dto.dart';
import 'package:inkpadu/features/ink/infrastructure/ink_page_codec.dart';

/// Enum für den lokalen Synchronisationsstatus einer Notiz.
enum LocalSyncStatus {
  /// Notiz ist synchronisiert.
  synced,
  /// Notiz wartet auf Synchronisation.
  pending,
  /// Notiz wird gerade synchronisiert.
  syncing,
  /// Konflikt bei der Synchronisation.
  conflict,
  /// Fehler bei der Synchronisation.
  error
}

/// Lokaler Speicher für handschriftliche Notizen mit SQLite-Datenbank.
class InkNotesLocalStorage {
  static const _dbName = 'inkpadu_local.db';
  static const _dbVersion = 5;

  static const _notesTable = 'ink_notes';
  static const _queueTable = 'sync_queue';

  Database? _db;

  /// Initialisiert die Datenbank, falls noch nicht geschehen.
  Future<void> init() async {
    if (_db != null) return;
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_notesTable (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            title TEXT NOT NULL,
            paper_style TEXT NOT NULL,
            page_data TEXT NOT NULL,
            last_opened_page INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL,
            sync_status TEXT NOT NULL,
            remote_updated_at INTEGER,
            created_at INTEGER NOT NULL,
            parent_id TEXT,
            pdf_background_path TEXT,
            pdf_file_id TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE $_queueTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            note_id TEXT NOT NULL,
            operation TEXT NOT NULL,
            retry_count INTEGER DEFAULT 0,
            last_error TEXT,
            changed_pages TEXT,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  /// Schließt die Datenbankverbindung.
  Future<void> close() async => await _db?.close();

  /// Gibt alle Notizen aus der lokalen Datenbank zurück.
  Future<List<InkNote>> getAllNotes() async {
    await init();
    final rows = await _db!.query(_notesTable, orderBy: 'updated_at DESC');
    return rows.map(_rowToInkNote).whereType<InkNote>().toList(growable: false);
  }

  /// Gibt alle Notizen zurück, die noch nicht synchronisiert sind.
  Future<List<InkNote>> getPendingNotes() async {
    await init();
    final rows = await _db!.query(
      _notesTable,
      where: 'sync_status != ?',
      whereArgs: [LocalSyncStatus.synced.name],
      orderBy: 'updated_at DESC',
    );
    return rows.map(_rowToInkNote).whereType<InkNote>().toList(growable: false);
  }

  /// Gibt die Notiz mit der gegebenen ID zurück, falls vorhanden.
  Future<InkNote?> getNoteById(String id) async {
    await init();
    final rows = await _db!.query(_notesTable, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _rowToInkNote(rows.first);
  }

  /// Speichert eine Notiz lokal und markiert sie für Synchronisation.
  Future<void> saveNote(
    InkNote note, {
    LocalSyncStatus status = LocalSyncStatus.pending,
    String? userId,
    Set<int>? changedPageIndices,
  }) async {
    await init();
    final dto = InkNoteDto.fromDomain(note, userId: userId ?? '');
    final createdAt = (dto.createdAt ?? dto.updatedAt).toUtc().millisecondsSinceEpoch;
    final map = <String, Object?>{
      'id': dto.id,
      'user_id': dto.userId,
      'title': dto.title,
      'paper_style': dto.paperStyle,
      'page_data': dto.pageData,
      'last_opened_page': dto.lastOpenedPageIndex,
      'updated_at': dto.updatedAt.toUtc().millisecondsSinceEpoch,
      'sync_status': status.name,
      'remote_updated_at': null,
      'created_at': createdAt,
      'pdf_background_path': note.pdfBackgroundPath,
      'pdf_file_id': note.pdfFileId,
    };

    await _db!.insert(_notesTable, map, conflictAlgorithm: ConflictAlgorithm.replace);
    // Enqueue sync operation nur, wenn die Notiz noch synchronisiert werden muss.
    if (status != LocalSyncStatus.synced) {
      await _enqueue(
        note.id,
        'UPSERT',
        changedPageIndices: changedPageIndices,
      );
    }
  }

  /// Speichert eine Notiz lokal ohne einen Queue-Eintrag zu erzeugen.
  /// Nützlich für sofortige Persistenz (z. B. beim Verlassen der Seite),
  /// während der eigentliche Remote-Sync separat getaktet wird.
  Future<void> saveNoteLocalOnly(InkNote note, {String? userId}) async {
    await init();
    final dto = InkNoteDto.fromDomain(note, userId: userId ?? '');
    final createdAt = (dto.createdAt ?? dto.updatedAt).toUtc().millisecondsSinceEpoch;
    final map = <String, Object?>{
      'id': dto.id,
      'user_id': dto.userId,
      'title': dto.title,
      'paper_style': dto.paperStyle,
      'page_data': dto.pageData,
      'last_opened_page': dto.lastOpenedPageIndex,
      'updated_at': dto.updatedAt.toUtc().millisecondsSinceEpoch,
      'sync_status': LocalSyncStatus.pending.name,
      'remote_updated_at': null,
      'created_at': createdAt,
      'pdf_background_path': note.pdfBackgroundPath,
      'pdf_file_id': note.pdfFileId,
    };
    await _db!.insert(_notesTable, map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Löscht eine Notiz lokal und markiert sie für Synchronisation.
  Future<void> deleteNote(String id) async {
    await init();
    await _db!.delete(_notesTable, where: 'id = ?', whereArgs: [id]);
    await _enqueue(id, 'DELETE');
  }

  /// Markiert eine Notiz als synchronisiert.
  Future<void> markSynced(String id, {DateTime? remoteUpdatedAt}) async {
    await init();
    final values = <String, Object?>{
      'sync_status': LocalSyncStatus.synced.name,
    };
    if (remoteUpdatedAt != null) {
      values['remote_updated_at'] = remoteUpdatedAt.toUtc().millisecondsSinceEpoch;
    }
    await _db!.update(_notesTable, values, where: 'id = ?', whereArgs: [id]);
  }

  InkNote? _rowToInkNote(Map<String, Object?> row) {
    try {
      final id = row['id'] as String?;
      final title = row['title'] as String? ?? '';
      final paperStyle = row['paper_style'] as String? ?? 'plain';
      final pageData = row['page_data'] as String? ?? '';
      final updatedAtMs = row['updated_at'] as int? ?? 0;
      final lastOpenedPageRaw = row['last_opened_page'];

      final updatedAt = DateTime.fromMillisecondsSinceEpoch(updatedAtMs).toLocal();
      final createdAtMs = row['created_at'] as int?;
      final createdAt = createdAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(createdAtMs, isUtc: true);

      final bundle = InkNotePageCodec.decode(pageData);
      final lastOpenedPageIndex = _resolveFlexiblePageIndex(
        lastOpenedPageRaw,
        pagesLength: bundle.pages.length,
        fallback: bundle.lastOpenedPageIndex,
      );

      final dto = InkNoteDto(
        id: id ?? '',
        userId: row['user_id'] as String? ?? '',
        title: title,
        paperStyle: paperStyle,
        pageData: pageData,
        lastOpenedPageIndex: lastOpenedPageIndex,
        pages: bundle.pages,
        updatedAt: updatedAt.toUtc(),
        createdAt: createdAt,
        pdfBackgroundPath: row['pdf_background_path'] as String?,
        pdfFileId: row['pdf_file_id'] as String?,
      );
      return dto.toDomain();
    } catch (e) {
      return null;
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

  Future<void> _enqueue(
    String noteId,
    String operation, {
    Set<int>? changedPageIndices,
  }) async {
    await init();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _db!.insert(_queueTable, {
      'note_id': noteId,
      'operation': operation,
      'changed_pages': changedPageIndices == null
          ? null
          : jsonEncode(changedPageIndices.toList()..sort()),
      'created_at': now,
    });
  }

  /// Gibt die nächsten Queue-Items für die Synchronisation zurück.
  Future<List<Map<String, Object?>>> fetchQueueItems({int limit = 100}) async {
    await init();
    final rows = await _db!.query(_queueTable, orderBy: 'created_at ASC', limit: limit);
    return rows;
  }

  /// Löscht ein Queue-Item anhand seiner ID.
  Future<void> deleteQueueItemById(int id) async {
    await init();
    await _db!.delete(_queueTable, where: 'id = ?', whereArgs: [id]);
  }

  /// Aktualisiert ein Queue-Item mit neuen Werten.
  Future<void> updateQueueItem(int id, {int? retryCount, String? lastError}) async {
    await init();
    final Map<String, Object?> values = {};
    if (retryCount != null) values['retry_count'] = retryCount;
    if (lastError != null) values['last_error'] = lastError;
    if (values.isNotEmpty) {
      await _db!.update(_queueTable, values, where: 'id = ?', whereArgs: [id]);
    }
  }

  /// Löscht alle Queue-Items für eine bestimmte Notiz.
  Future<void> clearQueueForNote(String noteId) async {
    await init();
    await _db!.delete(_queueTable, where: 'note_id = ?', whereArgs: [noteId]);
  }

  /// Extrahiert ggf. gespeicherte geänderte Seitenindizes aus einem Queue-Eintrag.
  Set<int>? extractChangedPages(Map<String, Object?> row) {
    final Object? raw = row['changed_pages'];
    if (raw == null) {
      return null;
    }
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final result = <int>{};
          for (final entry in decoded) {
            if (entry is num) {
              result.add(entry.toInt());
            } else if (entry is String) {
              final parsed = int.tryParse(entry);
              if (parsed != null) {
                result.add(parsed);
              }
            }
          }
          return result;
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
