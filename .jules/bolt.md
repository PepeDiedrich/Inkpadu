## 2024-05-23 - Lazy Building of Recursive Lists

**Learning:** deeply nested recursive widget building (e.g. for a file tree or note hierarchy) can cause significant performance issues if done eagerly. Even if the widgets are not displayed (e.g. inside a collapsed section), creating the Widget objects themselves consumes memory and CPU.

**Action:** Use a "Lazy Builder" pattern for recursive trees. Instead of passing a list of pre-built `children` Widgets, pass the data model (`List<Node>`) and a `childBuilder` function. Build the widgets only when the parent is expanded.

## 2024-05-24 - Avoiding O(N) Allocations in Getters

**Learning:** `List.unmodifiable(list)` always creates a NEW list (and iterates the source), which is an O(N) operation. Using this inside a getter that is called frequently (e.g., inside a `build` method or `paint` loop) causes massive garbage generation and CPU overhead.

**Action:** Cache the unmodifiable view in the state object (Controller/Model) and invalidate it only when the underlying data changes. Avoid calling `List.unmodifiable` in hot loops or getters.

## 2024-05-25 - Pitfalls of Hoisting Widgets in AnimatedBuilder

**Learning:** Hoisting a widget (e.g. `FinishedStrokes`) out of `AnimatedBuilder`'s builder closure to prevent allocation can break functionality if that widget depends on the same animation controller but doesn't rebuild when the controller notifies. `AnimatedBuilder` passes the *static* child instance back to the builder, so if the parent widget didn't rebuild, the child widget remains stale even if the controller updated.

**Action:** Only hoist truly static widgets (like backgrounds). If a widget depends on the animation state, it must be rebuilt inside the builder (or be a separate listener).

## 2024-05-25 - Optimizing Geometric Calculations with Caching

**Learning:** Iterating over all points in a drawing app (O(TotalPoints)) to determine canvas height is a performance bottleneck. `Stroke` entities often cache their bounding box.

**Action:** Use cached `boundingBox` properties (O(Strokes)) instead of raw point iteration for geometry calculations like height or hit-testing.
