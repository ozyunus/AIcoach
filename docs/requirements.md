# AI IELTS & TOEFL Writing Coach

## Overview

AI IELTS & TOEFL Writing Coach is a Flutter-based mobile application designed to help IELTS and TOEFL candidates improve their writing performance through AI-powered essay evaluation, historical mistake tracking, coaching reports, and habit-building challenges.

The primary goal is not only to score essays but to identify recurring weaknesses and help users systematically improve before their exam.

## MVP Scope

### Included

- Google Sign In
- Apple Sign In
- Essay Analysis
- Credit System
- Writing Progress Dashboard
- AI Coach Reports
- Challenges
- Push Notifications
- Analytics
- Crash Reporting
- In-App Purchases

### Excluded

- Global Leaderboard
- Country Rankings
- Exam Countdown
- Social Features
- Friend System

## Technology Stack

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

## State Management Decision

Use Riverpod.

Reason:

- Good fit for Flutter
- Testable
- Easier than Bloc for this project
- Works well with repository pattern
- AI coding tools understand it well

## Architecture Rule

Flutter UI must not call Claude API directly.

All AI calls must go through Firebase Functions.

## Credit System

- New users receive 3 free essay credits.
- Essay analysis consumes 1 credit.
- Coach reports are free.
- Challenges are free.

## Main Product Differentiator

The app is not just an AI essay scorer.

It tracks repeated mistakes over time and helps the user understand what they keep doing wrong.

Example:

"You repeated article mistakes in 8 of your last 10 essays."

## Success Metrics

Primary:

- D7 Retention
- D30 Retention
- Free-to-Paid Conversion

Secondary:

- Essays Per User
- Coach Report Usage
- Challenge Completion Rate
- Average Credits Purchased
