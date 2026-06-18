# Claude Prompt: Challenge Evaluation

## Purpose

Evaluate whether a user has completed a challenge.

## Challenge Types

- writing_streak
- error_reduction
- vocabulary_growth

## Input

- challengeType
- user progress
- previous data
- current data

## Output Requirements

Return JSON only.

## JSON Schema

```json
{
  "version": "1.0",
  "challenge_completed": true,
  "progress_summary": "You completed 5 writing days in a row.",
  "reward": {
    "type": "credit",
    "value": 1
  }
}
```

## Mentor Note

Most challenge checks should be calculated in app/backend logic.

Use Claude only when natural language interpretation is needed.
