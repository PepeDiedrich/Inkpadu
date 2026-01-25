## 2024-05-23 - Lazy Building of Recursive Lists

**Learning:** deeply nested recursive widget building (e.g. for a file tree or note hierarchy) can cause significant performance issues if done eagerly. Even if the widgets are not displayed (e.g. inside a collapsed section), creating the Widget objects themselves consumes memory and CPU.

**Action:** Use a "Lazy Builder" pattern for recursive trees. Instead of passing a list of pre-built `children` Widgets, pass the data model (`List<Node>`) and a `childBuilder` function. Build the widgets only when the parent is expanded.

## 2024-05-24 - Avoiding O(N) Allocations in Getters

**Learning:** `List.unmodifiable(list)` always creates a NEW list (and iterates the source), which is an O(N) operation. Using this inside a getter that is called frequently (e.g., inside a `build` method or `paint` loop) causes massive garbage generation and CPU overhead.

**Action:** Cache the unmodifiable view in the state object (Controller/Model) and invalidate it only when the underlying data changes. Avoid calling `List.unmodifiable` in hot loops or getters.

## 2024-05-25 - O(TotalPoints) vs O(Strokes) Layout Calculation

**Learning:** Iterating over all points of all strokes to determine canvas height in `_requiredCanvasHeightForStrokes` was an O(TotalPoints) operation, running on every drag event. This caused significant overhead (11ms+ for 100k points). Using cached `boundingBox` reduced this to O(Strokes), yielding a ~500x speedup.

**Action:** Always leverage cached properties (like `boundingBox` or `path`) on heavy domain objects instead of re-calculating them in layout or paint loops. Profile layout calculations that scale with user input size.
