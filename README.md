# AI IELTS & TOEFL Writing Coach

Flutter-based mobile app for IELTS and TOEFL candidates who want structured
essay feedback, recurring mistake tracking, writing progress, coaching reports,
and habit-building challenges.

The product goal is not only to score essays. It should help users understand
which mistakes they repeat over time and what to practice next.

## Current Status

The MVP foundation is in progress:

- Flutter app shell with 5 tabs: Home, Progress, Write, Coach, Profile
- Riverpod state management
- Firebase bootstrap with graceful fallback when Firebase is not configured
- Google and Apple auth repository layer
- Essay writing screen with word count, credits, submit state, and result card
- Mock essay analysis flow for local development and widget tests
- Firebase callable function for real Claude-powered essay analysis
- Firestore write flow for essays, analyses, user error stats, credits, streaks,
  and writing health score

For the active checklist, see [TODO.md](TODO.md).

## Architecture

```text
Flutter App
  -> Riverpod State Management
  -> Feature Repositories
  -> Firebase Auth / Firestore / Firebase Functions
  -> Claude API
```

Core rule: the Flutter app must never call Claude directly. All AI requests go
through Firebase Functions.

## Tech Stack

- Flutter
- Riverpod
- Firebase Auth
- Firestore
- Firebase Functions
- Anthropic Claude API
- RevenueCat
- Firebase Analytics
- Posthog
- OneSignal
- Firebase Crashlytics
- Setgreet SDK

Some services are documented as part of the MVP roadmap but are not fully wired
yet.

## Repository Layout

```text
lib/                 Flutter application code
lib/src/core/        App state, design system, Firebase bootstrap
lib/src/features/    Auth, home, write, progress, coach, profile features
functions/           Firebase Functions TypeScript backend
docs/                Product, architecture, Firestore, analytics, monetization
test/                Flutter tests
TODO.md              Current working checklist
```

## Run The App

Install Flutter dependencies:

```sh
flutter pub get
```

Run with the default local/mock repository behavior:

```sh
flutter run
```

Run against Firebase callable functions:

```sh
flutter run --dart-define=AI_COACH_USE_FUNCTIONS=true
```

Run checks:

```sh
flutter analyze
flutter test
```

## Backend Functions

Install and build the Firebase Functions project:

```sh
npm --prefix functions install
npm --prefix functions run build
```

Configure the Anthropic key in Firebase Secret Manager:

```sh
firebase functions:secrets:set ANTHROPIC_API_KEY --project aicoach-604d8
```

The Firebase project must be on the Blaze plan before Secret Manager can be
enabled for Functions secrets.

Deploy functions:

```sh
firebase deploy --only functions
```

For local emulator usage, copy `functions/.secret.local.example` to
`functions/.secret.local` and put the Anthropic key there. The real
`functions/.secret.local` file is ignored by git.

See [docs/backend-functions.md](docs/backend-functions.md) for the callable
function contract and deployment notes.

## Firebase Notes

- The current Firebase project alias is defined in `.firebaserc`.
- iOS has `ios/Runner/GoogleService-Info.plist`.
- Android still needs `android/app/google-services.json` and the Google
  Services Gradle plugin before real Android Firebase testing.
- Web and desktop Firebase support should use generated FlutterFire options
  before being treated as production-ready targets.

## Documentation

- [Requirements](requirements.md)
- [Architecture](docs/architecture.md)
- [Firestore schema](docs/firestore-schema.md)
- [Backend functions](docs/backend-functions.md)
- [iOS release runbook](docs/ios-release.md)
- [Roadmap](docs/roadmap.md)
- [Active TODO](TODO.md)
