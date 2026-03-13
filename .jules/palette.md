## 2024-05-24 - Auto-Capitalization für Mobile TextFields
**Erkenntnis:** In der App fehlte bei fast allen `TextField`s für Titel, Prompts und Freitext die automatische Großschreibung. Auf mobilen Tastaturen führt das zu einer schlechten UX, da der Nutzer den ersten Buchstaben manuell groß schreiben muss.
**Aktion:** Immer `textCapitalization: TextCapitalization.sentences` (oder `.words` für spezifische Titel) zu `TextField`s hinzufügen, die für natürliche Sprache oder Titel gedacht sind, um die mobile Eingabe flüssiger zu machen.
