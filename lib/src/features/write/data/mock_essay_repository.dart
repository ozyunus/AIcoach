import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/features/write/data/essay_repository.dart';

class MockEssayRepository implements EssayRepository {
  @override
  bool get isFirebaseBacked => false;

  @override
  Future<List<EssayRecord>> fetchRecentEssays(String userId) async {
    return const [];
  }

  @override
  Future<EssaySubmissionResult> submitEssay({
    required UserProfile user,
    required String prompt,
    required String essayText,
  }) async {
    if (user.credits <= 0) {
      throw const EssayRepositoryException('You are out of essay credits.');
    }

    final analysis = EssayAnalysis.mockFor(essayText);
    final essay = EssayRecord(
      id: 'essay-${DateTime.now().millisecondsSinceEpoch}',
      prompt: prompt,
      essayText: essayText.trim(),
      wordCount: RegExp(r'\S+').allMatches(essayText.trim()).length,
      rawScore: analysis.rawScore,
      normalizedScore: analysis.normalizedScore,
      createdAt: DateTime.now(),
      analysis: analysis,
    );

    return EssaySubmissionResult(
      user: user.copyWith(
        credits: user.credits - 1,
        writingHealthScore: analysis.normalizedScore,
        currentStreak: user.currentStreak + 1,
      ),
      essay: essay,
    );
  }
}
