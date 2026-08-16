# ListenThenTask

A personal Android app that transcribes speech and adds it to Google Tasks — built to be more reliable than asking Gemini to do it by voice.

Tap the mic, speak, tap again to stop. A confirmation dialog shows the transcribed text (editable) before sending it to your Google Tasks list.

## How it works

- **Speech-to-text**: [Vosk](https://alphacephei.com/vosk/) running fully on-device via `vosk_flutter`, with a bundled offline English model (`assets/models/`). No cloud STT service, no network dependency for transcription.
- **Auth**: Google Sign-In (`google_sign_in`, classic API) with the `tasks` scope, silently re-authenticating on launch so you don't have to sign in every time.
- **Tasks**: `googleapis`'s `TasksApi`, called with an authenticated HTTP client built from the signed-in account's auth headers. Inserts into your default task list (`@default`).

## Project layout

- `lib/pages/pages_home.dart` — main screen: mic button, live transcript, confirmation dialog
- `lib/auth/` — Google Sign-In wrapper
- `lib/account/` — sign-in/profile UI in the app bar
- `lib/tasks/` — Google Tasks API wrapper
- `lib/app/` — Vektis brand theme/colors

## Running it

```bash
flutter pub get
flutter run -d <device-id>
```

Android only. Requires a Google Cloud project with the Tasks API enabled and an OAuth client registered for the app's package name + SHA-1 (see `au.com.vektis.listen_then_task`).
