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