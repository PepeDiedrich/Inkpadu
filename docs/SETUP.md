# Inkpadu setup guide

This guide builds a private, working backend for Inkpadu without placing a credential in source control. Keep production values in your CI secret store, shell environment or local untracked configuration.

## 1. Prerequisites

- Flutter and a current Android SDK; `flutter doctor` should report an Android toolchain.
- An Appwrite project (self-hosted or Appwrite Cloud).
- A Gemini API key reserved for the Appwrite Function, not for the mobile app.
- Optional: GitHub and/or Google OAuth applications.

```bash
flutter pub get
flutter test
```

## 2. Create the Appwrite project

1. Create a project and note its endpoint and project ID.
2. Add an Android platform with package name `com.inkpadu.app`.
3. Add the desktop and web origins you actually use; do not use wildcards in production.
4. In **Auth**, enable only the OAuth providers you intend to offer. Copy the callback URLs supplied by Appwrite into the corresponding GitHub or Google OAuth application.
5. Grant every note document and PDF file permissions only for its owning user. The client creates `read`, `update` and `delete` permissions for that user.

## 3. Provision the data model

Create database `inkpadu-db` with the following collections and attributes. Attribute names must match exactly because the client sends these keys.

### `ink-notes`

One document per note; the document ID is the note ID.

| Attribute | Type |
| --- | --- |
| `user_id` | string |
| `title` | string |
| `paper_style` | string |
| `page_count` | integer |
| `last_opened_page` | integer |
| `updated_at` | datetime/string |
| `created_at` | datetime/string |
| `pdf_file_id` | optional string |

### `ink-note-pages`

One document per page, with an ID in the form `<note-id>_<page-index>`.

| Attribute | Type |
| --- | --- |
| `note_id` | string |
| `user_id` | string |
| `page_index` | integer |
| `payload` | string (large) |
| `updated_at` | datetime/string |
| `created_at` | datetime/string |

### `drawing-tool-preferences`

One document per user, using the user ID as the document ID: `user_id`, `tools_json`, optional `selected_tool_id`, `updated_at`, `created_at`.

Create bucket `note-pdfs` for PDF backgrounds. Keep client access private; files are created with user-scoped permissions. Enable realtime for the note collections if you want devices to receive changes without a manual refresh.

## 4. Configure the AI function

Deploy `backend/gemini_ai` as an Appwrite Function using a Dart runtime.

1. Set `GEMINI_API_KEY` as a **function environment variable** or secret. Never set it in Flutter, `android/`, a checked-in `.env` file or a GitHub Actions log.
2. Give the function permission to be invoked by authenticated users only.
3. Set a request-size limit compatible with a scaled PNG crop and add rate limits for your expected audience.
4. Record the function ID; it is passed to the app at build time.

The function accepts `image` (base64 PNG) and `prompt`. It returns streamed explanation text plus an optional `boxes` array. A box uses normalized `ymin`, `xmin`, `ymax`, `xmax` coordinates from `0` to `1000` and a colour such as `red`, `green` or `blue`. The client converts those coordinates to the selected canvas rectangle and renders the overlays.

## 5. Build with configuration

Use build-time values instead of changing source files:

```bash
export INKPADU_APPWRITE_CALLBACK_SCHEME='appwrite-callback-your-project-id'

flutter run \
  --dart-define=APPWRITE_ENDPOINT=https://your-appwrite.example/v1 \
  --dart-define=APPWRITE_PROJECT_ID=your-project-id \
  --dart-define=APPWRITE_AI_FUNCTION_ID=your-ai-function-id
```

For Android release builds, use the same environment variable for the callback scheme:

```bash
export INKPADU_APPWRITE_CALLBACK_SCHEME='appwrite-callback-your-project-id'
flutter build apk --release \
  --dart-define=APPWRITE_ENDPOINT=https://your-appwrite.example/v1 \
  --dart-define=APPWRITE_PROJECT_ID=your-project-id \
  --dart-define=APPWRITE_AI_FUNCTION_ID=your-ai-function-id
```

Register the resulting callback scheme in Appwrite and your OAuth provider. For desktop, Inkpadu uses `http://localhost:8350/auth-desktop`; make sure this redirect is allowed in the provider settings.

## 6. Sign release builds safely

Keep `android/key.properties` and the signing file out of Git. The repository already ignores key properties, `.jks` and `.keystore` files. Provide one of the following only in local or CI secrets:

```text
INKPADU_KEYSTORE_FILE=/secure/path/release.jks
INKPADU_KEYSTORE_PASSWORD=...
INKPADU_KEY_ALIAS=...
INKPADU_KEY_PASSWORD=...
```

Do not use the debug keystore for a store release.

## 7. Test without any backend

For screenshots, local UI development or a device demo, build the isolated test mode:

```bash
flutter build apk --debug --dart-define=INKPADU_TEST_MODE=true
```

It deliberately skips OAuth, Appwrite, background sync and the AI function. Notes remain local and the red `TESTMODUS` ribbon makes the mode visible.

## 8. Pre-publication checklist

- Run `git grep` or a secret scanner over the full Git history, not only the working tree.
- Rotate any credential that was ever committed, even if it was subsequently removed.
- Verify Appwrite collection, bucket and function permissions with a non-owner account.
- Restrict OAuth redirect URLs and Android signing credentials.
- Run `flutter test` and build a release APK before publishing.
