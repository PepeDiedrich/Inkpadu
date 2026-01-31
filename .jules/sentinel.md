## 2024-05-23 - Testing Navigation and Scrolling **Learning:**
1.  **Navigation Testing:** When testing a widget that defines `home` AND `routes` with `/` mapped, `MaterialApp` ignores `home` and renders the `/` route. Use `initialRoute` instead of `home` in tests if `/` is in routes.
2.  **Scrollable Testing:** `scrollUntilVisible` requires a `Finder` that finds a `Scrollable` widget. `find.byType(ListView)` finds the wrapper, not the `Scrollable`. Use `find.byType(Scrollable)` or `find.descendant(of: ..., matching: find.byType(Scrollable))`.
3.  **Localization:** Verify exact strings. "AI Features" vs "AI Assistant" caused confusion.
4.  **Overflows:** `RenderFlex overflow` in tests indicates real UI bugs. Fix them (e.g. wrap in `SingleChildScrollView`).
**Action:** Always check `MaterialApp` route config in tests. Use robust Finders for scrollables. Verify strings in `i18n` files.
