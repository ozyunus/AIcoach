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

## Firestore Collections

### users

- id
- email
- nickname
- examType
- credits
- writingHealthScore
- currentStreak
- createdAt

### essays

- id
- userId
- essayText
- rawScore
- normalizedScore
- wordCount
- createdAt

### essay_analyses

- essayId
- schemaVersion
- grammarErrors
- vocabularySuggestions
- generalFeedback

### user_error_stats

- userId
- articles
- tenses
- prepositions
- coherence

### coach_reports

- id
- userId
- content
- generatedAt

## Repository Pattern

- UserRepository
- EssayRepository
- CoachRepository
- ChallengeRepository
- AnalyticsRepository

## Credit System

- New User Credits: 3
- Essay Analysis: -1 Credit
- Coach Reports: Free
- Challenges: Free

## RevenueCat Products

- essay_pack_5
- essay_pack_10
- essay_pack_25

## Claude Prompt Architecture

- Essay Evaluation
- Coach Report
- Challenge Evaluation

## Error Taxonomy

- Articles
- Tenses
- Prepositions
- Subject Verb Agreement
- Sentence Structure
- Punctuation
- Word Choice
- Vocabulary Range
- Coherence
- Cohesion
- Task Achievement

## Dashboard Formula

Writing Health Score

- Grammar 40%
- Vocabulary 25%
- Coherence 20%
- Consistency 15%

## Challenges

### Writing Streak

Write 1 essay daily for 5 days

Reward: +1 Credit

### Error Reduction

Reduce selected error category

Reward: +2 Credits

### Vocabulary Growth

Reward: Achievement Badge

## OneSignal Events

- user_registered
- first_essay
- challenge_started
- challenge_completed
- credits_finished
- purchase_completed
- inactive_3_days

## Analytics Events

- app_opened
- signup_completed
- essay_submitted
- analysis_completed
- coach_report_generated
- paywall_opened
- purchase_completed
- challenge_started
- challenge_completed
- streak_day_completed

## Retention Tracking

Store:

- localHour
- localDayOfWeek
- timezone

## Crashlytics

Track:

- Flutter exceptions
- API failures
- Firebase failures
- Purchase failures
- Notification failures

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
