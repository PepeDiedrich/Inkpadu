## 2026-03-16 - Semantics in custom selection widgets
**Erkenntnis:** Custom selection elements (like the paper style options built with `InkWell` and `Container`) lack default semantics. Screen readers won't announce their role or selection state.
**Aktion:** Wrap custom interactive elements in `Semantics(button: true, selected: isActive, label: '<descriptive_label>')` to ensure accessibility.
