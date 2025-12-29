import 'dart:convert';
import 'dart:ui';

import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/drawing_tool_preferences_sync_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistiert benutzerdefinierte Zeichenwerkzeuge.
class DrawingToolPreferencesRepository {
  /// Erstellt das Repository und erlaubt optionale Test-Doubles.
  DrawingToolPreferencesRepository({
    SharedPreferences? sharedPreferences,
    AuthController? authController,
    DrawingToolPreferencesSync? syncService,
  }) : _sharedPreferences = sharedPreferences,
       _authController = authController,
       _syncService = syncService;

  /// Überschreibt die verwendete [SharedPreferences]-Instanz (z. B. in Tests).
  final SharedPreferences? _sharedPreferences;

  final AuthController? _authController;
  final DrawingToolPreferencesSync? _syncService;

  DrawingToolPreferencesRemoteModel? _remoteCache;

  static const String _storageKey = 'drawing_tools_v1';
  static const String _selectedToolKey = 'drawing_selected_tool_v1';
  static const String _toolbarPositionXKey = 'drawing_toolbar_pos_x_v1';
  static const String _toolbarPositionYKey = 'drawing_toolbar_pos_y_v1';

  /// Lädt gespeicherte Werkzeuge.
  Future<List<DrawingTool>> load(List<DrawingTool> defaults) async {
    try {
      final SharedPreferences prefs = await _prefs;
      final List<DrawingTool>? local = _readToolsFromPrefs(prefs);

      List<DrawingTool> result;
      if (local != null && local.isNotEmpty) {
        result = local;
      } else {
        result = defaults;
      }

      final DrawingToolPreferencesRemoteModel? remote =
          await _loadRemotePreferences();
      if (remote != null) {
        final List<DrawingTool> remoteTools = _decodeTools(remote.toolsJson);
        if (remoteTools.isNotEmpty) {
          result = remoteTools;
          await _persistLocalState(
            prefs,
            tools: result,
            selectedToolId: remote.selectedToolId,
          );
        } else if (remote.selectedToolId != null) {
          await prefs.setString(_selectedToolKey, remote.selectedToolId!);
        }
      }

      return result;
    } catch (error, stackTrace) {
      debugPrint(
        'Fehler beim Laden der Werkzeug-Voreinstellungen: $error\n$stackTrace',
      );
      return defaults;
    }
  }

  /// Lädt die gespeicherte Toolbar-Position.
  Future<Offset?> loadToolbarPosition() async {
    try {
      final SharedPreferences prefs = await _prefs;
      final double? dx = prefs.getDouble(_toolbarPositionXKey);
      final double? dy = prefs.getDouble(_toolbarPositionYKey);
      if (dx != null && dy != null) {
        return Offset(dx, dy);
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  /// Speichert die Toolbar-Position.
  Future<void> saveToolbarPosition(Offset position) async {
    try {
      final SharedPreferences prefs = await _prefs;
      await prefs.setDouble(_toolbarPositionXKey, position.dx);
      await prefs.setDouble(_toolbarPositionYKey, position.dy);
    } catch (error) {
      debugPrint('Fehler beim Speichern der Toolbar-Position: $error');
    }
  }

  /// Speichert die übergebenen [tools] persistent und synchronisiert optional remote.
  Future<void> save(List<DrawingTool> tools, {String? selectedToolId}) async {
    try {
      final SharedPreferences prefs = await _prefs;
      await _persistLocalState(
        prefs,
        tools: tools,
        selectedToolId: selectedToolId,
      );
      await _syncRemoteState(tools: tools, selectedToolId: selectedToolId);
    } catch (error, stackTrace) {
      debugPrint(
        'Fehler beim Speichern der Werkzeug-Voreinstellungen: $error\n$stackTrace',
      );
    }
  }

  /// Speichert die aktuell ausgewählte Werkzeug-ID persistent.
  Future<void> saveSelectedToolId(
    String toolId, {
    List<DrawingTool>? currentTools,
  }) async {
    try {
      final SharedPreferences prefs = await _prefs;
      await prefs.setString(_selectedToolKey, toolId);
      final List<DrawingTool> tools =
          currentTools ?? _readToolsFromPrefs(prefs) ?? const <DrawingTool>[];
      await _syncRemoteState(tools: tools, selectedToolId: toolId);
    } catch (error, stackTrace) {
      debugPrint(
        'Fehler beim Speichern der Werkzeugauswahl: $error\n$stackTrace',
      );
    }
  }

  /// Lädt die zuletzt gespeicherte Werkzeug-ID.
  Future<String?> loadSelectedToolId() async {
    try {
      final SharedPreferences prefs = await _prefs;
      final String? local = prefs.getString(_selectedToolKey);
      if (local != null) {
        return local;
      }
      final DrawingToolPreferencesRemoteModel? remote =
          await _loadRemotePreferences();
      if (remote?.selectedToolId != null) {
        await prefs.setString(_selectedToolKey, remote!.selectedToolId!);
      }
      return remote?.selectedToolId;
    } catch (error, stackTrace) {
      debugPrint('Fehler beim Laden der Werkzeugauswahl: $error\n$stackTrace');
      return null;
    }
  }

  Future<SharedPreferences> get _prefs async =>
      _sharedPreferences ?? await SharedPreferences.getInstance();

  List<DrawingTool>? _readToolsFromPrefs(SharedPreferences prefs) {
    final String? raw = prefs.getString(_storageKey);
    if (raw == null) {
      return null;
    }
    final List<DrawingTool> decoded = _decodeTools(raw);
    return decoded.isEmpty ? null : decoded;
  }

  List<DrawingTool> _decodeTools(String raw) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <DrawingTool>[];
      }

      final List<DrawingTool> stored = <DrawingTool>[];
      for (final dynamic entry in decoded) {
        if (entry is Map<String, dynamic>) {
          stored.add(DrawingTool.fromJson(entry));
          continue;
        }
        if (entry is Map) {
          final map = entry.map(
            (key, value) => MapEntry(key.toString(), value),
          );
          stored.add(DrawingTool.fromJson(map));
          continue;
        }
        debugPrint('Unbekannter Werkzeugeintrag vom Typ ${entry.runtimeType}');
      }
      return stored;
    } catch (error, stackTrace) {
      debugPrint(
        'Fehler beim Dekodieren der Werkzeugliste: $error\n$stackTrace',
      );
      return const <DrawingTool>[];
    }
  }

  Future<void> _persistLocalState(
    SharedPreferences prefs, {
    required List<DrawingTool> tools,
    String? selectedToolId,
  }) async {
    final String payload = _encodeTools(tools);
    await prefs.setString(_storageKey, payload);
    if (selectedToolId != null) {
      await prefs.setString(_selectedToolKey, selectedToolId);
    }
  }

  String _encodeTools(List<DrawingTool> tools) =>
      jsonEncode(tools.map((tool) => tool.toJson()).toList(growable: false));

  Future<void> _syncRemoteState({
    required List<DrawingTool> tools,
    required String? selectedToolId,
  }) async {
    final DrawingToolPreferencesSync? sync = _syncService;
    final String? userId = _resolveUserId();
    if (sync == null || userId == null) {
      return;
    }

    DrawingToolPreferencesRemoteModel? remote = _remoteCache;
    if (remote == null) {
      try {
        remote = await sync.fetchPreferences(userId);
        if (remote != null) {
          _remoteCache = remote;
        }
      } catch (_) {
        remote = null;
      }
    }

    final DateTime updatedAt = DateTime.now().toUtc();
    final DateTime createdAt = remote?.createdAt ?? updatedAt;
    final String toolsJson = _encodeTools(tools);
    final DrawingToolPreferencesUpsertPayload payload =
        DrawingToolPreferencesUpsertPayload(
          userId: userId,
          toolsJson: toolsJson,
          selectedToolId: selectedToolId,
          updatedAt: updatedAt,
          createdAt: createdAt,
        );

    try {
      await sync.upsertPreferences(payload);
      _remoteCache = DrawingToolPreferencesRemoteModel(
        userId: userId,
        toolsJson: toolsJson,
        selectedToolId: selectedToolId,
        createdAt: createdAt,
        updatedAt: payload.updatedAt,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Fehler beim Synchronisieren der Werkzeug-Voreinstellungen: $error\n$stackTrace',
      );
    }
  }

  Future<DrawingToolPreferencesRemoteModel?> _loadRemotePreferences() async {
    final DrawingToolPreferencesSync? sync = _syncService;
    final String? userId = _resolveUserId();
    if (sync == null || userId == null) {
      return null;
    }

    final DrawingToolPreferencesRemoteModel? cached = _remoteCache;
    if (cached != null && cached.userId == userId) {
      return cached;
    }

    try {
      final DrawingToolPreferencesRemoteModel? remote = await sync
          .fetchPreferences(userId);
      if (remote != null) {
        _remoteCache = remote;
      }
      return remote;
    } catch (error, stackTrace) {
      debugPrint(
        'Fehler beim Laden der entfernten Werkzeug-Voreinstellungen: $error\n$stackTrace',
      );
      return null;
    }
  }

  String? _resolveUserId() {
    final AuthController? auth = _authController;
    if (auth == null || !auth.isLoggedIn) {
      return null;
    }
    final user = auth.user;
    return user?.$id;
  }
}
