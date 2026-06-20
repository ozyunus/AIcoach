# Firestore Schema

## General Rules

- Every document should include `createdAt`.
- Documents that can be edited should include `updatedAt`.
- Use Firebase Auth UID as the primary user identifier.
- Do not store Claude API keys in Firestore.
- Keep user-facing data separate from internal analytics where possible.

---

## Collection: users

Path:

```text
users/{userId}
```

Example:

```json
{
  "id": "firebase_uid",
  "email": "user@example.com",
  "nickname": "writer742",
  "examType": "IELTS",
  "examFormat": "online",
  "credits": 3,
  "writingHealthScore": 72,
  "currentStreak": 0,
  "totalEssaysAnalyzed": 0,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## Collection: essays

Path:

```text
essays/{essayId}
```

Example:

```json
{
  "id": "essayId",
  "userId": "firebase_uid",
  "examType": "IELTS",
  "essayText": "Essay content...",
  "wordCount": 315,
  "rawScore": 6.5,
  "normalizedScore": 72,
  "grammarScore": 78,
  "vocabularyScore": 65,
  "coherenceScore": 70,
  "taskAchievementScore": 75,
  "createdAt": "timestamp"
}
```

---

## Collection: essay_analyses

Path:

```text
essay_analyses/{analysisId}
```

Example:

```json
{
  "id": "analysisId",
  "essayId": "essayId",
  "userId": "firebase_uid",
  "schemaVersion": "1.0",
  "grammarErrors": [
    {
      "category": "tenses",
      "original": "She write an essay yesterday.",
      "correction": "She wrote an essay yesterday.",
      "explanation": "Past simple tense is required because of 'yesterday'."
    }
  ],
  "vocabularySuggestions": [
    {
      "original": "very big problem",
      "better": "major challenge",
      "reason": "More academic and natural wording."
    }
  ],
  "generalFeedback": "Good structure, but tense accuracy needs improvement.",
  "createdAt": "timestamp"
}
```

---

## Collection: user_error_stats

Path:

```text
user_error_stats/{userId}
```

Example:

```json
{
  "userId": "firebase_uid",
  "articles": 35,
  "tenses": 18,
  "prepositions": 12,
  "subjectVerbAgreement": 8,
  "sentenceStructure": 10,
  "punctuation": 5,
  "wordChoice": 14,
  "vocabularyRange": 11,
  "coherence": 7,
  "cohesion": 6,
  "taskAchievement": 4,
  "updatedAt": "timestamp"
}
```

---

## Collection: coach_reports

Path:

```text
coach_reports/{reportId}
```

Example:

```json
{
  "id": "reportId",
  "userId": "firebase_uid",
  "reportType": "weekly",
  "content": "Your vocabulary is improving, but article mistakes are still frequent.",
  "focusAreas": ["articles", "coherence"],
  "generatedAt": "timestamp"
}
```

---

## Collection: challenges

Path:

```text
challenges/{challengeId}
```

Example:

```json
{
  "id": "challengeId",
  "userId": "firebase_uid",
  "type": "writing_streak",
  "status": "active",
  "startDate": "timestamp",
  "endDate": "timestamp",
  "progress": 3,
  "target": 5,
  "rewardType": "credit",
  "rewardValue": 1,
  "isFrozen": false,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## Mentor Note

The most important collections for MVP are:

1. users
2. essays
3. essay_analyses

Do not overbuild the database before the first working essay analysis flow.

---

## Security Rules

The deployable rules live in `firestore.rules` and are connected through
`firebase.json`.

Security posture:

- Users can read their own profile, essays, analyses, and error stats.
- Users can create their own profile with fixed initial credit/score fields.
- Users can update only profile/auth fields: `email`, `nickname`, `examType`,
  `lastLoginAt`, and `updatedAt`.
- Users cannot write `credits`, writing scores, essays, analyses, or error
  stats from the client.
- Essay submission and credit consumption must go through the callable backend,
  which writes with Admin SDK privileges.
