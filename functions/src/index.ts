import {initializeApp} from "firebase-admin/app";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {defineSecret} from "firebase-functions/params";
import {HttpsError, onCall} from "firebase-functions/v2/https";

initializeApp();

const db = getFirestore();
const anthropicApiKey = defineSecret("ANTHROPIC_API_KEY");
const defaultAnthropicModel = "claude-sonnet-4-6";
const anthropicVersion = "2023-06-01";

interface CorrectionPayload {
  type: string;
  original: string;
  corrected: string;
  explanation: string;
}

interface ErrorStatPayload {
  label: string;
  count: number;
}

interface SkillScorePayload {
  label: string;
  score: number;
}

interface AnalysisPayload {
  rawScore: string;
  normalizedScore: number;
  generalFeedback: string;
  skillScores: SkillScorePayload[];
  corrections: CorrectionPayload[];
  vocabularySuggestions: string[];
  errorStats: ErrorStatPayload[];
}

interface EssayPayload {
  id: string;
  prompt: string;
  essayText: string;
  wordCount: number;
  rawScore: string;
  normalizedScore: number;
  grammarScore: number;
  vocabularyScore: number;
  coherenceScore: number;
  taskAchievementScore: number;
  createdAt: number;
  analysis: AnalysisPayload;
}

interface UserPayload {
  id: string;
  email: string;
  nickname: string;
  examType: string;
  credits: number;
  writingHealthScore: number;
  currentStreak: number;
}

interface SubmitEssayResponse {
  user: UserPayload;
  essay: EssayPayload;
}

export const submitEssay = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 60,
    memory: "256MiB",
    secrets: [anthropicApiKey],
  },
  async (request): Promise<SubmitEssayResponse> => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Please sign in first.");
    }

    const prompt = readString(request.data?.prompt, "");
    const essayText = readString(request.data?.essayText, "").trim();
    const requestedExamType = readString(request.data?.examType, "IELTS");
    const wordCount = countWords(essayText);

    if (!prompt) {
      throw new HttpsError("invalid-argument", "Prompt is required.");
    }

    if (wordCount < 20) {
      throw new HttpsError(
        "invalid-argument",
        "Essay must contain at least 20 words.",
      );
    }

    const userRef = db.collection("users").doc(uid);
    const essayRef = db.collection("essays").doc();
    const analysisRef = db.collection("essay_analyses").doc(essayRef.id);
    const errorStatsRef = db.collection("user_error_stats").doc(uid);
    const precheckSnapshot = await userRef.get();

    if (!precheckSnapshot.exists) {
      throw new HttpsError("not-found", "User profile was not found.");
    }

    const precheckData = precheckSnapshot.data() ?? {};
    const precheckCredits = readNumber(precheckData.credits, 0);
    if (precheckCredits <= 0) {
      throw new HttpsError(
        "failed-precondition",
        "You are out of essay credits.",
      );
    }

    const analysisExamType = readString(
      precheckData.examType,
      requestedExamType,
    );
    const analysis = await analyzeEssayWithClaude({
      examType: analysisExamType,
      prompt,
      essayText,
    });
    const nowMs = Date.now();

    return db.runTransaction(async (transaction) => {
      const userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw new HttpsError("not-found", "User profile was not found.");
      }

      const userData = userSnapshot.data() ?? {};
      const credits = readNumber(userData.credits, 0);
      if (credits <= 0) {
        throw new HttpsError(
          "failed-precondition",
          "You are out of essay credits.",
        );
      }

      const previousTotal = readNumber(userData.totalEssaysAnalyzed, 0);
      const previousHealth = readNumber(userData.writingHealthScore, 62);
      const nextTotal = previousTotal + 1;
      const nextHealth = Math.round(
        (previousHealth * previousTotal + analysis.normalizedScore) /
          nextTotal,
      );
      const nextStreak = readNumber(userData.currentStreak, 0) + 1;
      const nextCredits = credits - 1;
      const examType = readString(userData.examType, analysisExamType);
      const createdAt = FieldValue.serverTimestamp();
      const rawScore = Number(analysis.rawScore);

      transaction.set(essayRef, {
        id: essayRef.id,
        userId: uid,
        examType,
        prompt,
        essayText,
        wordCount,
        rawScore,
        normalizedScore: analysis.normalizedScore,
        grammarScore: scoreFor(analysis, "Grammar"),
        vocabularyScore: scoreFor(analysis, "Vocabulary"),
        coherenceScore: scoreFor(analysis, "Coherence"),
        taskAchievementScore: scoreFor(analysis, "Task Achievement"),
        createdAt,
      });

      transaction.set(analysisRef, {
        id: analysisRef.id,
        essayId: essayRef.id,
        userId: uid,
        schemaVersion: "1.0",
        grammarErrors: analysis.corrections.map((correction) => ({
          category: toErrorCategory(correction.type),
          original: correction.original,
          correction: correction.corrected,
          explanation: correction.explanation,
        })),
        vocabularySuggestions: analysis.vocabularySuggestions.map(
          vocabularySuggestionToFirestore,
        ),
        generalFeedback: analysis.generalFeedback,
        createdAt,
      });

      transaction.set(
        errorStatsRef,
        {
          userId: uid,
          ...analysis.errorStats.reduce<Record<string, FieldValue>>(
            (fields, stat) => {
              fields[toFirestoreErrorKey(stat.label)] = FieldValue.increment(
                stat.count,
              );
              return fields;
            },
            {},
          ),
          updatedAt: createdAt,
        },
        {merge: true},
      );

      transaction.set(
        userRef,
        {
          credits: nextCredits,
          writingHealthScore: nextHealth,
          currentStreak: nextStreak,
          totalEssaysAnalyzed: nextTotal,
          updatedAt: createdAt,
        },
        {merge: true},
      );

      logger.info("Essay submitted", {
        uid,
        essayId: essayRef.id,
        wordCount,
        score: analysis.rawScore,
      });

      return {
        user: {
          id: uid,
          email: readString(userData.email, ""),
          nickname: readString(userData.nickname, "Writer"),
          examType,
          credits: nextCredits,
          writingHealthScore: nextHealth,
          currentStreak: nextStreak,
        },
        essay: {
          id: essayRef.id,
          prompt,
          essayText,
          wordCount,
          rawScore: analysis.rawScore,
          normalizedScore: analysis.normalizedScore,
          grammarScore: scoreFor(analysis, "Grammar"),
          vocabularyScore: scoreFor(analysis, "Vocabulary"),
          coherenceScore: scoreFor(analysis, "Coherence"),
          taskAchievementScore: scoreFor(analysis, "Task Achievement"),
          createdAt: nowMs,
          analysis,
        },
      };
    });
  },
);

interface AnalyzeEssayRequest {
  examType: string;
  prompt: string;
  essayText: string;
}

interface ClaudeMessageResponse {
  content?: unknown;
  error?: {
    message?: string;
    type?: string;
  };
}

interface ClaudeEssayResponse {
  raw_score?: unknown;
  normalized_score?: unknown;
  scores?: {
    grammar?: unknown;
    vocabulary?: unknown;
    coherence?: unknown;
    task_achievement?: unknown;
  };
  analysis?: {
    grammar_errors?: unknown;
    vocabulary_suggestions?: unknown;
    general_feedback?: unknown;
  };
}

async function analyzeEssayWithClaude(
  request: AnalyzeEssayRequest,
): Promise<AnalysisPayload> {
  const apiKey = anthropicApiKey.value();
  if (!apiKey) {
    throw new HttpsError(
      "failed-precondition",
      "ANTHROPIC_API_KEY secret is not configured.",
    );
  }

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "anthropic-version": anthropicVersion,
      "content-type": "application/json",
      "x-api-key": apiKey,
    },
    body: JSON.stringify({
      model: anthropicModel(),
      max_tokens: 1800,
      temperature: 0,
      system:
        "You are an expert IELTS and TOEFL writing examiner. Return only " +
        "valid JSON that matches the requested schema. Do not include " +
        "markdown, comments, or extra prose.",
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: buildEssayEvaluationPrompt(request),
            },
          ],
        },
      ],
    }),
  });

  const data = (await response.json()) as ClaudeMessageResponse;

  if (!response.ok) {
    const message =
      data.error?.message ?? `Claude API request failed with ${response.status}.`;
    logger.error("Claude essay analysis failed", {
      status: response.status,
      type: data.error?.type,
    });
    throw new HttpsError("unavailable", message);
  }

  const text = textFromClaudeResponse(data);
  const parsed = parseClaudeJson(text);

  return analysisFromClaudePayload(parsed, request.examType);
}

function anthropicModel(): string {
  return process.env.ANTHROPIC_MODEL?.trim() || defaultAnthropicModel;
}

function buildEssayEvaluationPrompt(request: AnalyzeEssayRequest): string {
  return [
    "Evaluate this writing submission.",
    "",
    `Exam type: ${request.examType}`,
    `Prompt: ${request.prompt}`,
    "",
    "Return JSON only with this exact shape:",
    JSON.stringify(
      {
        version: "1.0",
        raw_score: 6.5,
        normalized_score: 72,
        scores: {
          grammar: 78,
          vocabulary: 65,
          coherence: 70,
          task_achievement: 75,
        },
        analysis: {
          grammar_errors: [
            {
              category: "tenses",
              original: "She write an essay yesterday.",
              correction: "She wrote an essay yesterday.",
              explanation:
                "Past simple tense is required because of the time marker.",
            },
          ],
          vocabulary_suggestions: [
            {
              original: "very big problem",
              better: "major challenge",
              reason: "More suitable for academic writing.",
            },
          ],
          general_feedback:
            "The essay is well structured, but grammar accuracy needs work.",
        },
      },
      null,
      2,
    ),
    "",
    "Scoring rules:",
    "- raw_score is IELTS band 0-9 when examType is IELTS.",
    "- raw_score is TOEFL Writing score 0-30 when examType is TOEFL.",
    "- normalized_score and every score field must be integers from 0 to 100.",
    "- Include at most 6 grammar_errors and at most 5 vocabulary_suggestions.",
    "- Use only these categories: articles, tenses, prepositions, " +
      "subject_verb_agreement, sentence_structure, punctuation, word_choice, " +
      "vocabulary_range, coherence, cohesion, task_achievement.",
    "",
    "Essay:",
    request.essayText,
  ].join("\n");
}

function textFromClaudeResponse(data: ClaudeMessageResponse): string {
  if (!Array.isArray(data.content)) {
    throw new HttpsError("internal", "Claude returned an invalid response.");
  }

  const text = data.content
    .map((block) => {
      if (
        typeof block === "object" &&
        block !== null &&
        "type" in block &&
        block.type === "text" &&
        "text" in block &&
        typeof block.text === "string"
      ) {
        return block.text;
      }
      return "";
    })
    .join("")
    .trim();

  if (!text) {
    throw new HttpsError("internal", "Claude returned an empty response.");
  }

  return text;
}

function parseClaudeJson(text: string): ClaudeEssayResponse {
  try {
    return JSON.parse(text) as ClaudeEssayResponse;
  } catch (error) {
    const firstBrace = text.indexOf("{");
    const lastBrace = text.lastIndexOf("}");
    if (firstBrace >= 0 && lastBrace > firstBrace) {
      try {
        return JSON.parse(text.slice(firstBrace, lastBrace + 1)) as
          ClaudeEssayResponse;
      } catch (_) {
        logger.error("Claude essay analysis JSON parse failed", {error});
      }
    }

    throw new HttpsError(
      "internal",
      "Claude returned analysis in an invalid JSON format.",
    );
  }
}

function analysisFromClaudePayload(
  payload: ClaudeEssayResponse,
  examType: string,
): AnalysisPayload {
  const normalizedScore = scoreValue(payload.normalized_score, 0);
  const scores = payload.scores ?? {};
  const corrections = correctionsFromClaude(payload.analysis?.grammar_errors);
  const vocabularySuggestions = vocabularySuggestionsFromClaude(
    payload.analysis?.vocabulary_suggestions,
  );

  return {
    rawScore: rawScoreLabel(payload.raw_score, examType, normalizedScore),
    normalizedScore,
    generalFeedback: readString(
      payload.analysis?.general_feedback,
      "Analysis completed, but no feedback text was returned.",
    ),
    skillScores: [
      {
        label: "Task Achievement",
        score: scoreValue(scores.task_achievement, normalizedScore),
      },
      {label: "Coherence", score: scoreValue(scores.coherence, normalizedScore)},
      {
        label: "Vocabulary",
        score: scoreValue(scores.vocabulary, normalizedScore),
      },
      {label: "Grammar", score: scoreValue(scores.grammar, normalizedScore)},
    ],
    corrections,
    vocabularySuggestions,
    errorStats: errorStatsFromCorrections(corrections),
  };
}

function correctionsFromClaude(value: unknown): CorrectionPayload[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .filter((item): item is Record<string, unknown> => isRecord(item))
    .map((item) => ({
      type: categoryLabel(readString(item.category, "grammar")),
      original: readString(item.original, ""),
      corrected: readString(item.correction, ""),
      explanation: readString(item.explanation, ""),
    }))
    .filter((correction) => correction.original || correction.corrected);
}

function vocabularySuggestionsFromClaude(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((item) => {
      if (typeof item === "string") {
        return item.trim();
      }

      if (!isRecord(item)) {
        return "";
      }

      const original = readString(item.original, "");
      const better = readString(item.better, "");
      if (original && better) {
        return `${original} -> ${better}`;
      }

      return original || better;
    })
    .filter((suggestion) => suggestion.length > 0);
}

function errorStatsFromCorrections(
  corrections: CorrectionPayload[],
): ErrorStatPayload[] {
  const counts = new Map<string, number>();
  for (const correction of corrections) {
    const label = correction.type;
    counts.set(label, (counts.get(label) ?? 0) + 1);
  }

  return Array.from(counts.entries()).map(([label, count]) => ({
    label,
    count,
  }));
}

function scoreValue(value: unknown, fallback: number): number {
  return Math.round(clamp(finiteNumber(value, fallback), 0, 100));
}

function rawScoreLabel(
  value: unknown,
  examType: string,
  normalizedScore: number,
): string {
  const isToefl = examType.toLowerCase().includes("toefl");
  const fallback = isToefl
    ? Math.round((normalizedScore / 100) * 30)
    : 4 + (normalizedScore / 100) * 5;
  const score = finiteNumber(value, fallback);

  if (isToefl) {
    return Math.round(clamp(score, 0, 30)).toString();
  }

  return clamp(score, 0, 9).toFixed(1);
}

function finiteNumber(value: unknown, fallback: number): number {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  if (typeof value === "string") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  }

  return fallback;
}

function categoryLabel(value: string): string {
  const normalized = value.trim().toLowerCase().replace(/_/g, " ");
  if (!normalized) {
    return "Grammar";
  }

  return normalized.replace(/\b\w/g, (match) => match.toUpperCase());
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function vocabularySuggestionToFirestore(suggestion: string): {
  original: string;
  better: string;
  reason: string;
} {
  const parts = suggestion.split(" -> ");
  if (parts.length !== 2) {
    return {
      original: suggestion,
      better: suggestion,
      reason: "Suggested vocabulary upgrade.",
    };
  }

  return {
    original: parts[0],
    better: parts[1],
    reason: "More natural academic wording.",
  };
}

function scoreFor(analysis: AnalysisPayload, label: string): number {
  return (
    analysis.skillScores.find((score) => score.label === label)?.score ??
    analysis.normalizedScore
  );
}

function toErrorCategory(label: string): string {
  return label.toLowerCase().replaceAll(" ", "_");
}

function toFirestoreErrorKey(label: string): string {
  const normalized = label.toLowerCase();
  if (normalized.includes("article")) {
    return "articles";
  }
  if (normalized.includes("tense")) {
    return "tenses";
  }
  if (normalized.includes("preposition")) {
    return "prepositions";
  }
  if (normalized.includes("subject")) {
    return "subjectVerbAgreement";
  }
  if (normalized.includes("sentence")) {
    return "sentenceStructure";
  }
  if (normalized.includes("punctuation")) {
    return "punctuation";
  }
  if (normalized.includes("choice") || normalized.includes("collocation")) {
    return "wordChoice";
  }
  if (normalized.includes("vocabulary")) {
    return "vocabularyRange";
  }
  if (normalized.includes("coherence")) {
    return "coherence";
  }
  if (normalized.includes("cohesion")) {
    return "cohesion";
  }
  if (normalized.includes("task")) {
    return "taskAchievement";
  }

  return normalized.replace(/[^a-zA-Z0-9]/g, "");
}

function countWords(text: string): number {
  return text.match(/\S+/g)?.length ?? 0;
}

function readString(value: unknown, fallback: string): string {
  return typeof value === "string" && value.trim() ? value.trim() : fallback;
}

function readNumber(value: unknown, fallback: number): number {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}
