import 'dart:convert';

import 'package:appwrite/appwrite.dart';
// ignore: implementation_imports
import 'package:appwrite/src/enums.dart' show HttpMethod;
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter/foundation.dart';

import 'package:ai_handwriting_app/app/auth/appwrite_config.dart';

/// Repräsentiert den entfernten Zustand der Werkzeugvoreinstellungen eines Nutzers.
class DrawingToolPreferencesRemoteModel {
  /// Erstellt ein neues Remote-Modell.
  const DrawingToolPreferencesRemoteModel({
    required this.userId,
    required this.toolsJson,
    required this.updatedAt,
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

  /// Baut ein Modell aus einem Appwrite Dokument.
  factory DrawingToolPreferencesRemoteModel.fromDocument(
    appwrite_models.Document document,
  ) {
    final candidate = DrawingToolPreferencesRemoteModel.tryFromMap(
      Map<String, dynamic>.from(document.data),
      fallbackUpdatedAt: document.$updatedAt,
    );
    if (candidate == null) {
      throw StateError(
        'Ungültiges Dokument für DrawingToolPreferences: ${document.$id}',
      );
    }
    return candidate;
  }

  /// Versucht, ein Remote-Modell aus einer Daten-Map zu erstellen.
  static DrawingToolPreferencesRemoteModel? tryFromMap(
    Map<String, dynamic> data, {
    Object? fallbackUpdatedAt,
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

    return DrawingToolPreferencesRemoteModel(
      userId: userId,
      toolsJson: toolsJson,
      selectedToolId: selectedToolId,
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

  /// Map für Appwrite.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'user_id': userId,
    'tools_json': toolsJson,
    'selected_tool_id': selectedToolId,
    'updated_at': updatedAt.toUtc().toIso8601String(),
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
    Databases? databases,
    this.databaseId = 'inkpadu-db',
    this.collectionId = 'drawing-tool-preferences',
  }) : _databases = databases ?? Databases(client ?? AppwriteConfig.client);

  final Databases _databases;

  /// Appwrite Datenbank-ID.
  final String databaseId;

  /// Appwrite Collection-ID.
  final String collectionId;

  @override
  Future<DrawingToolPreferencesRemoteModel?> fetchPreferences(
    String userId,
  ) async {
    try {
      final document = await _databases.getDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: userId,
      );
      return DrawingToolPreferencesRemoteModel.fromDocument(document);
    } on TypeError catch (error, stackTrace) {
      debugPrint('Appwrite fetchPreferences parsing error: $error');
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'DrawingToolPreferencesSyncService',
          informationCollector: () => <DiagnosticsNode>[
            DiagnosticsNode.message(
              'Fallback auf Rohdokument für user $userId aktiviert',
            ),
          ],
        ),
      );
      return _fetchPreferencesWithRawDocument(userId: userId);
    } on StateError catch (error, stackTrace) {
      debugPrint('Appwrite fetchPreferences invalid document: $error');
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'DrawingToolPreferencesSyncService',
          informationCollector: () => <DiagnosticsNode>[
            DiagnosticsNode.message(
              'Fallback auf Rohdokument für user $userId aktiviert',
            ),
          ],
        ),
      );
      return _fetchPreferencesWithRawDocument(userId: userId);
    } on AppwriteException catch (error, stackTrace) {
      if (error.code == 404) {
        return null;
      }
      debugPrint('Appwrite fetchPreferences fehlgeschlagen: ${error.message}');
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

  Future<DrawingToolPreferencesRemoteModel?> _fetchPreferencesWithRawDocument({
    required String userId,
  }) async {
    try {
      final response = await _databases.client.call(
        HttpMethod.get,
        path:
            '/databases/${Uri.encodeComponent(databaseId)}/collections/${Uri.encodeComponent(collectionId)}/documents/${Uri.encodeComponent(userId)}',
      );

      final raw = response.data;
      if (raw is! Map) {
        debugPrint(
          'DrawingToolPreferencesSyncService: Unerwartetes Antwortformat ${raw.runtimeType}',
        );
        return null;
      }

      final Map<String, dynamic> normalized = _normalizeRawDocument(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );

      final model = DrawingToolPreferencesRemoteModel.tryFromMap(
        normalized,
        fallbackUpdatedAt:
            normalized['updated_at'] ?? normalized[r'$updatedAt'],
      );

      if (model == null) {
        debugPrint(
          'DrawingToolPreferencesSyncService: Rohdokument für user $userId unvollständig.',
        );
      }
      return model;
    } on AppwriteException catch (error, stackTrace) {
      if (error.code == 404) {
        return null;
      }
      debugPrint(
        'DrawingToolPreferencesSyncService: Rohabruf fehlgeschlagen: ${error.message}',
      );
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'DrawingToolPreferencesSyncService',
          informationCollector: () => <DiagnosticsNode>[
            DiagnosticsNode.message(
              'Rohabruf der Werkzeugpräferenzen für user $userId fehlgeschlagen',
            ),
          ],
        ),
      );
      rethrow;
    } catch (error, stackTrace) {
      debugPrint(
        'DrawingToolPreferencesSyncService: Fehler beim Rohabruf: $error',
      );
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'DrawingToolPreferencesSyncService',
          informationCollector: () => <DiagnosticsNode>[
            DiagnosticsNode.message(
              'Rohabruf der Werkzeugpräferenzen für user $userId fehlgeschlagen',
            ),
          ],
        ),
      );
      return null;
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
      await _databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: payload.userId,
        data: payload.toMap(),
        permissions: permissions,
      );
    } on AppwriteException catch (error) {
      if (error.code == 409) {
        await _databases.updateDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: payload.userId,
          data: payload.toMap(),
          permissions: permissions,
        );
        return;
      }
      debugPrint('Appwrite upsertPreferences fehlgeschlagen: ${error.message}');
      rethrow;
    }
  }
}
