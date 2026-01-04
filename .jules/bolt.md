## 2024-05-23 - Lazy Building of Recursive Lists

**Learning:** deeply nested recursive widget building (e.g. for a file tree or note hierarchy) can cause significant performance issues if done eagerly. Even if the widgets are not displayed (e.g. inside a collapsed section), creating the Widget objects themselves consumes memory and CPU.

**Action:** Use a "Lazy Builder" pattern for recursive trees. Instead of passing a list of pre-built `children` Widgets, pass the data model (`List<Node>`) and a `childBuilder` function. Build the widgets only when the parent is expanded.

## 2024-05-23 - Use Cached Properties for Expensive Calculations

**Learning:** In painting or layout widgets (like `NoteThumbnail`), iterating through raw data points (e.g., all points of all strokes) in `build()` is extremely expensive (O(N*M)). If the data model already provides a cached property (e.g., `stroke.boundingBox`), use it! This reduces complexity to O(N) and leverages lazy calculation.

**Action:** Always check domain entities for cached geometric properties before manually calculating bounds or metrics in UI widgets.
