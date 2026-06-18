# Roadmap

## Phase 0 - Documentation

Goal:

Prepare enough documentation so Codex can generate a clean initial project.

Tasks:

- requirements.md
- architecture.md
- firestore-schema.md
- analytics.md
- monetization.md
- prompts/essay_evaluation.md
- prompts/coach_report.md
- prompts/challenge_evaluation.md

## Phase 1 - Flutter Foundation

Tasks:

- Create Flutter project
- Add folder structure
- Add Riverpod
- Add Firebase setup
- Add theme system
- Add placeholder navigation

Success:

App opens with 5-tab navigation.

## Phase 2 - Auth

Tasks:

- Google Sign In
- Apple Sign In
- Create user document
- Add 3 free credits

Success:

New users can sign in and see their profile.

## Phase 3 - Essay MVP

Tasks:

- Essay input screen
- Word count
- Submit button
- Mock analysis response
- Result screen

Success:

User can submit essay and see fake analysis result.

## Phase 4 - Claude Integration

Tasks:

- Firebase Function
- Secure Claude API call
- JSON validation
- Store essay and analysis

Success:

Real AI analysis works end-to-end.

## Phase 5 - Dashboard

Tasks:

- Score chart
- Writing Health Score
- Error stats
- Last essay card

Success:

User sees progress from stored essays.

## Phase 6 - Credit System and RevenueCat

Tasks:

- Credit validation
- Credit consumption
- Paywall
- Purchase flow

Success:

User can buy credits and spend credits.

## Phase 7 - Coach Reports

Tasks:

- Generate report from last 10 essays
- Store report
- Display report screen

Success:

User receives personalized feedback based on history.

## Phase 8 - Challenges

Tasks:

- Writing streak challenge
- Error reduction challenge
- Vocabulary challenge

Success:

User can start and complete challenges.

## Phase 9 - Analytics, Notifications, Crashlytics

Tasks:

- Posthog events
- Firebase Analytics events
- OneSignal notifications
- Crashlytics setup

Success:

Core behavior and crashes are trackable.
