import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

bool _isSqfliteFfiConfigured = false;
Directory? _currentDatabaseDir;
final List<Directory> _pendingCleanupDirs = <Directory>[];

Future<void> ensureTestDatabaseFactory() async {
  if (_isSqfliteFfiConfigured) {
    return;
  }
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  _isSqfliteFfiConfigured = true;
}

Future<void> resetTestDatabase() async {
  await ensureTestDatabaseFactory();
  if (_currentDatabaseDir != null) {
    _pendingCleanupDirs.add(_currentDatabaseDir!);
    _currentDatabaseDir = null;
  }

  final Directory tempDir = await Directory.systemTemp.createTemp('inkpadu_sqflite_test_');
  _currentDatabaseDir = tempDir;
  databaseFactoryFfi.setDatabasesPath(tempDir.path);
}

Future<void> disposeTestDatabase() async {
  final List<Directory> targets = <Directory>[
    if (_currentDatabaseDir != null) _currentDatabaseDir!,
    ..._pendingCleanupDirs,
  ];
  _pendingCleanupDirs.clear();
  _currentDatabaseDir = null;

  for (final Directory dir in targets) {
    if (await dir.exists()) {
      try {
        await dir.delete(recursive: true);
      } catch (_) {
        // Ignoriere Bereinigungsfehler.
      }
    }
  }
}
