import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/sync_status.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_sync_service.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/sync_queue_repository.dart';

/// Zentrale Komponente für Sync-Management mit Debouncing, Retry und Offline-Queue.
class InkNoteSyncQueue {
  /// Erstellt eine neue [InkNoteSyncQueue].
  InkNoteSyncQueue({
    required InkNotesSync syncService,
    SyncQueueRepository? repository,
    Connectivity? connectivity,
    Duration debounceDuration = const Duration(seconds: 2),
    Duration periodicSyncInterval = const Duration(seconds: 30),
  })  : _syncService = syncService,
        _repository = repository ?? SyncQueueRepository(),
        _connectivity = connectivity ?? Connectivity(),
        _debounceDuration = debounceDuration,
        _periodicSyncInterval = periodicSyncInterval {
    _initialize();
  }

  final InkNotesSync _syncService;
  final SyncQueueRepository _repository;
  final Connectivity _connectivity;
  final Duration _debounceDuration;
  final Duration _periodicSyncInterval;

  final Map<String, InkNote> _pendingNotes = {};
  final Set<String> _pendingDeletes = {};
  final Map<String, SyncStatus> _syncStatuses = {};
  final Map<String, int> _retryAttempts = {};

  Timer? _debounceTimer;
  Timer? _periodicSyncTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  String? _userId;
  bool _isOnline = true;
  bool _disposed = false;

  static const int _maxRetries = 5;
  static const List<int> _retryDelaysSeconds = [1, 2, 4, 8, 16];

  /// Gibt den aktuellen Sync-Status für eine Notiz zurück.
  SyncStatus getStatus(String noteId) =>
      _syncStatuses[noteId] ?? SyncStatus.idle;

  /// Stream für Status-Änderungen einer bestimmten Notiz.
  final StreamController<Map<String, SyncStatus>> _statusController =
      StreamController<Map<String, SyncStatus>>.broadcast();

  /// Stream der Sync-Status-Änderungen.
  Stream<Map<String, SyncStatus>> get statusStream => _statusController.stream;

  /// Gibt alle aktuellen Sync-Status zurück.
  Map<String, SyncStatus> get allStatuses => Map.unmodifiable(_syncStatuses);

  void _initialize() {
    _loadQueueFromStorage();
    _setupConnectivityMonitoring();
    _startPeriodicSync();
  }

  Future<void> _loadQueueFromStorage() async {
    try {
      final notes = await _repository.loadQueue();
      for (final note in notes) {
        _pendingNotes[note.id] = note;
        _syncStatuses[note.id] = SyncStatus.pending;
      }

      final deletes = await _repository.loadDeleteQueue();
      _pendingDeletes.addAll(deletes);
      for (final noteId in deletes) {
        _syncStatuses[noteId] = SyncStatus.pending;
      }

      _notifyStatusChange();
    } catch (error) {
      debugPrint('InkNoteSyncQueue: Fehler beim Laden der Queue: $error');
    }
  }

  void _setupConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        final wasOffline = !_isOnline;
        _isOnline = !results.contains(ConnectivityResult.none);

        if (wasOffline && _isOnline) {
          debugPrint('InkNoteSyncQueue: Netzwerk wiederhergestellt, starte Queue-Verarbeitung');
          _processQueue();
        }
      },
    );
  }

  void _startPeriodicSync() {
    _periodicSyncTimer = Timer.periodic(_periodicSyncInterval, (_) {
      if (_isOnline && (_pendingNotes.isNotEmpty || _pendingDeletes.isNotEmpty)) {
        _processQueue();
      }
    });
  }

  /// Setzt die User-ID für die Synchronisation.
  void setUserId(String? userId) {
    if (_userId == userId) return;
    
    _userId = userId;
    
    if (userId != null) {
      _processQueue();
    }
  }

  /// Fügt eine Notiz zur Sync-Queue hinzu (mit Debouncing).
  void enqueueUpsert(InkNote note) {
    if (_disposed) return;

    _pendingNotes[note.id] = note;
    _syncStatuses[note.id] = SyncStatus.pending;
    _notifyStatusChange();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _processQueue();
    });

    _saveQueueToStorage();
  }

  /// Fügt eine Notiz-Löschung zur Queue hinzu (mit Debouncing).
  void enqueueDelete(String noteId) {
    if (_disposed) return;

    _pendingNotes.remove(noteId);
    _pendingDeletes.add(noteId);
    _syncStatuses[noteId] = SyncStatus.pending;
    _notifyStatusChange();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _processQueue();
    });

    _saveQueueToStorage();
  }

  /// Verarbeitet die Queue sofort (z.B. beim dispose).
  Future<void> flush() async {
    _debounceTimer?.cancel();
    await _processQueue();
  }

  Future<void> _processQueue() async {
    if (_disposed || _userId == null || !_isOnline) {
      return;
    }

    final userId = _userId!;

    // Verarbeite Upserts
    final notesToSync = List<InkNote>.from(_pendingNotes.values);
    for (final note in notesToSync) {
      if (_disposed) break;
      await _syncNote(note, userId);
    }

    // Verarbeite Deletes
    final notesToDelete = List<String>.from(_pendingDeletes);
    for (final noteId in notesToDelete) {
      if (_disposed) break;
      await _deleteNote(noteId, userId);
    }
  }

  Future<void> _syncNote(InkNote note, String userId) async {
    if (_disposed) return;

    final noteId = note.id;
    _syncStatuses[noteId] = SyncStatus.syncing;
    _notifyStatusChange();

    try {
      await _syncService.upsertNote(note, userId);
      
      _pendingNotes.remove(noteId);
      _retryAttempts.remove(noteId);
      _syncStatuses[noteId] = SyncStatus.synced;
      _notifyStatusChange();
      
      await _saveQueueToStorage();
      
      // Nach 2 Sekunden Status zurück auf idle setzen
      Timer(const Duration(seconds: 2), () {
        if (!_disposed && _syncStatuses[noteId] == SyncStatus.synced) {
          _syncStatuses[noteId] = SyncStatus.idle;
          _notifyStatusChange();
        }
      });
    } on AppwriteException catch (error) {
      debugPrint('InkNoteSyncQueue: Sync-Fehler für Note $noteId: ${error.message}');
      await _handleSyncError(noteId, error);
    } catch (error) {
      debugPrint('InkNoteSyncQueue: Unerwarteter Sync-Fehler für Note $noteId: $error');
      await _handleSyncError(noteId, error);
    }
  }

  Future<void> _deleteNote(String noteId, String userId) async {
    if (_disposed) return;

    _syncStatuses[noteId] = SyncStatus.syncing;
    _notifyStatusChange();

    try {
      await _syncService.deleteNote(noteId, userId);
      
      _pendingDeletes.remove(noteId);
      _retryAttempts.remove(noteId);
      _syncStatuses.remove(noteId);
      _notifyStatusChange();
      
      await _saveQueueToStorage();
    } on AppwriteException catch (error) {
      debugPrint('InkNoteSyncQueue: Lösch-Fehler für Note $noteId: ${error.message}');
      await _handleSyncError(noteId, error);
    } catch (error) {
      debugPrint('InkNoteSyncQueue: Unerwarteter Lösch-Fehler für Note $noteId: $error');
      await _handleSyncError(noteId, error);
    }
  }

  Future<void> _handleSyncError(String noteId, Object error) async {
    // Bei Auth-Fehler keine Retries
    if (error is AppwriteException && (error.code == 401 || error.code == 403)) {
      _syncStatuses[noteId] = SyncStatus.error;
      _notifyStatusChange();
      return;
    }

    final attempts = _retryAttempts[noteId] ?? 0;
    
    if (attempts >= _maxRetries) {
      _syncStatuses[noteId] = SyncStatus.error;
      _notifyStatusChange();
      return;
    }

    _retryAttempts[noteId] = attempts + 1;
    _syncStatuses[noteId] = SyncStatus.pending;
    _notifyStatusChange();

    final delaySeconds = _retryDelaysSeconds[attempts.clamp(0, _retryDelaysSeconds.length - 1)];
    await Future<void>.delayed(Duration(seconds: delaySeconds));

    if (!_disposed) {
      _processQueue();
    }
  }

  Future<void> _saveQueueToStorage() async {
    try {
      await _repository.saveQueue(_pendingNotes.values.toList());
      await _repository.saveDeleteQueue(_pendingDeletes.toList());
    } catch (error) {
      debugPrint('InkNoteSyncQueue: Fehler beim Speichern der Queue: $error');
    }
  }

  void _notifyStatusChange() {
    if (!_disposed && _statusController.hasListener) {
      _statusController.add(Map.from(_syncStatuses));
    }
  }

  /// Gibt alle Ressourcen frei und syncronisiert ausstehende Änderungen.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    _debounceTimer?.cancel();
    _periodicSyncTimer?.cancel();
    await _connectivitySubscription?.cancel();

    await flush();
    await _statusController.close();
  }
}
