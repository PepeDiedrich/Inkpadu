## 2024-05-22 - [Critical] Logging in Release Mode
⚠️ Documenting a critical vulnerability where `debugPrint` was not disabled in release mode.
**Vulnerability:** `debugPrint` statements were active in release builds, potentially leaking sensitive user data (PII, tokens) and application logic to the system log (Logcat, Syslog).
**Impact:** Attackers with physical access to the device or malicious apps with log-reading permissions could extract sensitive information.
**Fix:** Implemented a global override in `lib/main.dart` to mute `debugPrint` when `kReleaseMode` is true.
```dart
if (kReleaseMode) {
  debugPrint = (String? message, {int? wrapWidth}) {};
}
```
