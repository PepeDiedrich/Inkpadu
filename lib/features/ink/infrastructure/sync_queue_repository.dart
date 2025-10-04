import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_note_dto.dart';

/// Repository für die lokale Persistenz der Offline-Sync-Queue.
///
/// Speichert ausstehende Notizen lokal, damit sie nach einem App-Neustart
/// weiterhin synchronisiert werden können.
class SyncQueueRepository {
  /// Erstellt ein neues [SyncQueueRepository].
  SyncQueueRepository({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  static const String _queueKey = 'ink_notes_sync_queue';
  static const String _deleteQueueKey = 'ink_notes_delete_queue';

  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Speichert die Liste der ausstehenden Notizen lokal.
  Future<void> saveQueue(List<InkNote> notes) async {
    await _ensureInitialized();
    try {
      final jsonList = notes
          .map((note) => InkNoteDto.fromDomain(note).toJson())
          .toList();
      final encoded = jsonEncode(jsonList);
      await _prefs!.setString(_queueKey, encoded);
    } catch (error) {
      debugPrint('SyncQueueRepository: Fehler beim Speichern der Queue: $error');
    }
  }

  /// Lädt die Liste der ausstehenden Notizen aus dem lokalen Speicher.
  Future<List<InkNote>> loadQueue() async {
    await _ensureInitialized();
    try {
      final encoded = _prefs!.getString(_queueKey);
      if (encoded == null || encoded.isEmpty) {
        return const <InkNote>[];
      }

      final jsonList = jsonDecode(encoded) as List<dynamic>;
      return jsonList
          .map((json) => InkNoteDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } catch (error) {
      debugPrint('SyncQueueRepository: Fehler beim Laden der Queue: $error');
      return const <InkNote>[];
    }
  }

  /// Löscht die gespeicherte Queue.
  Future<void> clearQueue() async {
    await _ensureInitialized();
    await _prefs!.remove(_queueKey);
  }

  /// Speichert die Liste der zu löschenden Notiz-IDs lokal.
  Future<void> saveDeleteQueue(List<String> noteIds) async {
    await _ensureInitialized();
    try {
      final encoded = jsonEncode(noteIds);
      await _prefs!.setString(_deleteQueueKey, encoded);
    } catch (error) {
      debugPrint('SyncQueueRepository: Fehler beim Speichern der Lösch-Queue: $error');
    }
  }

  /// Lädt die Liste der zu löschenden Notiz-IDs aus dem lokalen Speicher.
  Future<List<String>> loadDeleteQueue() async {
    await _ensureInitialized();
    try {
      final encoded = _prefs!.getString(_deleteQueueKey);
      if (encoded == null || encoded.isEmpty) {
        return const <String>[];
      }

      final jsonList = jsonDecode(encoded) as List<dynamic>;
      return jsonList.cast<String>();
    } catch (error) {
      debugPrint('SyncQueueRepository: Fehler beim Laden der Lösch-Queue: $error');
      return const <String>[];
    }
  }

  /// Löscht die gespeicherte Lösch-Queue.
  Future<void> clearDeleteQueue() async {
    await _ensureInitialized();
    await _prefs!.remove(_deleteQueueKey);
  }
}
