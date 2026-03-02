import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Legt fest, auf welcher Seite das Editor-Seitenpanel angezeigt wird.
enum EditorSidebarSide {
  /// Panel befindet sich links neben der Zeichenfläche (empfohlen für Rechtshänder:innen).
  left,

  /// Panel befindet sich rechts neben der Zeichenfläche (empfohlen für Linkshänder:innen).
  right,
}

/// Repräsentiert einen KI-Prompt mit ID, Titel und dem eigentlichen Prompt-Text.
class AiPrompt {
  /// Erstellt einen neuen [AiPrompt].
  const AiPrompt({required this.id, required this.title, required this.prompt});

  /// Die eindeutige ID des Prompts.
  final String id;

  /// Der Titel des Prompts.
  final String title;

  /// Der eigentliche Prompt-Text.
  final String prompt;

  /// Konvertiert den Prompt in ein JSON-Format.
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'prompt': prompt};

  /// Erstellt einen [AiPrompt] aus einem JSON-Format.
  factory AiPrompt.fromJson(Map<String, dynamic> json) => AiPrompt(
    id: json['id'] as String,
    title: json['title'] as String,
    prompt: json['prompt'] as String,
  );
}

/// Einstellungen für den Notiz-Editor.
class EditorSettings extends ChangeNotifier {
  /// Erstellt neue [EditorSettings] mit optionalen Vorgaben und lädt vom Speicher.
  EditorSettings({
    this.sidebarSide = EditorSidebarSide.right,
    this.lineSimplifierEnabled = true,
    this.lineSimplifierStrength = 0.25,
    this.lineSimplifierMinTolerance = 0.3,
    this.debugModeEnabled = false,
    this.aiSystemPrompt = '',
    this.aiPrompts = const [],
  }) {
    _loadFromPrefs();
  }

  static const String _prefKeyDb = 'editor_settings_';

  /// `true`, wenn Debug-Overlays im Editor angezeigt werden sollen.
  bool debugModeEnabled;

  /// Aktuell gewählte Seite des Assistenz-Panels.
  EditorSidebarSide sidebarSide;

  /// `true`, wenn der Linien-Simplifier aktiv ist.
  bool lineSimplifierEnabled;

  /// Faktor zur Berechnung der Simplifier-Toleranz relativ zur Strichbreite.
  /// Wertebereich: 0.05 (sehr weich) bis 0.8 (sehr hart).
  double lineSimplifierStrength;

  /// Minimaler Toleranzwert in Pixeln zur Vereinfachung.
  /// Wertebereich: >= 0.05.
  double lineSimplifierMinTolerance;

  /// Liste der benutzerdefinierten AI-Prompts.
  List<AiPrompt> aiPrompts;

  /// Optionales System-Prompt für den KI-Assistenten.
  String aiSystemPrompt;

  /// Convenience: `true`, wenn das Panel links erscheinen soll.
  bool get isPanelOnLeft => sidebarSide == EditorSidebarSide.left;

  /// Convenience: `true`, wenn das Panel rechts erscheinen soll.
  bool get isPanelOnRight => sidebarSide == EditorSidebarSide.right;

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final sideIndex = prefs.getInt('${_prefKeyDb}sidebarSide');
      if (sideIndex != null &&
          sideIndex >= 0 &&
          sideIndex < EditorSidebarSide.values.length) {
        sidebarSide = EditorSidebarSide.values[sideIndex];
      }

      lineSimplifierEnabled =
          prefs.getBool('${_prefKeyDb}lineSimplifierEnabled') ??
          lineSimplifierEnabled;
      lineSimplifierStrength =
          prefs.getDouble('${_prefKeyDb}lineSimplifierStrength') ??
          lineSimplifierStrength;
      lineSimplifierMinTolerance =
          prefs.getDouble('${_prefKeyDb}lineSimplifierMinTolerance') ??
          lineSimplifierMinTolerance;
      debugModeEnabled =
          prefs.getBool('${_prefKeyDb}debugModeEnabled') ?? debugModeEnabled;
      aiSystemPrompt =
          prefs.getString('${_prefKeyDb}aiSystemPrompt') ?? aiSystemPrompt;

      final aiPromptsJson = prefs.getStringList('${_prefKeyDb}aiPrompts');
      if (aiPromptsJson != null) {
        aiPrompts = aiPromptsJson
            .map((jsonStr) {
              try {
                return AiPrompt.fromJson(
                  jsonDecode(jsonStr) as Map<String, dynamic>,
                );
              } catch (_) {
                return null;
              }
            })
            .whereType<AiPrompt>()
            .toList();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load EditorSettings: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('${_prefKeyDb}sidebarSide', sidebarSide.index);
      await prefs.setBool(
        '${_prefKeyDb}lineSimplifierEnabled',
        lineSimplifierEnabled,
      );
      await prefs.setDouble(
        '${_prefKeyDb}lineSimplifierStrength',
        lineSimplifierStrength,
      );
      await prefs.setDouble(
        '${_prefKeyDb}lineSimplifierMinTolerance',
        lineSimplifierMinTolerance,
      );
      await prefs.setBool('${_prefKeyDb}debugModeEnabled', debugModeEnabled);
      await prefs.setString('${_prefKeyDb}aiSystemPrompt', aiSystemPrompt);

      final aiPromptsJsonList = aiPrompts
          .map((p) => jsonEncode(p.toJson()))
          .toList();
      await prefs.setStringList('${_prefKeyDb}aiPrompts', aiPromptsJsonList);
    } catch (e) {
      debugPrint('Failed to save EditorSettings: $e');
    }
  }

  /// Aktualisiert einzelne Properties und benachrichtigt Listener.
  void update({
    EditorSidebarSide? sidebarSide,
    bool? lineSimplifierEnabled,
    double? lineSimplifierStrength,
    double? lineSimplifierMinTolerance,
    bool? debugModeEnabled,
    String? aiSystemPrompt,
    List<AiPrompt>? aiPrompts,
  }) {
    var hasChanged = false;
    if (sidebarSide != null && sidebarSide != this.sidebarSide) {
      this.sidebarSide = sidebarSide;
      hasChanged = true;
    }
    if (lineSimplifierEnabled != null &&
        lineSimplifierEnabled != this.lineSimplifierEnabled) {
      this.lineSimplifierEnabled = lineSimplifierEnabled;
      hasChanged = true;
    }
    if (lineSimplifierStrength != null &&
        lineSimplifierStrength != this.lineSimplifierStrength) {
      this.lineSimplifierStrength = lineSimplifierStrength.clamp(0.05, 0.8);
      hasChanged = true;
    }
    if (lineSimplifierMinTolerance != null &&
        lineSimplifierMinTolerance != this.lineSimplifierMinTolerance) {
      this.lineSimplifierMinTolerance = lineSimplifierMinTolerance.clamp(
        0.05,
        double.infinity,
      );
      hasChanged = true;
    }
    if (debugModeEnabled != null && debugModeEnabled != this.debugModeEnabled) {
      this.debugModeEnabled = debugModeEnabled;
      hasChanged = true;
    }
    if (aiSystemPrompt != null && aiSystemPrompt != this.aiSystemPrompt) {
      this.aiSystemPrompt = aiSystemPrompt;
      hasChanged = true;
    }
    if (aiPrompts != null) {
      this.aiPrompts = aiPrompts;
      hasChanged = true;
    }
    if (hasChanged) {
      _saveToPrefs();
      notifyListeners();
    }
  }
}

/// Ermöglicht globalen Zugriff auf [EditorSettings].
class EditorSettingsScope extends InheritedNotifier<EditorSettings> {
  /// Erstellt einen neuen Scope.
  const EditorSettingsScope({
    super.key,
    required EditorSettings settings,
    required super.child,
  }) : super(notifier: settings);

  /// Liefert die [EditorSettings] aus dem Kontext.
  static EditorSettings of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<EditorSettingsScope>();
    assert(scope != null, 'EditorSettingsScope nicht im Widget-Tree gefunden');
    return scope!.notifier!;
  }

  @override
  bool updateShouldNotify(
    covariant InheritedNotifier<EditorSettings> oldWidget,
  ) => true;
}
