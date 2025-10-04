import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_auth.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_sync_service.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_note_sync_queue.dart';

/// Notifier verwaltet die in-memory Sammlung handschriftlicher Notizen und
/// synchronisiert sie optional mit Appwrite.
class InkNotesController extends ChangeNotifier {
  /// Erstellt einen neuen [InkNotesController]. Wird sowohl ein
  /// [InkNotesSync] als auch ein [InkNotesAuth] übergeben, werden
  /// Notizen automatisch für angemeldete E-Mail-Nutzer mit Appwrite
  /// synchronisiert.
  InkNotesController({
    InkNotesSync? syncService,
    InkNotesAuth? auth,
    InkNoteSyncQueue? syncQueue,
  })  : _syncService = syncService,
        _auth = auth,
        _syncQueue = syncQueue {
    final authBridge = _auth;
    if (_syncService != null && authBridge != null) {
      authBridge.addListener(_handleAuthChanged);
      _handleAuthChanged();
    }
  }

  final List<InkNote> _notes = [];
  final InkNotesSync? _syncService;
  final InkNotesAuth? _auth;
  final InkNoteSyncQueue? _syncQueue;

  InkNotesRealtimeSubscription? _realtimeSubscription;
  String? _activeUserId;
  bool _applyingRemoteUpdate = false;

  /// Unveränderliche Sicht auf alle Notizen.
  List<InkNote> get notes => List.unmodifiable(_notes);

  /// Legt eine neue leere Notiz an und gibt sie zurück.
  InkNote createEmpty({
    String? title,
    NotePaperStyle paperStyle = NotePaperStyle.plain,
  }) {
    final String? cleanedTitle = title?.trim();
    final note = InkNote.empty(
      title: (cleanedTitle?.isEmpty ?? true) ? null : cleanedTitle,
      paperStyle: paperStyle,
    );
    _notes.insert(0, note);
    _safelyNotifyListeners();
    _syncIfPossible(note);
    return note;
  }

  /// Fügt eine Notiz ein oder aktualisiert sie anhand der ID.
  void upsert(InkNote note, {bool fromRemote = false}) {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx == -1) {
      _notes.add(note);
    } else {
      if (!_applyingRemoteUpdate &&
          _notes[idx].updatedAt.isAfter(note.updatedAt)) {
        return;
      }
      _notes[idx] = note;
    }
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _safelyNotifyListeners();
    if (!fromRemote) {
      _syncIfPossible(note);
    }
  }

  /// Löscht die Notiz mit passender [id].
  void delete(String id, {bool fromRemote = false}) {
    final int before = _notes.length;
    _notes.removeWhere((n) => n.id == id);
    if (_notes.length != before) {
      _safelyNotifyListeners();
      if (!fromRemote) {
        _deleteIfPossible(id);
      }
    }
  }

  void _safelyNotifyListeners() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  void _handleAuthChanged() {
    final auth = _auth;
    if (_syncService == null || auth == null) {
      return;
    }
    if (!auth.isLoggedIn || auth.userId == null) {
      _activeUserId = null;
      unawaited(_realtimeSubscription?.cancel());
      _realtimeSubscription = null;
      return;
    }

    final String email = (auth.email ?? '').trim();
    if (email.isEmpty) {
      _activeUserId = null;
      unawaited(_realtimeSubscription?.cancel());
      _realtimeSubscription = null;
      return;
    }

    final String userId = auth.userId!;
    if (_activeUserId == userId) {
      return;
    }

    _activeUserId = userId;
    _syncQueue?.setUserId(userId);
    unawaited(_synchronizeWithRemote(userId));
  }

  Future<void> _synchronizeWithRemote(String userId) async {
    final service = _syncService;
    if (service == null) return;

    List<InkNote> remoteNotes = const [];
    try {
      remoteNotes = await service.fetchNotes(userId);
    } catch (error) {
      debugPrint('Fehler beim Laden der Notizen aus Appwrite: $error');
    }

    final Map<String, InkNote> merged = {
      for (final note in remoteNotes) note.id: note,
    };

    final Map<String, InkNote> toUpload = {};
    for (final local in _notes) {
      final remote = merged[local.id];
      if (remote == null || local.updatedAt.isAfter(remote.updatedAt)) {
        merged[local.id] = local;
        toUpload[local.id] = local;
      }
    }

    final List<InkNote> nextNotes = merged.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    _notes
      ..clear()
      ..addAll(nextNotes);
    _safelyNotifyListeners();

    for (final note in toUpload.values) {
      _syncIfPossible(note);
    }

    await _realtimeSubscription?.cancel();
    _realtimeSubscription = service.observeUserNotes(
      userId: userId,
      onEvent: _handleRemoteEvent,
    );
  }

  void _handleRemoteEvent(InkNotesRemoteEvent event) {
    _applyingRemoteUpdate = true;
    try {
      if (event is InkNotesRemoteUpsert) {
        final incoming = event.note;
        final idx = _notes.indexWhere((n) => n.id == incoming.id);
        if (idx != -1 &&
            _notes[idx].updatedAt.isAfter(incoming.updatedAt)) {
          return;
        }
        upsert(incoming, fromRemote: true);
      } else if (event is InkNotesRemoteDelete) {
        delete(event.noteId, fromRemote: true);
      }
    } finally {
      _applyingRemoteUpdate = false;
    }
  }

  void _syncIfPossible(InkNote note) {
    final queue = _syncQueue;
    if (queue == null || _activeUserId == null) {
      return;
    }
    queue.enqueueUpsert(note);
  }

  void _deleteIfPossible(String noteId) {
    final queue = _syncQueue;
    if (queue == null || _activeUserId == null) {
      return;
    }
    queue.enqueueDelete(noteId);
  }

  @override
  void dispose() {
    _auth?.removeListener(_handleAuthChanged);
    unawaited(_realtimeSubscription?.cancel());
    unawaited(_syncQueue?.dispose());
    super.dispose();
  }
}

/// InheritedWidget für einfachen Zugriff im Widget-Tree.
/// Inherited Scope für Zugriff auf [InkNotesController].
/// Ein [InheritedNotifier] zum Verwalten des Zustands von handschriftlichen Notizen.
class InkNotesScope extends InheritedNotifier<InkNotesController> {
  /// Erstellt eine neue [InkNotesScope].
  const InkNotesScope({
    super.key,
    required InkNotesController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Liefert den [InkNotesController] aus dem Kontext.
  static InkNotesController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<InkNotesScope>();
    assert(scope != null, 'InkNotesScope nicht im Widget-Tree gefunden');
    return scope!.notifier!;
  }

  @override
  @override
  bool updateShouldNotify(
    covariant InheritedNotifier<InkNotesController> oldWidget,
  ) => true;
}
