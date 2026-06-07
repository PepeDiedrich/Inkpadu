import 'dart:convert';

import 'package:appwrite/appwrite.dart';
// ignore: implementation_imports
import 'package:appwrite/src/enums.dart' show HttpMethod;
import 'package:flutter/foundation.dart';

import 'package:inkpadu/app/auth/appwrite_config.dart';

/// Repräsentiert den entfernten Zustand der Werkzeugvoreinstellungen eines Nutzers.
class DrawingToolPreferencesRemoteModel {
  /// Erstellt ein neues Remote-Modell.
  const DrawingToolPreferencesRemoteModel({
    required this.userId,
    required this.toolsJson,
    required this.updatedAt,
    required this.createdAt,
    this.selectedToolId,
  });

  /// Appwrite Benutzer-ID.
  final String userId;

  /// Serialisierte Werkzeuge.
  final String toolsJson;

  /// Optional ausgewählte Werkzeug-ID.
  final String? selectedToolId;

  /// Zeitstempel der letzten Aktualisierung.
  final DateTime updatedAt;

  /// Zeitstempel der Erstellung.
  final DateTime createdAt;

  /// Versucht, ein Remote-Modell aus einer Daten-Map zu erstellen.
  static DrawingToolPreferencesRemoteModel? tryFromMap(
    Map<String, dynamic> data, {
    Object? fallbackUpdatedAt,
    Object? fallbackCreatedAt,
  }) {
    final String? userId = _stringOrNull(data['user_id']);
    if (userId == null) {
      return null;
    }

    final String toolsJson = _normalizeToolsJson(data['tools_json']);
    final String? selectedToolId = _normalizeSelectedToolId(
      data['selected_tool_id'],
    );

    final DateTime updatedAt =
        (_parseTimestamp(data['updated_at']) ??
                _parseTimestamp(fallbackUpdatedAt) ??
                DateTime.now().toUtc())
            .toUtc();

    final DateTime createdAt =
        (_parseTimestamp(data['created_at']) ??
                _parseTimestamp(fallbackCreatedAt) ??
                _parseTimestamp(fallbackUpdatedAt) ??
                updatedAt)
            .toUtc();

    return DrawingToolPreferencesRemoteModel(
      userId: userId,
      toolsJson: toolsJson,
      selectedToolId: selectedToolId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime? _parseTimestamp(Object? value) {
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is String) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }

  static String? _stringOrNull(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  static String _normalizeToolsJson(Object? value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    if (value == null) {
      return '[]';
    }
    try {
      return jsonEncode(value);
    } catch (_) {
      return '[]';
    }
  }

  static String? _normalizeSelectedToolId(Object? value) {
    final String? candidate = _stringOrNull(value);
    if (candidate == null || candidate.isEmpty) {
      return null;
    }
    return candidate;
  }
}

/// Payload zum Aktualisieren oder Erstellen eines Appwrite-Dokuments.
class DrawingToolPreferencesUpsertPayload {
  /// Erstellt ein neues Upsert-Payload.
  const DrawingToolPreferencesUpsertPayload({
    required this.userId,
    required this.toolsJson,
    required this.updatedAt,
    required this.createdAt,
    this.selectedToolId,
  });

  /// Appwrite Benutzer-ID, gleichzeitig Dokument-ID.
  final String userId;

  /// Serialisierte Werkzeuge.
  final String toolsJson;

  /// Optional ausgewählte Werkzeug-ID.
  final String? selectedToolId;

  /// Zeitstempel der letzten Aktualisierung.
  final DateTime updatedAt;

  /// Zeitstempel der Erstellung.
  final DateTime createdAt;

  /// Map für Appwrite.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'user_id': userId,
    'tools_json': toolsJson,
    'selected_tool_id': selectedToolId,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
  };
}

/// Abstrakte Schnittstelle für das Synchronisieren der Werkzeugvoreinstellungen.
abstract class DrawingToolPreferencesSync {
  /// Lädt die gespeicherten Voreinstellungen für einen Nutzer.
  Future<DrawingToolPreferencesRemoteModel?> fetchPreferences(String userId);

  /// Erstellt oder aktualisiert die Voreinstellungen eines Nutzers.
  Future<void> upsertPreferences(DrawingToolPreferencesUpsertPayload payload);
}

/// Konkreter Sync-Service, der Appwrite Databases verwendet.
class DrawingToolPreferencesSyncService implements DrawingToolPreferencesSync {
  /// Erstellt einen neuen Sync-Service.
  DrawingToolPreferencesSyncService({
    Client? client,
    this.databaseId = 'inkpadu-db',
    this.collectionId = 'drawing-tool-preferences',
  }) : _client = client ?? AppwriteConfig.client;

  final Client _client;

  /// Appwrite Datenbank-ID.
  final String databaseId;

  /// Appwrite Collection-ID.
  final String collectionId;

  @override
  Future<DrawingToolPreferencesRemoteModel?> fetchPreferences(
    String userId,
  ) async {
    try {
      final raw = await _call(
        method: HttpMethod.get,
        path: _buildPath(documentId: userId),
      );

      final normalized = _normalizeRawDocument(raw);

      return DrawingToolPreferencesRemoteModel.tryFromMap(
        normalized,
        fallbackUpdatedAt:
            normalized['updated_at'] ?? normalized[r'$updatedAt'],
        fallbackCreatedAt:
            normalized['created_at'] ?? normalized[r'$createdAt'],
      );
    } on FormatException catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('DrawingToolPreferencesSyncService: Formatfehler $error');
      }
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'DrawingToolPreferencesSyncService',
          informationCollector: () => <DiagnosticsNode>[
            DiagnosticsNode.message('fetchPreferences für $userId'),
          ],
        ),
      );
      return null;
    } on AppwriteException catch (error, stackTrace) {
      if (error.code == 404) {
        return null;
      }
      if (kDebugMode) {
        debugPrint(
          'Appwrite fetchPreferences fehlgeschlagen: ${error.message}',
        );
      }
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'DrawingToolPreferencesSyncService',
          informationCollector: () => <DiagnosticsNode>[
            DiagnosticsNode.message('fetchPreferences für $userId'),
          ],
        ),
      );
      rethrow;
    }
  }

  Map<String, dynamic> _normalizeRawDocument(Map<String, dynamic> doc) {
    final normalized = <String, dynamic>{};
    doc.forEach((key, value) {
      normalized[key] = value;
    });

    final permissions = normalized[r'$permissions'];
    if (permissions is List) {
      normalized[r'$permissions'] = permissions.whereType<String>().toList(
        growable: false,
      );
    } else {
      normalized[r'$permissions'] = const <String>[];
    }

    normalized[r'$createdAt'] ??= DateTime.now().toUtc().toIso8601String();
    normalized[r'$updatedAt'] ??= normalized[r'$createdAt'];
    normalized['created_at'] ??= normalized[r'$createdAt'];
    normalized['updated_at'] ??= normalized[r'$updatedAt'];

    return normalized;
  }

  @override
  Future<void> upsertPreferences(
    DrawingToolPreferencesUpsertPayload payload,
  ) async {
    final permissions = <String>[
      Permission.read(Role.user(payload.userId)),
      Permission.write(Role.user(payload.userId)),
      Permission.update(Role.user(payload.userId)),
      Permission.delete(Role.user(payload.userId)),
    ];

    try {
      await _call(
        method: HttpMethod.post,
        path: _buildPath(),
        params: <String, dynamic>{
          'documentId': payload.userId,
          'data': payload.toMap(),
          'permissions': permissions,
        },
      );
    } on AppwriteException catch (error) {
      if (error.code == 409) {
        await _call(
          method: HttpMethod.patch,
          path: _buildPath(documentId: payload.userId),
          params: <String, dynamic>{
            'data': payload.toMap(),
            'permissions': permissions,
          },
        );
        return;
      }
      if (kDebugMode) {
        debugPrint(
          'Appwrite upsertPreferences fehlgeschlagen: ${error.message}',
        );
      }
      rethrow;
    }
  }

  String _buildPath({String? documentId}) {
    final encodedDb = Uri.encodeComponent(databaseId);
    final encodedCollection = Uri.encodeComponent(collectionId);
    final basePath =
        '/databases/$encodedDb/collections/$encodedCollection/documents';
    if (documentId == null) {
      return basePath;
    }
    return '$basePath/${Uri.encodeComponent(documentId)}';
  }

  Future<Map<String, dynamic>> _call({
    required HttpMethod method,
    required String path,
    Map<String, dynamic>? params,
  }) async {
    final response = await _client.call(
      method,
      path: path,
      params: params ?? const <String, dynamic>{},
    );

    final raw = response.data;
    if (raw == null) {
      return const <String, dynamic>{};
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }

    throw const FormatException('Unerwartetes Antwortformat von Appwrite');
  }
}
