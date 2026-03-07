
## $(date +%Y-%m-%d) - Extracted HomePage widgets
**Erkenntnis:** Riesige `build`-Methoden mit inline `ListView.builder` und `GridView.builder` führen zu schwer wartbarem Code. Enums, die innerhalb von Widgets definiert sind, erschweren zudem die Extraktion von Teil-Widgets.
**Aktion:** Inline-Listen in eigenständige `StatelessWidget`-Klassen in einer separaten Datei ausgelagert. Das private Enum `_SortOption` wurde public gemacht (`SortOption`), um als saubere Parameter-Signatur für die ausgelagerten Widgets zu dienen.
