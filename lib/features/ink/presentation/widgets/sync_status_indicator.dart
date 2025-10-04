import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/domain/sync_status.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_note_sync_queue.dart';

/// Widget zur Anzeige des Sync-Status einer Notiz.
///
/// Zeigt ein Icon mit Tooltip basierend auf dem aktuellen Sync-Status.
class SyncStatusIndicator extends StatelessWidget {
  /// Erstellt einen neuen [SyncStatusIndicator].
  const SyncStatusIndicator({
    super.key,
    required this.syncQueue,
    required this.noteId,
  });

  /// Die Sync-Queue, die den Status verwaltet.
  final InkNoteSyncQueue? syncQueue;

  /// Die ID der Notiz, deren Status angezeigt werden soll.
  final String noteId;

  @override
  Widget build(BuildContext context) {
    final queue = syncQueue;
    if (queue == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<Map<String, SyncStatus>>(
      stream: queue.statusStream,
      initialData: queue.allStatuses,
      builder: (context, snapshot) {
        final statuses = snapshot.data ?? {};
        final status = statuses[noteId] ?? SyncStatus.idle;

        return _buildStatusIcon(context, status);
      },
    );
  }

  Widget _buildStatusIcon(BuildContext context, SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return const SizedBox.shrink();

      case SyncStatus.pending:
        return const Tooltip(
          message: 'Wartet auf Synchronisation...',
          child: Icon(
            Icons.schedule,
            size: 18,
            color: Colors.orange,
          ),
        );

      case SyncStatus.syncing:
        return const Tooltip(
          message: 'Wird synchronisiert...',
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        );

      case SyncStatus.synced:
        return const Tooltip(
          message: 'Erfolgreich synchronisiert',
          child: Icon(
            Icons.check_circle,
            size: 18,
            color: Colors.green,
          ),
        );

      case SyncStatus.error:
        return const Tooltip(
          message: 'Synchronisationsfehler',
          child: Icon(
            Icons.error,
            size: 18,
            color: Colors.red,
          ),
        );
    }
  }
}
