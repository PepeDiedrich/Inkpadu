## 2024-05-23 - Lazy Building of Recursive Lists

**Learning:** deeply nested recursive widget building (e.g. for a file tree or note hierarchy) can cause significant performance issues if done eagerly. Even if the widgets are not displayed (e.g. inside a collapsed section), creating the Widget objects themselves consumes memory and CPU.

**Action:** Use a "Lazy Builder" pattern for recursive trees. Instead of passing a list of pre-built `children` Widgets, pass the data model (`List<Node>`) and a `childBuilder` function. Build the widgets only when the parent is expanded.
