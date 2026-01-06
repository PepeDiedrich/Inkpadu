## 2024-05-23 - Lazy Building of Recursive Lists

**Learning:** deeply nested recursive widget building (e.g. for a file tree or note hierarchy) can cause significant performance issues if done eagerly. Even if the widgets are not displayed (e.g. inside a collapsed section), creating the Widget objects themselves consumes memory and CPU.

**Action:** Use a "Lazy Builder" pattern for recursive trees. Instead of passing a list of pre-built `children` Widgets, pass the data model (`List<Node>`) and a `childBuilder` function. Build the widgets only when the parent is expanded.

## 2024-05-24 - Avoiding O(N) Allocations in Getters

**Learning:** `List.unmodifiable(list)` always creates a NEW list (and iterates the source), which is an O(N) operation. Using this inside a getter that is called frequently (e.g., inside a `build` method or `paint` loop) causes massive garbage generation and CPU overhead.

**Action:** Cache the unmodifiable view in the state object (Controller/Model) and invalidate it only when the underlying data changes. Avoid calling `List.unmodifiable` in hot loops or getters.
