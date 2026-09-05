# Inkpadu — digital ink built for understanding, not just writing

Inkpadu is a cross-platform handwriting notebook for tablets and desktop. It combines a low-latency ink canvas, PDF annotation, local-first notes and an AI-assisted review workflow. The product idea is simple: learners should be able to circle a handwritten step, ask for help, and immediately see *where* the feedback applies — not receive an answer detached from the page.

This is a full Flutter project, not a UI prototype: it includes the mobile and desktop client, local persistence, synchronization, OAuth, an Appwrite backend and the AI workflow.

## At a glance

```mermaid
flowchart LR
    A[Stylus / touch input] --> B[Ink canvas]
    B --> C[Local SQLite note store]
    C --> D{Online and signed in?}
    D -->|yes| E[Durable sync queue]
    E --> F[Appwrite Databases, Storage and Realtime]
    D -->|no| G[Continue locally]
    B --> H[AI lasso selection]
    H --> I[Crop and scale selected canvas region]
    I --> J[Appwrite Function]
    J --> K[Gemini]
    K --> L[Streaming explanation + normalized coloured boxes]
    L --> M[Answer panel + canvas overlay]
```

| Notes | Paper setup | Ink editor |
| --- | --- | --- |
| ![Empty local notebook](assets/screenshots/home.png) | ![Paper style chooser](assets/screenshots/editor.png) | ![Tablet ink editor](assets/screenshots/ai-feedback.png) |

The screenshots were captured from the Android tablet build. The red `TESTMODUS` ribbon identifies the backend-free build used for device testing and demos.

## Features

- Multi-page handwritten notes with blank, lined, squared or dotted paper.
- Ink, fineliner, fountain pen, brush and highlighter; erase, select, move, undo and redo strokes.
- PDF import, annotation directly on the page and PDF export.
- Local-first persistence: notes remain usable without login or connectivity.
- GitHub and Google sign-in via Appwrite; cross-device sync after login.
- A normal lasso for editing and an **AI lasso** for guided learning.

## AI lasso: feedback anchored to the handwritten page

Chat answers alone are not enough for handwritten calculations. The hard part is connecting an explanation to the exact term, line or operation that caused the mistake. Inkpadu's AI lasso makes this relationship visible.

1. A learner circles a region on the canvas.
2. The app renders only that region to a PNG and scales it down when needed.
3. The crop and an action such as **Tipp**, **Hilfe** or **Überprüfen** go to an Appwrite Function; no Gemini key is bundled into the client.
4. The AI response is streamed into the panel, so the explanation becomes readable as it arrives instead of waiting for a completed answer.
5. In parallel, the response contains optional coloured boxes in normalized `0…1000` coordinates.
6. Inkpadu maps each box back into the original lasso bounds and paints it on the zoomable canvas. The answer uses the same colours, making feedback directly traceable to the handwriting.

```mermaid
sequenceDiagram
    participant L as Learner
    participant C as Ink canvas
    participant F as Appwrite Function
    participant AI as Gemini
    L->>C: Circle a calculation with AI lasso
    C->>C: Capture and scale selected region
    C->>F: PNG crop + guided prompt
    F->>AI: Vision / reasoning request
    AI-->>F: Stream answer and box metadata
    F-->>C: Forward streamed chunks
    C-->>L: Growing explanation + matching coloured overlays
```

This coordinate contract is deliberate. The model sees a cropped raster image, but Inkpadu has to position feedback on a zoomable vector canvas. Normalized coordinates keep the AI response independent of device resolution and crop size.

The panel is movable and resizable, supports touch, stylus, mouse and keyboard scrolling, renders LaTex mathematics, and can insert generated HTML for visual results. The workflow is designed for learning rather than an unbounded chat: the built-in prompts make it possible to ask for a hint or a review without giving away the solution too early.

## Why the ink feels fluid

Handwriting makes every performance mistake visible. A page with hundreds of strokes cannot repaint and synchronize in the same way as a simple form. I separated input, rendering, persistence and network work deliberately.

| Challenge | Engineering decision |
| --- | --- |
| Dense, long stylus strokes | Ramer-Douglas-Peucker simplification moves to a separate isolate after 250 points, keeping the UI isolate responsive. Short strokes avoid isolate overhead. |
| Repainting an entire page | Finished ink is rendered into cached `Picture` tiles. Only tiles in the current viewport are rebuilt; off-screen tiles are purged to bound memory. |
| Recomputing geometry | Completed strokes cache their `Path`; structural edits invalidate the relevant cache instead of rebuilding every path continuously. |
| Erasing and selection | A bounding-box prefilter rejects most strokes before point-in-polygon or distance calculations run. |
| Saving while writing | Changes persist locally first; remote writes are debounced, preventing a burst of stylus events from becoming a burst of requests. |
| Large note payloads | Point data uses fixed-point coordinates, delta encoding, ZigZag + VarInt, gzip and Base64. Stroke metadata remains readable JSON and legacy formats are still decoded. |

The learning here was that smooth drawing is not a single optimization. It is a set of boundaries: only the stylus path stays on the critical rendering path; simplification, compression and synchronization move out of it.

## Local-first synchronization

The notebook remains useful before a user has logged in and when a connection is unavailable. SQLite stores notes, their synchronization status and an ordered operation queue. Every edit lands locally first. When the device is online, the repository uploads pending changes, processes queued deletes, merges remote notes by timestamp and subscribes to Appwrite Realtime updates. Android additionally uses Workmanager to retry pending work in the background.

```mermaid
flowchart TD
    A[Edit note] --> B[Save locally]
    B --> C[Queue UPSERT or DELETE]
    C --> D{Backend reachable?}
    D -->|no| E[Keep working offline]
    D -->|yes| F[Process queue in order]
    F --> G[Fetch and merge remote notes]
    G --> H[Realtime updates keep device current]
```

That design is about more than caching: deleted notes must not reappear after a later merge, retries need durable state, and a network error must never block a pen stroke.

## Backend and security boundaries

```text
Flutter client
  ├─ Appwrite OAuth (GitHub / Google) → session and user identity
  ├─ SQLite → notes and durable sync queue
  ├─ Appwrite Databases / Storage → note metadata, pages and PDF assets
  ├─ Appwrite Realtime → remote updates
  └─ Appwrite Function → selected image + guided prompt
                                └─ Gemini → streamed text + coloured boxes
```

The Appwrite endpoint and project ID are build-time configuration. OAuth secrets and the Gemini key stay with their providers or in the function environment, never in the mobile bundle. Release builds suppress debug logging to avoid leaking OAuth tokens or personal note content into device logs.

## Backend-free test mode

For tablet demos, UI testing and screenshots, Inkpadu now has an explicit backend-free build:

```bash
flutter build apk --debug --dart-define=INKPADU_TEST_MODE=true
```

It creates a local demo session, skips OAuth, Appwrite and background sync, and uses only local notes. The `TESTMODUS` ribbon ensures this cannot be mistaken for a production configuration. A normal build leaves the backend integration unchanged.

## Run and validate

```bash
flutter pub get
flutter run
flutter test
flutter test integration_test/app_test.dart
```

For a configured backend, set `APPWRITE_ENDPOINT` and `APPWRITE_PROJECT_ID` through `--dart-define` (or use the configured defaults in `lib/app/auth/appwrite_config.dart`).

For the complete Appwrite, OAuth, Gemini Function, Android callback and release-signing procedure, see the [setup guide](docs/SETUP.md).

## What I learned building Inkpadu

- AI becomes useful for learning when it is grounded in a deliberate user selection and can point back to that selection.
- A responsive drawing app needs explicit rendering, memory and geometry strategy; a `CustomPainter` alone is not enough.
- Offline-first behavior is a product feature: queue semantics, merge rules and deletion handling matter most when the network fails.
- A visibly labelled local build dramatically shortens the device-feedback loop and makes demos reproducible without depending on production services.
