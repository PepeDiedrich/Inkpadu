## 2024-05-23 - [Bottom Sheets & Scrolling]
**Learning:** `DrawingToolEditorSheet` and similar bottom sheets use `PageStorageKey` for their scroll views. `scrollUntilVisible` can fail with "Too many elements" if the finder is not specific enough to the scrollable.
**Action:** Use `tester.drag(find.byKey(theKey), const Offset(0, -1000))` to scroll reliably, or explicitly target the scrollable in `scrollUntilVisible` using `find.descendant` (though drag is often simpler). Also, ensure `tester.view.physicalSize` is large enough for bottom sheets to render fully if needed, or scroll to interact.
