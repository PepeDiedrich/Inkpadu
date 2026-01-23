## 2024-05-23 - Lazy Building of Recursive Lists

**Learning:** deeply nested recursive widget building (e.g. for a file tree or note hierarchy) can cause significant performance issues if done eagerly. Even if the widgets are not displayed (e.g. inside a collapsed section), creating the Widget objects themselves consumes memory and CPU.

**Action:** Use a "Lazy Builder" pattern for recursive trees. Instead of passing a list of pre-built `children` Widgets, pass the data model (`List<Node>`) and a `childBuilder` function. Build the widgets only when the parent is expanded.

## 2024-05-24 - Avoiding O(N) Allocations in Getters

**Learning:** `List.unmodifiable(list)` always creates a NEW list (and iterates the source), which is an O(N) operation. Using this inside a getter that is called frequently (e.g., inside a `build` method or `paint` loop) causes massive garbage generation and CPU overhead.

**Action:** Cache the unmodifiable view in the state object (Controller/Model) and invalidate it only when the underlying data changes. Avoid calling `List.unmodifiable` in hot loops or getters.

## 2024-05-25 - Caching Bounds for Canvas Resizing

**Learning:** Iterating through all points of all strokes (O(TotalPoints)) to calculate the required canvas height causes significant UI jank on the main thread (20ms+ for 1000 strokes) whenever a stroke is completed.

**Action:** Use cached `Stroke.boundingBox` (O(1) access) to reduce complexity to O(Strokes). Ensure to skip empty strokes. This reduces calculation time from ~23ms to ~0.4ms (50x speedup).
