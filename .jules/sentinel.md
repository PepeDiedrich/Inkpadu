## 2025-05-22 - Layout Overflow in Tests
**Learning:** `EditorSettingsPage` (and similar settings pages) caused `RenderFlex` overflow errors in widget tests because they lacked `SingleChildScrollView` around the main `Column`. This is a common issue when testing on standard test viewports (800x600).
**Action:** Always wrap scrollable content (like settings forms) in `SingleChildScrollView`. In tests, if overflow occurs, fix the widget first. Also, consider increasing `tester.view.physicalSize` for full-page screenshots or interactions, but the widget itself should be responsive.

## 2025-05-22 - Localization Testing
**Learning:** When testing widgets with `slang` (`TranslationProvider`), `find.text()` fails if the string doesn't match the *exact* localization value (including case, dots, etc.). The English translations in `lib/i18n/en.i18n.json` are the source of truth.
**Action:** Always verify the exact string values in `en.i18n.json` before writing expectations. Do not guess based on variable names (e.g., `enableDebugMode` vs "Enable debug mode").

## 2025-05-22 - Testing Animated Visibility
**Learning:** `AnimatedCrossFade` keeps both children in the widget tree during animation (and potentially after, depending on implementation). `find.text()` will find them even if invisible.
**Action:** Use `.hitTestable()` to verify if a widget is truly interactive/visible to the user, or check specific properties like `Opacity`.
