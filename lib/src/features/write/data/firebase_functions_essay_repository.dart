import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/features/write/data/essay_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FirebaseFunctionsEssayRepository implements EssayRepository {
  FirebaseFunctionsEssayRepository({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
  }) : _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'us-central1'),
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFunctions _functions;
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
    try {
      final callable = _functions.httpsCallable('submitEssay');
      final response = await callable.call<Map<String, dynamic>>({
        'examType': user.examType.label,
        'prompt': prompt,
        'essayText': essayText.trim(),
      });
      final data = _mapFrom(response.data);
      final userData = _mapFrom(data['user']);
      final essayData = _mapFrom(data['essay']);

      return EssaySubmissionResult(
        user: _userFromCallable(user, userData),
        essay: _essayFromCallable(prompt, essayData),
      );
    } on FirebaseFunctionsException catch (error) {
      throw EssayRepositoryException(
        error.message ?? 'Essay analysis function failed.',
      );
    } on EssayRepositoryException {
      rethrow;
    } on Object catch (error) {
      throw EssayRepositoryException(error.toString());
    }
  }

  EssayRecord _essayFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> essayDoc,
    Map<String, dynamic>? analysisData,
  ) {
    final data = essayDoc.data();
    final analysis = _analysisFromFirestore(data, analysisData);

    return EssayRecord(
      id: _asString(data['id'], essayDoc.id),
      prompt: _asString(data['prompt'], WritingCoachController.samplePrompt),
      essayText: _asString(data['essayText'], ''),
      wordCount: _asInt(data['wordCount'], 0),
      rawScore: _rawScoreLabel(data['rawScore']),
      normalizedScore: _asInt(data['normalizedScore'], 0),
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
    final normalizedScore = _asInt(essayData['normalizedScore'], 0);

    return EssayAnalysis(
      rawScore: _rawScoreLabel(essayData['rawScore']),
      normalizedScore: normalizedScore,
      generalFeedback: _asString(
        analysisData?['generalFeedback'],
        'Analysis saved, but no feedback text was found.',
      ),
      skillScores: [
        SkillScore(
          'Task Achievement',
          _asInt(essayData['taskAchievementScore'], normalizedScore),
        ),
        SkillScore(
          'Coherence',
          _asInt(essayData['coherenceScore'], normalizedScore),
        ),
        SkillScore(
          'Vocabulary',
          _asInt(essayData['vocabularyScore'], normalizedScore),
        ),
        SkillScore(
          'Grammar',
          _asInt(essayData['grammarScore'], normalizedScore),
        ),
      ],
      corrections: _correctionsFromCallable(grammarErrors),
      vocabularySuggestions: _vocabularySuggestionsFromCallable(
        vocabularySuggestions,
      ),
      errorStats: _errorStatsFromCorrections(
        _correctionsFromCallable(grammarErrors),
      ),
    );
  }

  UserProfile _userFromCallable(
    UserProfile fallback,
    Map<String, dynamic> data,
  ) {
    return fallback.copyWith(
      email: _asString(data['email'], fallback.email),
      nickname: _asString(data['nickname'], fallback.nickname),
      examType: _examTypeFromString(data['examType'], fallback.examType),
      credits: _asInt(data['credits'], fallback.credits),
      writingHealthScore: _asInt(
        data['writingHealthScore'],
        fallback.writingHealthScore,
      ),
      currentStreak: _asInt(data['currentStreak'], fallback.currentStreak),
    );
  }

  EssayRecord _essayFromCallable(
    String fallbackPrompt,
    Map<String, dynamic> data,
  ) {
    final analysis = _analysisFromCallable(_mapFrom(data['analysis']), data);

    return EssayRecord(
      id: _asString(
        data['id'],
        'essay-${DateTime.now().millisecondsSinceEpoch}',
      ),
      prompt: _asString(data['prompt'], fallbackPrompt),
      essayText: _asString(data['essayText'], ''),
      wordCount: _asInt(data['wordCount'], 0),
      rawScore: _rawScoreLabel(data['rawScore']),
      normalizedScore: _asInt(data['normalizedScore'], 0),
      createdAt: _dateTimeFromCallable(data['createdAt']) ?? DateTime.now(),
      analysis: analysis,
    );
  }

  EssayAnalysis _analysisFromCallable(
    Map<String, dynamic> analysisData,
    Map<String, dynamic> essayData,
  ) {
    final normalizedScore = _asInt(analysisData['normalizedScore'], 0);
    final skillScores = _skillScoresFromCallable(analysisData, essayData);
    final corrections = _correctionsFromCallable(analysisData['corrections']);

    return EssayAnalysis(
      rawScore: _rawScoreLabel(
        analysisData['rawScore'] ?? essayData['rawScore'],
      ),
      normalizedScore: normalizedScore,
      generalFeedback: _asString(
        analysisData['generalFeedback'],
        'Analysis completed, but no feedback text was returned.',
      ),
      skillScores: skillScores,
      corrections: corrections,
      vocabularySuggestions: _vocabularySuggestionsFromCallable(
        analysisData['vocabularySuggestions'],
      ),
      errorStats: _errorStatsFromCallable(
        analysisData['errorStats'],
      ).ifEmpty(_errorStatsFromCorrections(corrections)),
    );
  }

  List<SkillScore> _skillScoresFromCallable(
    Map<String, dynamic> analysisData,
    Map<String, dynamic> essayData,
  ) {
    final skillScores = analysisData['skillScores'];
    if (skillScores is List) {
      return skillScores.whereType<Map>().map((item) {
        final data = _mapFrom(item);
        return SkillScore(
          _asString(data['label'], 'Skill'),
          _asInt(data['score'], 0),
        );
      }).toList();
    }

    final normalizedScore = _asInt(analysisData['normalizedScore'], 0);
    return [
      SkillScore(
        'Task Achievement',
        _asInt(essayData['taskAchievementScore'], normalizedScore),
      ),
      SkillScore(
        'Coherence',
        _asInt(essayData['coherenceScore'], normalizedScore),
      ),
      SkillScore(
        'Vocabulary',
        _asInt(essayData['vocabularyScore'], normalizedScore),
      ),
      SkillScore('Grammar', _asInt(essayData['grammarScore'], normalizedScore)),
    ];
  }

  List<Correction> _correctionsFromCallable(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value.whereType<Map>().map((item) {
      final data = _mapFrom(item);
      return Correction(
        type: _asString(data['type'] ?? data['category'], 'grammar'),
        original: _asString(data['original'], ''),
        corrected: _asString(data['corrected'] ?? data['correction'], ''),
        explanation: _asString(data['explanation'], ''),
      );
    }).toList();
  }

  List<String> _vocabularySuggestionsFromCallable(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value.map((item) {
      if (item is String) {
        return item;
      }

      final data = _mapFrom(item);
      final original = _asString(data['original'], '');
      final better = _asString(data['better'], '');
      if (original.isEmpty && better.isEmpty) {
        return item.toString();
      }
      return '$original -> $better';
    }).toList();
  }

  List<ErrorStat> _errorStatsFromCallable(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) {
          final data = _mapFrom(item);
          return ErrorStat(
            _asString(data['label'] ?? data['category'], 'grammar'),
            _asInt(data['count'], 0),
          );
        })
        .where((stat) => stat.count > 0)
        .toList();
  }

  List<ErrorStat> _errorStatsFromCorrections(List<Correction> corrections) {
    final counts = <String, int>{};
    for (final correction in corrections) {
      counts[correction.type] = (counts[correction.type] ?? 0) + 1;
    }

    return counts.entries
        .map((entry) => ErrorStat(entry.key, entry.value))
        .toList();
  }

  Map<String, dynamic> _mapFrom(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }

    return const {};
  }

  String _asString(Object? value, String fallback) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  int _asInt(Object? value, int fallback) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _rawScoreLabel(Object? value) {
    if (value is num) {
      return value.toStringAsFixed(1);
    }

    return _asString(value, '0.0');
  }

  ExamType _examTypeFromString(Object? value, ExamType fallback) {
    final text = value?.toString().toLowerCase();
    if (text == null) {
      return fallback;
    }

    return ExamType.values.firstWhere(
      (examType) =>
          examType.name.toLowerCase() == text ||
          examType.label.toLowerCase() == text,
      orElse: () => fallback,
    );
  }

  DateTime? _dateTimeFromCallable(Object? value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.round());
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  DateTime? _dateTimeFromFirestore(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return _dateTimeFromCallable(value);
  }
}

extension _IterableEssayStats on List<ErrorStat> {
  List<ErrorStat> ifEmpty(List<ErrorStat> fallback) {
    return isEmpty ? fallback : this;
  }
}
