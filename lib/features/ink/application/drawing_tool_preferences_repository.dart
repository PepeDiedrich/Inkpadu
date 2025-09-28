import 'dart:convert';

import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistiert benutzerdefinierte Zeichenwerkzeuge.
class DrawingToolPreferencesRepository {
  /// Erstellt das Repository und erlaubt ein optionales [SharedPreferences]
  ///-Mock für Tests.
  const DrawingToolPreferencesRepository({SharedPreferences? sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  /// Überschreibt die verwendete [SharedPreferences]-Instanz (z. B. in Tests).
  final SharedPreferences? _sharedPreferences;

  static const String _storageKey = 'drawing_tools_v1';
  static const String _selectedToolKey = 'drawing_selected_tool_v1';

  /// Lädt gespeicherte Werkzeuge und merged sie mit den [defaults].
  Future<List<DrawingTool>> load(List<DrawingTool> defaults) async {
    try {
      final SharedPreferences prefs =
          _sharedPreferences ?? await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_storageKey);
      if (raw == null) {
        return defaults;
      }

      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) {
        return defaults;
      }

      final List<DrawingTool> stored = <DrawingTool>[];
      for (final dynamic entry in decoded) {
        if (entry is! Map<String, dynamic>) {
          continue;
        }
        try {
          stored.add(DrawingTool.fromJson(entry));
        } catch (error, stackTrace) {
          debugPrint(
            'Fehler beim Parsen eines gespeicherten Werkzeugs: $error\n$stackTrace',
          );
        }
      }

      if (stored.isEmpty) {
        return defaults;
      }

      return _mergeWithDefaults(defaults, stored);
    } catch (error, stackTrace) {
      debugPrint(
        'Fehler beim Laden der Werkzeug-Voreinstellungen: $error\n$stackTrace',
      );
      return defaults;
    }
  }

  /// Speichert die übergebenen [tools] persistent.
  Future<void> save(List<DrawingTool> tools) async {
    try {
      final SharedPreferences prefs =
          _sharedPreferences ?? await SharedPreferences.getInstance();
      final String payload = jsonEncode(
        tools.map((tool) => tool.toJson()).toList(growable: false),
      );
      await prefs.setString(_storageKey, payload);
    } catch (error, stackTrace) {
      debugPrint(
        'Fehler beim Speichern der Werkzeug-Voreinstellungen: $error\n$stackTrace',
      );
    }
  }

  /// Speichert die aktuell ausgewählte Werkzeug-ID persistent.
  Future<void> saveSelectedToolId(String toolId) async {
    try {
      final SharedPreferences prefs =
          _sharedPreferences ?? await SharedPreferences.getInstance();
      await prefs.setString(_selectedToolKey, toolId);
    } catch (error, stackTrace) {
      debugPrint(
        'Fehler beim Speichern der Werkzeugauswahl: $error\n$stackTrace',
      );
    }
  }

  /// Lädt die zuletzt gespeicherte Werkzeug-ID.
  Future<String?> loadSelectedToolId() async {
    try {
      final SharedPreferences prefs =
          _sharedPreferences ?? await SharedPreferences.getInstance();
      return prefs.getString(_selectedToolKey);
    } catch (error, stackTrace) {
      debugPrint('Fehler beim Laden der Werkzeugauswahl: $error\n$stackTrace');
      return null;
    }
  }

  List<DrawingTool> _mergeWithDefaults(
    List<DrawingTool> defaults,
    List<DrawingTool> stored,
  ) => defaults
      .map((tool) {
        DrawingTool? match;
        for (final DrawingTool candidate in stored) {
          if (candidate.id == tool.id) {
            match = candidate;
            break;
          }
        }
        if (match == null) {
          return tool;
        }
        return DrawingTool(
          id: tool.id,
          label: match.label,
          icon: match.icon,
          color: match.color,
          baseWidth: match.baseWidth,
          isHighlighter: tool.isHighlighter,
          isEraser: tool.isEraser,
          usePressure: match.usePressure,
        );
      })
      .toList(growable: false);
}
