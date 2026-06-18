# Architecture

## Goal

Build a maintainable Flutter MVP for an AI IELTS & TOEFL Writing Coach.

The app must be simple enough for MVP development, but structured enough to grow without major rewrites.

## Main Architecture

```text
Flutter App
  -> Riverpod State Management
  -> Feature Repositories
  -> Firebase Auth / Firestore / Firebase Functions
  -> Claude API
```

## Core Rule

The Flutter app must never call Claude API directly.

All AI requests must go through Firebase Functions.

## Main Services

- Firebase Auth: user authentication
- Firestore: user, essay, analysis, challenge, and report data
- Firebase Functions: secure API layer for Claude
- Claude API: essay scoring and coach reports
- RevenueCat: consumable credit purchases
- OneSignal: push notifications
- Firebase Analytics: standard app analytics
- Posthog: product analytics and funnel tracking
- Crashlytics: crash monitoring
- Setgreet SDK: onboarding and remote screen management

## Suggested App Flow

1. User signs in.
2. User receives 3 free credits.
3. User submits an essay.
4. App checks credit balance.
5. Flutter calls the `submitEssay` Firebase Function.
6. The function sends essay text to Claude.
7. Claude returns structured JSON.
8. The function stores essay and analysis in Firestore.
9. Dashboard updates.
10. User can view progress, errors, challenges, and coach reports.

## Important Mentor Note

Do not start with every feature at once.

Build in this order:

1. Auth
2. Firestore user profile
3. Essay submission screen
4. Firebase Function mock response
5. Real Claude integration
6. Result screen
7. Dashboard
8. Credit system
9. RevenueCat
10. Challenges
11. Coach reports
12. Analytics and notifications
