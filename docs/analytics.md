# Analytics Plan

## Goal

Use analytics to understand:

- Where users drop off
- Whether users return
- Whether users buy credits
- Whether challenges increase retention
- Which hours users are active

## Shared Event Rules

Send the same core events to:

- Firebase Analytics
- Posthog

Use consistent event names.

---

## Core Events

### app_opened

Triggered when the app is opened.

Properties:

```json
{
  "localHour": 21,
  "localDayOfWeek": "Tuesday",
  "timezone": "Europe/Istanbul"
}
```

### signup_completed

Triggered after successful account creation.

Properties:

```json
{
  "authProvider": "google",
  "examType": "IELTS"
}
```

### essay_submitted

Triggered when user taps analyze.

Properties:

```json
{
  "examType": "IELTS",
  "wordCount": 315,
  "creditsBeforeSubmit": 3,
  "localHour": 21
}
```

### analysis_completed

Triggered when Claude analysis returns successfully.

Properties:

```json
{
  "rawScore": 6.5,
  "normalizedScore": 72,
  "durationMs": 8500
}
```

### paywall_opened

Triggered when paywall appears.

Properties:

```json
{
  "reason": "credits_finished"
}
```

### purchase_completed

Triggered after successful RevenueCat purchase.

Properties:

```json
{
  "productId": "essay_pack_10",
  "creditsAdded": 10
}
```

### challenge_started

Properties:

```json
{
  "challengeType": "writing_streak"
}
```

### challenge_completed

Properties:

```json
{
  "challengeType": "writing_streak",
  "rewardType": "credit",
  "rewardValue": 1
}
```

### coach_report_generated

Properties:

```json
{
  "reportType": "weekly",
  "essayCountUsed": 10
}
```

---

## Key Funnels

### Activation Funnel

```text
app_opened
-> signup_completed
-> essay_submitted
-> analysis_completed
```

### Monetization Funnel

```text
analysis_completed
-> credits_finished
-> paywall_opened
-> purchase_completed
```

### Retention Funnel

```text
essay_submitted
-> challenge_started
-> streak_day_completed
-> challenge_completed
```

## Mentor Note

Do not track 100 events in MVP.

Track fewer events but make them clean and consistent.
