
## 2024-03-05 - TextField Auto-Capitalization for Mobile UX
**Erkenntnis:** By default, Flutter's `TextField` lacks automatic capitalization, which negatively impacts mobile UX in free-text fields like titles or note bodies where users expect auto-capitalization (e.g., at the start of sentences or words).
**Aktion:** Always explicitly set `textCapitalization: TextCapitalization.sentences` (or `.words`) in `TextField` widgets used for titles, names, or general descriptions to provide a native, frictionless mobile typing experience.
