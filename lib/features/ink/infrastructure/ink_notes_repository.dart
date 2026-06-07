import 'dart:async';

import 'package:inkpadu/features/ink/domain/ink_note.dart';
import 'package:inkpadu/features/ink/infrastructure/ink_notes_local_storage.dart';
import 'package:inkpadu/features/ink/infrastructure/ink_notes_sync_service.dart';

/// Repository für die Verwaltung von handschriftlichen Notizen, kombiniert lokalen Speicher und Synchronisation.
class InkNotesRepository {
  /// Lokaler Speicher für Notizen.
  final InkNotesLocalStorage localStorage;

  /// Optionaler Service für die Synchronisation mit dem Backend.
  final InkNotesSync? syncService;

  /// Erstellt ein neues Repository mit lokalem Speicher und optionalem Sync-Service.
  InkNotesRepository({required this.localStorage, this.syncService});

  /// Initialisiert das Repository.
  Future<void> init() async {
    await localStorage.init();
  }

  /// Gibt alle lokalen Notizen zurück.
  Future<List<InkNote>> getLocalNotes() => localStorage.getAllNotes();

  /// Fügt eine Notiz hinzu oder aktualisiert sie und synchronisiert falls möglich.
  Future<void> upsertNote(
    InkNote note, {
    required String userId,
    Set<int>? changedPageIndices,
  }) async {
    // Always save locally first (offline-first)
    await localStorage.saveNote(
      note,
      userId: userId,
      changedPageIndices: changedPageIndices,
    );

    // Try to sync immediately if possible
    await _trySyncNote(note, userId, changedPageIndices: changedPageIndices);
  }

  /// Löscht eine Notiz und synchronisiert die Löschung.
  Future<void> deleteNote(String id, {String? userId}) async {
    await localStorage.deleteNote(id);
    // Try remote delete
    if (userId != null && syncService != null) {
      try {
        await syncService!.deleteNote(id, userId);
        await localStorage.markSynced(id);
      } catch (_) {
        // Keep queue for retry
      }
    }
  }

  /// Synchronisiert alle Notizen mit dem Remote-Service.
  Future<void> syncAll({required String userId}) async {
    if (syncService == null) return;

    // Identify notes pending deletion to avoid resurrection from remote fetch
    // We fetch a larger number to be safe, assuming no user has >1000 pending operations regularly.
    final queueItems = await localStorage.fetchQueueItems(limit: 1000);
    final pendingDeletes = queueItems
        .where((row) => row['operation'] == 'DELETE')
        .map((row) => row['note_id'] as String?)
        .whereType<String>()
        .toSet();

    // Upload pending local notes
    final pending = await localStorage.getPendingNotes();
    for (final note in pending) {
      await _trySyncNote(note, userId);
    }

    // Process queue items (ensure ordered retries)
    await processQueueOnce(userId: userId);

    // Fetch remote and merge
    try {
      final remoteNotes = await syncService!.fetchNotes(userId);
      final localNotes = await localStorage.getAllNotes();
      final merged = <String, InkNote>{};

      for (final r in remoteNotes) {
        // If we have a pending delete for this note, ignore the remote version
        // so we don't "resurrect" it locally.
        if (pendingDeletes.contains(r.id)) {
          continue;
        }
        merged[r.id] = r;
      }
      for (final l in localNotes) {
        final remote = merged[l.id];
        if (remote == null || l.updatedAt.isAfter(remote.updatedAt)) {
          merged[l.id] = l;
          // push local newer to remote
          await _trySyncNote(l, userId);
        }
      }

      // Persist merged set locally
      for (final n in merged.values) {
        await localStorage.saveNote(
          n,
          status: LocalSyncStatus.synced,
          userId: userId,
        );
      }
    } catch (e) {
      // Ignore fetch errors; keep local pending items for later retry
    }
  }

  /// Verarbeitet ausstehende Synchronisations-Queue-Items einmal.
  /// Process queue items once (ordered by creation). This method is re-entrant
  /// and will attempt operations via the syncService. On success removes the
  /// queue item; on failure increases retry_count.
  Future<void> processQueueOnce({
    required String userId,
    int maxItems = 50,
  }) async {
    if (syncService == null) return;
    final items = await localStorage.fetchQueueItems(limit: maxItems);
    for (final row in items) {
      final int? id = row['id'] as int?;
      final String? noteId = row['note_id'] as String?;
      final String? operation = row['operation'] as String?;
      final int retryCount = (row['retry_count'] as int?) ?? 0;
      if (id == null || noteId == null || operation == null) {
        if (id != null) await localStorage.deleteQueueItemById(id);
        continue;
      }

      try {
        if (operation == 'UPSERT') {
          final note = await localStorage.getNoteById(noteId);
          if (note != null) {
            final changedPages = localStorage.extractChangedPages(row);
            await syncService!.upsertNote(
              note,
              userId,
              changedPageIndices: changedPages,
            );
            await localStorage.markSynced(
              noteId,
              remoteUpdatedAt: note.updatedAt.toUtc(),
            );
          }
        } else if (operation == 'DELETE') {
          await syncService!.deleteNote(noteId, userId);
          // ensure local note removed
          // localStorage.deleteNote was already called when enqueuing delete
        }

        await localStorage.deleteQueueItemById(id);
      } catch (err) {
        // increase retry count and store last error
        await localStorage.updateQueueItem(
          id,
          retryCount: retryCount + 1,
          lastError: err.toString(),
        );
      }
    }
  }

  Future<void> _trySyncNote(
    InkNote note,
    String userId, {
    Set<int>? changedPageIndices,
  }) async {
    if (syncService == null) return;
    try {
      await syncService!.upsertNote(
        note,
        userId,
        changedPageIndices: changedPageIndices,
      );
      await localStorage.markSynced(
        note.id,
        remoteUpdatedAt: note.updatedAt.toUtc(),
      );
    } catch (e) {
      // leave as pending for retry
    }
  }
}
