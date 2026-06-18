# Claude Prompt: Coach Report

## Purpose

Generate a personalized coaching report based on user's historical writing data.

## Input

- examType
- last 10 essay scores
- error statistics
- score trend
- common mistakes

## Output Requirements

Return valid JSON only.

## JSON Schema

```json
{
  "version": "1.0",
  "summary": "You are improving steadily, especially in vocabulary.",
  "main_strengths": [
    "Vocabulary range has improved",
    "Essay structure is more consistent"
  ],
  "main_weaknesses": [
    "Article mistakes are still frequent",
    "Coherence sometimes drops in body paragraphs"
  ],
  "recommended_focus": [
    {
      "topic": "Articles",
      "reason": "This is your most repeated grammar issue.",
      "suggested_action": "Practice article usage for 20 minutes twice this week."
    }
  ],
  "encouraging_message": "You are moving in the right direction. Focus on one weakness at a time."
}
```

## Tone

- Encouraging
- Clear
- Specific
- Not harsh
- Not childish
