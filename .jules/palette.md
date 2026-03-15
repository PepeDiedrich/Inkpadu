## 2024-05-18 - Textfeld-Eingabe optimieren
**Erkenntnis:** Textfelder für Freitext (Titel, Inhalte) auf mobilen Geräten benötigen standardmäßig keine manuelle Großschreibung. Das Weglassen von `textCapitalization` zwingt den Nutzer zu unnötigen Tipp-Vorgängen.
**Aktion:** Immer `textCapitalization: TextCapitalization.sentences` (oder `.words`) für Textfelder verwenden, die natürliche Sprache aufnehmen, um den Flow zu verbessern.
