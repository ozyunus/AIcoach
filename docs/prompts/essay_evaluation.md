# Claude Prompt: Essay Evaluation

## Purpose

Evaluate an IELTS or TOEFL essay and return a strict JSON response.

## Input

- examType: IELTS or TOEFL
- essayText: user essay

## Output Requirements

The response must be valid JSON only.

No markdown.

No explanation outside JSON.

## JSON Schema

```json
{
  "version": "1.0",
  "raw_score": 6.5,
  "normalized_score": 72,
  "scores": {
    "grammar": 78,
    "vocabulary": 65,
    "coherence": 70,
    "task_achievement": 75
  },
  "analysis": {
    "grammar_errors": [
      {
        "category": "tenses",
        "original": "She write an essay yesterday.",
        "correction": "She wrote an essay yesterday.",
        "explanation": "Past simple tense is required because of the time marker 'yesterday'."
      }
    ],
    "vocabulary_suggestions": [
      {
        "original": "very big problem",
        "better": "major challenge",
        "reason": "More suitable for academic writing."
      }
    ],
    "general_feedback": "The essay is well structured, but grammar accuracy needs improvement."
  }
}
```

## Error Categories

Use only these categories:

- articles
- tenses
- prepositions
- subject_verb_agreement
- sentence_structure
- punctuation
- word_choice
- vocabulary_range
- coherence
- cohesion
- task_achievement

## Mentor Note

This prompt must be tested with real essays before production.

The biggest product risk is scoring consistency.
