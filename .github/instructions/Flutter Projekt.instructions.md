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

Hintergrund (Dark Mode): Sehr dunkles Blau (#1A2A3A)

Hintergrund (Light Mode): Helles Grau/Off-White (#F5F5F5)

Textfarbe: Helles Grau auf dunklem Grund (#E0E0E0), dunkles Grau auf hellem Grund (#333333)

Primäre Akzentfarbe: Ein warmer Goldton (#FFC107)

Sekundäre Akzentfarbe: Ein sanftes Grün (#2ECC71)
keep the ui simple and clean.
good balance between known icon and text.
update immer das setup script in bin für appwrite wenn du änderungen an den collections machst u.s.w machst.