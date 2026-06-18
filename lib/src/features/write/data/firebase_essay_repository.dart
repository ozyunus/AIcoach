import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/features/write/data/essay_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseEssayRepository implements EssayRepository {
  FirebaseEssayRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  bool get isFirebaseBacked => true;

  @override
  Future<List<EssayRecord>> fetchRecentEssays(String userId) async {
    final snapshot = await _firestore
        .collection('essays')
        .where('userId', isEqualTo: userId)
        .limit(20)
        .get();

    final essays = <EssayRecord>[];
    for (final essayDoc in snapshot.docs) {
      final analysisDoc = await _firestore
          .collection('essay_analyses')
          .doc(essayDoc.id)
          .get();
      essays.add(_essayFromFirestore(essayDoc, analysisDoc.data()));
    }

    essays.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return essays;
  }

  @override
  Future<EssaySubmissionResult> submitEssay({
    required UserProfile user,
    required String prompt,
    required String essayText,
  }) async {
    final cleanEssay = essayText.trim();
    if (cleanEssay.isEmpty) {
      throw const EssayRepositoryException('Essay text is empty.');
    }

    final analysis = EssayAnalysis.mockFor(cleanEssay);
    final userRef = _firestore.collection('users').doc(user.id);
    final essayRef = _firestore.collection('essays').doc();
    final analysisRef = _firestore
        .collection('essay_analyses')
        .doc(essayRef.id);
    final errorStatsRef = _firestore
        .collection('user_error_stats')
        .doc(user.id);
    final wordCount = RegExp(r'\S+').allMatches(cleanEssay).length;
    final rawScore = double.tryParse(analysis.rawScore) ?? 0;
    final scores = _scoresByKey(analysis);

    final updatedUser = await _firestore.runTransaction<UserProfile>((
      transaction,
    ) async {
      final userSnapshot = await transaction.get(userRef);
      final userData = userSnapshot.data() ?? <String, dynamic>{};
      final credits = userData['credits'] as int? ?? user.credits;

      if (credits <= 0) {
        throw const EssayRepositoryException('You are out of essay credits.');
      }

      final previousTotal = userData['totalEssaysAnalyzed'] as int? ?? 0;
      final previousHealth =
          userData['writingHealthScore'] as int? ?? user.writingHealthScore;
      final nextTotal = previousTotal + 1;
      final nextHealth =
          ((previousHealth * previousTotal + analysis.normalizedScore) /
                  nextTotal)
              .round();
      final nextStreak =
          (userData['currentStreak'] as int? ?? user.currentStreak) + 1;
      final nextCredits = credits - 1;
      final createdAt = FieldValue.serverTimestamp();

      transaction.set(essayRef, {
        'id': essayRef.id,
        'userId': user.id,
        'examType': user.examType.name,
        'prompt': prompt,
        'essayText': cleanEssay,
        'wordCount': wordCount,
        'rawScore': rawScore,
        'normalizedScore': analysis.normalizedScore,
        'grammarScore': scores['grammar'] ?? analysis.normalizedScore,
        'vocabularyScore': scores['vocabulary'] ?? analysis.normalizedScore,
        'coherenceScore': scores['coherence'] ?? analysis.normalizedScore,
        'taskAchievementScore':
            scores['taskAchievement'] ?? analysis.normalizedScore,
        'createdAt': createdAt,
      });

      transaction.set(analysisRef, {
        'id': analysisRef.id,
        'essayId': essayRef.id,
        'userId': user.id,
        'schemaVersion': '1.0',
        'grammarErrors': analysis.corrections
            .map(
              (correction) => {
                'category': _errorKey(correction.type),
                'original': correction.original,
                'correction': correction.corrected,
                'explanation': correction.explanation,
              },
            )
            .toList(),
        'vocabularySuggestions': analysis.vocabularySuggestions
            .map((suggestion) => _vocabularySuggestionMap(suggestion))
            .toList(),
        'generalFeedback': analysis.generalFeedback,
        'createdAt': createdAt,
      });

      transaction.set(errorStatsRef, {
        'userId': user.id,
        for (final stat in analysis.errorStats)
          _errorKey(stat.label): FieldValue.increment(stat.count),
        'updatedAt': createdAt,
      }, SetOptions(merge: true));

      transaction.set(userRef, {
        'credits': nextCredits,
        'writingHealthScore': nextHealth,
        'currentStreak': nextStreak,
        'totalEssaysAnalyzed': nextTotal,
        'updatedAt': createdAt,
      }, SetOptions(merge: true));

      return user.copyWith(
        credits: nextCredits,
        writingHealthScore: nextHealth,
        currentStreak: nextStreak,
      );
    });

    final essay = EssayRecord(
      id: essayRef.id,
      prompt: prompt,
      essayText: cleanEssay,
      wordCount: wordCount,
      rawScore: analysis.rawScore,
      normalizedScore: analysis.normalizedScore,
      createdAt: DateTime.now(),
      analysis: analysis,
    );

    return EssaySubmissionResult(user: updatedUser, essay: essay);
  }

  EssayRecord _essayFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> essayDoc,
    Map<String, dynamic>? analysisData,
  ) {
    final data = essayDoc.data();
    final analysis = _analysisFromFirestore(data, analysisData);

    return EssayRecord(
      id: data['id'] as String? ?? essayDoc.id,
      prompt: data['prompt'] as String? ?? WritingCoachController.samplePrompt,
      essayText: data['essayText'] as String? ?? '',
      wordCount: data['wordCount'] as int? ?? 0,
      rawScore: _rawScoreLabel(data['rawScore']),
      normalizedScore: data['normalizedScore'] as int? ?? 0,
      createdAt: _dateTimeFromFirestore(data['createdAt']) ?? DateTime.now(),
      analysis: analysis,
    );
  }

  EssayAnalysis _analysisFromFirestore(
    Map<String, dynamic> essayData,
    Map<String, dynamic>? analysisData,
  ) {
    final grammarErrors = analysisData?['grammarErrors'];
    final vocabularySuggestions = analysisData?['vocabularySuggestions'];
    final normalizedScore = essayData['normalizedScore'] as int? ?? 0;

    return EssayAnalysis(
      rawScore: _rawScoreLabel(essayData['rawScore']),
      normalizedScore: normalizedScore,
      generalFeedback:
          analysisData?['generalFeedback'] as String? ??
          'Analysis saved, but no feedback text was found.',
      skillScores: [
        SkillScore(
          'Task Achievement',
          essayData['taskAchievementScore'] as int? ?? normalizedScore,
        ),
        SkillScore(
          'Coherence',
          essayData['coherenceScore'] as int? ?? normalizedScore,
        ),
        SkillScore(
          'Vocabulary',
          essayData['vocabularyScore'] as int? ?? normalizedScore,
        ),
        SkillScore(
          'Grammar',
          essayData['grammarScore'] as int? ?? normalizedScore,
        ),
      ],
      corrections: grammarErrors is List
          ? grammarErrors
                .whereType<Map>()
                .map(
                  (item) => Correction(
                    type: item['category'] as String? ?? 'grammar',
                    original: item['original'] as String? ?? '',
                    corrected: item['correction'] as String? ?? '',
                    explanation: item['explanation'] as String? ?? '',
                  ),
                )
                .toList()
          : const [],
      vocabularySuggestions: vocabularySuggestions is List
          ? vocabularySuggestions.whereType<Map>().map((item) {
              final original = item['original'] as String? ?? '';
              final better = item['better'] as String? ?? '';
              if (original.isEmpty && better.isEmpty) {
                return item.toString();
              }
              return '$original -> $better';
            }).toList()
          : const [],
      errorStats: grammarErrors is List
          ? _errorStatsFromCorrections(grammarErrors)
          : const [],
    );
  }

  Map<String, int> _scoresByKey(EssayAnalysis analysis) {
    final scores = <String, int>{};
    for (final skill in analysis.skillScores) {
      final key = switch (skill.label.toLowerCase()) {
        final label when label.contains('grammar') => 'grammar',
        final label when label.contains('vocabulary') => 'vocabulary',
        final label when label.contains('coherence') => 'coherence',
        final label when label.contains('task') => 'taskAchievement',
        _ => skill.label,
      };
      scores[key] = skill.score.clamp(0, 100).toInt();
    }
    return scores;
  }

  Map<String, String> _vocabularySuggestionMap(String suggestion) {
    final parts = suggestion.split(' -> ');

    if (parts.length != 2) {
      return {
        'original': suggestion,
        'better': suggestion,
        'reason': 'Suggested vocabulary upgrade.',
      };
    }

    return {
      'original': parts.first,
      'better': parts.last,
      'reason': 'More natural academic wording.',
    };
  }

  List<ErrorStat> _errorStatsFromCorrections(List<Object?> corrections) {
    final counts = <String, int>{};
    for (final item in corrections.whereType<Map>()) {
      final key = item['category'] as String? ?? 'grammar';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return counts.entries
        .map((entry) => ErrorStat(entry.key, entry.value))
        .toList();
  }

  String _errorKey(String label) {
    final normalized = label.toLowerCase();

    if (normalized.contains('article')) {
      return 'articles';
    }
    if (normalized.contains('tense')) {
      return 'tenses';
    }
    if (normalized.contains('preposition')) {
      return 'prepositions';
    }
    if (normalized.contains('subject')) {
      return 'subjectVerbAgreement';
    }
    if (normalized.contains('sentence')) {
      return 'sentenceStructure';
    }
    if (normalized.contains('punctuation')) {
      return 'punctuation';
    }
    if (normalized.contains('choice') || normalized.contains('collocation')) {
      return 'wordChoice';
    }
    if (normalized.contains('vocabulary')) {
      return 'vocabularyRange';
    }
    if (normalized.contains('coherence')) {
      return 'coherence';
    }
    if (normalized.contains('cohesion')) {
      return 'cohesion';
    }
    if (normalized.contains('task')) {
      return 'taskAchievement';
    }

    return normalized.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  String _rawScoreLabel(Object? value) {
    if (value is num) {
      return value.toStringAsFixed(1);
    }
    return value as String? ?? '0.0';
  }

  DateTime? _dateTimeFromFirestore(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
