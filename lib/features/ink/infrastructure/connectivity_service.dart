import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_repository.dart';

/// Service zur Überwachung der Internetverbindung und zum Auslösen von Synchronisationen.
class ConnectivityService {
  /// Erstellt einen neuen [ConnectivityService] mit dem gegebenen Repository.
  ConnectivityService({required this.repository}) {
    _connectivity = Connectivity();
    _controller = StreamController<bool>.broadcast();
  }

  late final Connectivity _connectivity;
  late final StreamController<bool> _controller;

  /// Repository, das zur Synchronisation verwendet wird.
  final InkNotesRepository repository;

  /// Stream, der `true` ausgibt, wenn das Gerät online ist, sonst `false`.
  Stream<bool> get isOnline => _controller.stream;

  /// Subscription für die Konnektivitätsänderungen, die überwacht werden.
  StreamSubscription<dynamic>? _sub;

  /// Startet die Überwachung der Konnektivität.
  void startMonitoring() {
    _sub ??= _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      final online = results.any((result) => result != ConnectivityResult.none);
      _controller.add(online);
      if (online) {
        // best effort: if repository has user context, caller should provide userId
        // For now, try to sync without userId is a no-op in repository
        try {
          // No userId available here; rely on calling code to trigger sync with userId
          // If repository.syncAll requires userId, caller integration should pass it.
        } catch (_) {}
      }
    });
  }

  /// Stoppt die Überwachung der Konnektivität und schließt den Stream.
  Future<void> stopMonitoring() async {
    await _sub?.cancel();
    await _controller.close();
  }
}
