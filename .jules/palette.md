## 2024-05-28 - Auto-Capitalization für Texteingaben
**Erkenntnis:** TextFields für Titel oder freie Texteingaben auf mobilen Geräten erfordern explizit `textCapitalization: TextCapitalization.sentences` (oder `.words`), da sonst Nutzer zur manuellen Großschreibung gezwungen werden, was den Flow stört.
**Aktion:** Bei zukünftigen Implementierungen von Textfeldern für Namen/Titel standardmäßig Auto-Capitalization aktivieren.
