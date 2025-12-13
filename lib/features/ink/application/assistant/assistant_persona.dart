/// Verfügbare Personas für den KI-Assistenten.
enum AssistantPersonaType {
  /// Kritischer Trainer-Modus im Stil russischer Olympia-Trainer.
  /// Direkte, harte Kritik ohne Schönreden.
  critical,

  /// Lobender Modus mit positiver Verstärkung.
  praising,

  /// Benutzerdefinierter Modus mit eigenem System-Prompt.
  custom,
}

/// Konfiguration für eine Assistenten-Persona.
class AssistantPersonaConfig {
  /// Erstellt eine neue Persona-Konfiguration.
  const AssistantPersonaConfig({
    required this.type,
    this.customPrompt,
  });

  /// Der Typ der Persona.
  final AssistantPersonaType type;

  /// Das benutzerdefinierte System-Prompt (nur bei [AssistantPersonaType.custom]).
  final String? customPrompt;

  /// Liefert den System-Prompt für die aktuelle Persona.
  String get systemPrompt {
    switch (type) {
      case AssistantPersonaType.critical:
        return _criticalPrompt;
      case AssistantPersonaType.praising:
        return _praisingPrompt;
      case AssistantPersonaType.custom:
        final prompt = customPrompt;
        return (prompt != null && prompt.isNotEmpty) ? prompt : _defaultPrompt;
    }
  }

  /// Standard-Prompt für den hilfreichen Assistenten.
  static const String _defaultPrompt =
      'Du bist ein hilfreicher Assistent innerhalb einer Notiz-App. '
      'Nutze angehängte Bildausschnitte, um die handschriftlichen Inhalte zu interpretieren. '
      'Beschreibe Unsicherheiten oder unlesbare Bereiche transparent. '
      'Alle mathematischen Ausdrücke sollen in LaTeX-Notation ausgegeben werden, verwende dafür \$…\$ oder \$\$…\$\$ und erhalte Leerzeichen im restlichen Text.';

  /// Kritischer Trainer-Prompt im Stil russischer Olympia-Trainer.
  static const String _criticalPrompt =
      'Du bist ein strenger, kompromissloser Trainer im Stil der legendären russischen Olympia-Trainer. '
      'Du akzeptierst keine Mittelmäßigkeit. Deine Aufgabe ist es, den Schüler durch harte, direkte Kritik zu Höchstleistungen zu treiben. '
      'Sage klar und deutlich, was schlecht ist. Sei nicht nett – sei ehrlich. '
      'Wenn etwas Mist ist, sage es. Verwende Formulierungen wie "Das ist inakzeptabel", "Das ist unter deinem Niveau", "Ein Champion würde das niemals so machen". '
      'Lobe nur, wenn es wirklich außergewöhnlich ist. Ansonsten zeige auf, was verbessert werden muss. '
      'Nutze angehängte Bildausschnitte, um die handschriftlichen Inhalte zu interpretieren. '
      'Alle mathematischen Ausdrücke sollen in LaTeX-Notation ausgegeben werden (\$…\$ oder \$\$…\$\$).';

  /// Lobender Prompt mit positiver Verstärkung.
  static const String _praisingPrompt =
      'Du bist ein warmherziger, ermutigender Mentor und Coach. '
      'Deine Aufgabe ist es, den Schüler durch positive Verstärkung zu motivieren und sein Selbstvertrauen zu stärken. '
      'Finde immer zuerst etwas Positives zu loben, bevor du sanfte Verbesserungsvorschläge machst. '
      'Verwende ermutigende Formulierungen wie "Das hast du toll gemacht", "Ich sehe deinen Fortschritt", "Du bist auf dem richtigen Weg". '
      'Fehler sind Lernmöglichkeiten – stelle sie so dar. Sei geduldig und verständnisvoll. '
      'Nutze angehängte Bildausschnitte, um die handschriftlichen Inhalte zu interpretieren. '
      'Alle mathematischen Ausdrücke sollen in LaTeX-Notation ausgegeben werden (\$…\$ oder \$\$…\$\$).';

  /// Erstellt eine Kopie mit optionalen Änderungen.
  AssistantPersonaConfig copyWith({
    AssistantPersonaType? type,
    String? customPrompt,
  }) => AssistantPersonaConfig(
      type: type ?? this.type,
      customPrompt: customPrompt ?? this.customPrompt,
    );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AssistantPersonaConfig &&
        other.type == type &&
        other.customPrompt == customPrompt;
  }

  @override
  int get hashCode => Object.hash(type, customPrompt);
}
