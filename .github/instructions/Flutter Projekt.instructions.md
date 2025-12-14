---
applyTo: '**'
---
rules:
  # --- PERFORMANCE-REGELN ---

  - name: UseConstConstructors
    description: "Performance: Empfiehlt die Verwendung von `const` für Widget-Konstruktoren, um unnötige Rebuilds zu vermeiden."
    languages: [dart]
    recommendation: |
      Verwende `const` für diesen Widget-Konstruktor.
      'const'-Widgets werden nur einmal erstellt und bei jedem Rebuild wiederverwendet. Das ist die einfachste und effektivste Performance-Optimierung in Flutter.
    do_not:
      - "return Text('{{...}}');"
      - "return Icon(Icons.{{...}});"
      - "return Padding(padding: EdgeInsets.all({{...}}), child: {{...}});"
      - "return Center(child: {{...}});"

  - name: PreferListViewBuilder
    description: "Performance: Schlägt `ListView.builder` für dynamische Listen vor, anstatt eine Liste von Widgets direkt zu übergeben."
    languages: [dart]
    recommendation: |
      Für eine bessere Performance, besonders bei langen Listen, solltest du `ListView.builder` verwenden.
      Dieser Konstruktor baut nur die Elemente, die aktuell auf dem Bildschirm sichtbar sind ("lazy loading").
    do_not:
      - "ListView(children: {{variable}}.map((item) => {{Widget}}(item)).toList())"

  # --- CODE-QUALITÄT & KONVENTIONEN ---

  - name: PreferFinalForLocals
    description: "Code-Qualität: Empfiehlt `final` für lokale Variablen, die nach der Initialisierung nicht mehr verändert werden."
    languages: [dart]
    recommendation: |
      Diese Variable wird nicht neu zugewiesen. Deklariere sie als `final`, um den Code sicherer und lesbarer zu machen.
    do_not:
      - "{{type}} {{variable}} = {{value}};"

  - name: AddDocumentationComments
    description: "Konventionen: Erinnert daran, öffentliche Klassen und Methoden mit Doc-Kommentaren zu versehen."
    languages: [dart]
    severity: suggestion
    recommendation: |
      Füge einen Dokumentationskommentar (`///`) hinzu, um den Zweck dieser Klasse oder Methode zu erklären.
      Gute Dokumentation hilft dir und anderen, den Code später besser zu verstehen.
    do_not:
      - "class {{ClassName}} {{...}} {"
      - "{{returnType}} {{methodName}}({{...}}) {"

  - name: UseObjectOrientedDrawingStructure
    description: "Code-Qualität: Empfiehlt die Verwendung von objektorientierten Datenstrukturen anstelle von rohen Listen für Zeichnungsdaten."
    languages: [dart]
    recommendation: |
      Anstatt `List<List<Offset?>>` zu verwenden, solltest du Klassen wie `DrawingPoint`, `Stroke` und `NotePage` definieren.
      Dies kapselt Daten (wie Farbe, Strichstärke) mit der Logik, macht den Code erweiterbar (z.B. für Undo/Redo) und verbessert die Lesbarkeit und Wartbarkeit.
    do_not:
      - "List<List<Offset?>> paths;"
      - "List<List<Offset>> strokes;"

  # --- LOKALISIERUNG (i18n) ---

  - name: UseLocalizedStrings
    description: "Lokalisierung: ALLE sichtbaren Texte MÜSSEN über das slang-Übersetzungssystem (`context.t.xxx`) eingefügt werden."
    languages: [dart]
    severity: error
    recommendation: |
      NIEMALS hardcoded Strings für UI-Texte verwenden!
      
      **So geht's richtig:**
      1. Füge den neuen String zu `lib/i18n/en.i18n.json` hinzu (Englisch als Basissprache)
      2. Füge die deutsche Übersetzung zu `lib/i18n/de.i18n.json` hinzu
      3. Führe `dart run slang` aus, um die Dart-Dateien zu generieren
      4. Verwende im Code: `context.t.section.keyName`
      
      **Beispiel:**
      ```json
      // en.i18n.json
      {
        "common": {
          "save": "Save",
          "cancel": "Cancel"
        }
      }
      ```
      
      ```dart
      // Im Widget
      Text(context.t.common.save)  // ✅ Richtig
      Text('Speichern')            // ❌ Falsch!
      ```
      
      **Für Strings mit Parametern:**
      ```json
      {
        "notes": {
          "deleteConfirm(title)": "Delete \"${title}\"?"
        }
      }
      ```
      ```dart
      Text(context.t.notes.deleteConfirm(title: note.title))
      ```
    do_not:
      - "Text('{{German text}}')"
      - "label: '{{German text}}'"
      - "title: '{{German text}}'"
      - "subtitle: '{{German text}}'"
      - "hintText: '{{German text}}'"
      - "labelText: '{{German text}}'"
      - "tooltip: '{{German text}}'"

  - name: LocalizationFileStructure
    description: "Lokalisierung: Beschreibt die Struktur der Übersetzungsdateien."
    languages: [json]
    recommendation: |
      Die Übersetzungsdateien befinden sich in `lib/i18n/`.
      
      **Verfügbare Sektionen:**
      - `app`: App-Name und Tagline
      - `common`: Häufig verwendete Texte (Save, Cancel, Delete, etc.)
      - `auth`: Login/Logout-bezogene Texte
      - `notes`: Notiz-bezogene Texte
      - `drawing`: Zeichenwerkzeug-bezogene Texte
      - `ai`: KI-Feature-bezogene Texte
      - `pdf`: PDF-Import/Export-bezogene Texte
      - `settings`: Einstellungsseite-bezogene Texte
      - `errors`: Fehlermeldungen
      - `onboarding`: Onboarding-Seite-bezogene Texte
      - `editor`: Editor-Einstellungen und Persona-bezogene Texte
      - `pdfDialog`: PDF-Dialog-bezogene Texte
      
      **Neue Sektion hinzufügen:**
      Wenn du eine neue Feature-Sektion brauchst, füge sie zu denn Sprachdateien hinzu:
      - en.i18n.json (Englisch - Pflicht)
      - de.i18n.json (Deutsch - Pflicht)

# --- DESIGN-RICHTLINIEN ---

Hintergrund (Dark Mode): Sehr dunkles Blau (#1A2A3A)

Hintergrund (Light Mode): Helles Grau/Off-White (#F5F5F5)

Textfarbe: Helles Grau auf dunklem Grund (#E0E0E0), dunkles Grau auf hellem Grund (#333333)

Primäre Akzentfarbe: Ein warmer Goldton (#FFC107)

Sekundäre Akzentfarbe: Ein sanftes Grün (#2ECC71)

Keep the UI simple and clean.
Good balance between known icon and text.
