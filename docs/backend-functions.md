# Backend Functions

## Current Endpoint

The Flutter app can call this Firebase callable function when the app is run
with `AI_COACH_USE_FUNCTIONS=true`:

```text
submitEssay
```

Request:

```json
{
  "examType": "IELTS",
  "prompt": "Essay prompt...",
  "essayText": "User essay..."
}
```

Response:

```json
{
  "user": {
    "id": "firebase_uid",
    "email": "user@example.com",
    "nickname": "Writer",
    "examType": "IELTS",
    "credits": 2,
    "writingHealthScore": 68,
    "currentStreak": 1
  },
  "essay": {
    "id": "essayId",
    "prompt": "Essay prompt...",
    "essayText": "User essay...",
    "wordCount": 180,
    "rawScore": "6.8",
    "normalizedScore": 68,
    "grammarScore": 65,
    "vocabularyScore": 61,
    "coherenceScore": 68,
    "taskAchievementScore": 72,
    "createdAt": 1780664400000,
    "analysis": {
      "rawScore": "6.8",
      "normalizedScore": 68,
      "generalFeedback": "Feedback text...",
      "skillScores": [],
      "corrections": [],
      "vocabularySuggestions": [],
      "errorStats": []
    }
  }
}
```

## Claude Setup

`submitEssay` calls Anthropic Claude from Firebase Functions. The API key must
live in Firebase Secret Manager, not in Flutter or Firestore:

```sh
firebase functions:secrets:set ANTHROPIC_API_KEY --project aicoach-604d8
```

Firebase Functions secrets use Google Secret Manager. The Firebase project must
be on the Blaze plan before this command can complete.

The function defaults to `claude-sonnet-4-6`, which is a valid Anthropic API
model ID as of 2026-06-18. Treat the model ID as an explicit deploy-time choice,
not an auto-updating "latest" alias. Override it with the `ANTHROPIC_MODEL`
runtime environment variable only if you intentionally want a different model.

For local emulator runs, copy `functions/.secret.local.example` to
`functions/.secret.local` and provide the same key through that local secret
file:

```sh
ANTHROPIC_API_KEY=sk-ant-...
```

`functions/.secret.local` is ignored by git.

Pre-deploy check:

```sh
npm --prefix functions run build
```

## Deploy

Build locally:

```sh
npm --prefix functions install
npm --prefix functions run build
```

Deploy:

```sh
firebase deploy --only functions --project aicoach-604d8
```

Run Flutter against callable functions:

```sh
flutter run --dart-define=AI_COACH_USE_FUNCTIONS=true
```

## Current Behavior

`submitEssay` now calls Claude for a strict JSON essay evaluation, maps that
response into the Flutter `EssayAnalysis` shape, and performs the backend
transaction:

- validates Firebase Auth
- validates prompt and essay length
- checks credits
- creates `essays/{essayId}`
- creates `essay_analyses/{essayId}`
- updates `user_error_stats/{userId}`
- decrements `users/{userId}.credits`
- updates streak, writing health, and total essay count

## Next Step

Add emulator coverage for the callable function and test at least a few real
IELTS/TOEFL essays for scoring consistency before production launch.
