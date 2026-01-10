## 2024-05-22 - ListView Visibility in Tests
**Learning:** `ListView` (and other scrollables) in Flutter tests may not render off-screen children, causing `find.text` to fail even if the widget is logically present in the list. This is true even for non-lazy `ListView` constructors if they use `SliverList`.
**Action:** When testing long lists, explicitly resize the view using `tester.view.physicalSize = const Size(width, largeHeight);` (and reset in tearDown) or use `tester.dragUntilVisible` / `tester.scrollUntilVisible`.

## 2024-05-22 - Testing with Slang Translations
**Learning:** This app uses `slang` for i18n. To test widgets that rely on `context.t`, wrap the test widget in `TranslationProvider` and ensure `LocaleSettings.setLocale` is called in `setUpAll`.
**Action:** Use the `TranslationProvider` wrapper pattern in `pumpWidget`.
