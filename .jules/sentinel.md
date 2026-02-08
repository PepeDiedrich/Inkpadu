## 2024-05-24 - Testing SQLite with sqflite_common_ffi
**Learning:** To test `sqflite` based classes like `InkNotesLocalStorage`, we need `sqflite_common_ffi`. We must initialize it in `setUpAll` using `sqfliteFfiInit()` and `databaseFactory = databaseFactoryFfi`. Also, `getDatabasesPath()` returns a local directory in the FFI environment, so we must clean up the database file manually (e.g. `deleteDatabase(path)`) in `setUp` to ensure test isolation.
**Action:** Always include `sqflite_common_ffi` setup in `setUpAll` and clean DB in `setUp` for local storage tests.
