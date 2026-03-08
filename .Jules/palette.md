

## 2024-05-24 - AI Lasso Panel Close Button
**Erkenntnis:** Close icons in headers that are wrapped in `GestureDetector` lack hover states, tooltips, and accessibility semantics. They should be implemented using `IconButton`s instead. When converting them, padding might need to be set to `EdgeInsets.zero` and constraints to `BoxConstraints()` to maintain the layout visually while fixing the accessibility.
**Aktion:** Immer `IconButton` anstelle von reinen Icons innerhalb von `GestureDetector` für Standard-Aktionen wie Schließen verwenden.
