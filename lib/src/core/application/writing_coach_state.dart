import 'package:ai_coach/src/features/auth/data/auth_repository.dart';
import 'package:ai_coach/src/core/design/app_theme_mode.dart';
import 'package:ai_coach/src/features/write/data/essay_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final writingCoachProvider =
    NotifierProvider<WritingCoachController, WritingCoachState>(
      WritingCoachController.new,
    );

class WritingCoachController extends Notifier<WritingCoachState> {
  static const samplePrompt =
      'Some people believe technology has made our lives too complex. '
      'To what extent do you agree?';

  static const sampleEssay =
      'In recent years, public transport has become a central topic in city '
      'planning. Government should invest in public transport to reduce the '
      'traffic. This will make a big advantage for people who travel every day.\n\n'
      'Cars cause pollution, they should be limited in city centres. If cities '
      'build better trains and buses, more people will choose them over private '
      'vehicles.';

  @override
  WritingCoachState build() {
    final repository = ref.watch(authRepositoryProvider);
    final initialState = WritingCoachState.initial(
      user: repository.currentUser,
    );

    if (initialState.user != null) {
      Future<void>.microtask(_restoreCurrentSession);
    }

    return initialState;
  }

  Future<void> _restoreCurrentSession() async {
    final initialUserId = state.user?.id;
    if (initialUserId == null) {
      return;
    }

    state = state.copyWith(
      isLoadingEssays: true,
      clearAuthError: true,
      clearEssayError: true,
    );

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.refreshCurrentUser();

      if (state.user?.id != initialUserId) {
        return;
      }

      if (user == null) {
        state = WritingCoachState.initial();
        return;
      }

      state = state.copyWith(user: user);
      await loadRecentEssays();
    } on Object catch (error) {
      if (state.user?.id != initialUserId) {
        return;
      }

      state = state.copyWith(
        isLoadingEssays: false,
        authError: _friendlyError(error),
      );
    }
  }

  Future<void> signIn(AuthProvider provider) async {
    state = state.copyWith(isAuthenticating: true, clearAuthError: true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = switch (provider) {
        AuthProvider.google => await repository.signInWithGoogle(),
        AuthProvider.apple => await repository.signInWithApple(),
      };

      state = WritingCoachState.initial(user: user);
      await loadRecentEssays();
    } on Object catch (error) {
      state = state.copyWith(
        isAuthenticating: false,
        authError: _friendlyError(error),
      );
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = WritingCoachState.initial();
  }

  Future<void> selectExam(ExamType examType) async {
    final user = state.user;
    if (user == null) {
      return;
    }

    state = state.copyWith(user: user.copyWith(examType: examType));

    try {
      await ref.read(authRepositoryProvider).updateExamType(examType);
    } on Object catch (error) {
      state = state.copyWith(authError: _friendlyError(error));
    }
  }

  void cycleThemeMode() {
    state = state.copyWith(themeMode: state.themeMode.next);
  }

  void updateDraft(String value) {
    state = state.copyWith(draftEssay: value);
  }

  void loadSampleEssay() {
    state = state.copyWith(draftEssay: sampleEssay);
  }

  void clearDraft() {
    state = state.copyWith(draftEssay: '');
  }

  Future<void> loadRecentEssays() async {
    final user = state.user;
    if (user == null) {
      return;
    }

    state = state.copyWith(isLoadingEssays: true, clearEssayError: true);

    try {
      final essays = await ref
          .read(essayRepositoryProvider)
          .fetchRecentEssays(user.id);

      if (state.user?.id != user.id) {
        return;
      }

      state = state.copyWith(essays: essays, isLoadingEssays: false);
    } on Object catch (error) {
      if (state.user?.id != user.id) {
        return;
      }

      state = state.copyWith(
        isLoadingEssays: false,
        essayError: _friendlyError(error),
      );
    }
  }

  Future<void> submitEssay() async {
    final user = state.user;
    if (user == null || state.wordCount < 20 || state.isSubmittingEssay) {
      return;
    }

    if (user.credits <= 0) {
      state = state.copyWith(essayError: 'You are out of essay credits.');
      return;
    }

    final draftEssay = state.draftEssay;
    state = state.copyWith(isSubmittingEssay: true, clearEssayError: true);

    try {
      final result = await ref
          .read(essayRepositoryProvider)
          .submitEssay(user: user, prompt: samplePrompt, essayText: draftEssay);

      if (state.user?.id != user.id) {
        return;
      }

      state = state.copyWith(
        user: result.user,
        essays: [result.essay, ...state.essays],
        latestAnalysis: result.essay.analysis,
        draftEssay: '',
        isSubmittingEssay: false,
      );
    } on Object catch (error) {
      if (state.user?.id != user.id) {
        return;
      }

      state = state.copyWith(
        isSubmittingEssay: false,
        essayError: _friendlyError(error),
      );
    }
  }

  String _friendlyError(Object error) {
    if (error is AuthRepositoryException) {
      return error.message;
    }

    if (error is EssayRepositoryException) {
      return error.message;
    }

    return error.toString();
  }
}

class WritingCoachState {
  const WritingCoachState({
    required this.user,
    required this.essays,
    required this.challenges,
    required this.draftEssay,
    required this.latestAnalysis,
    required this.themeMode,
    required this.isAuthenticating,
    required this.isLoadingEssays,
    required this.isSubmittingEssay,
    required this.authError,
    required this.essayError,
  });

  final UserProfile? user;
  final List<EssayRecord> essays;
  final List<ChallengeProgress> challenges;
  final String draftEssay;
  final EssayAnalysis? latestAnalysis;
  final WritingCoachThemeMode themeMode;
  final bool isAuthenticating;
  final bool isLoadingEssays;
  final bool isSubmittingEssay;
  final String? authError;
  final String? essayError;

  bool get isSignedIn => user != null;
  EssayRecord? get lastEssay => essays.isEmpty ? null : essays.first;

  int get wordCount {
    final text = draftEssay.trim();
    if (text.isEmpty) {
      return 0;
    }

    return RegExp(r'\S+').allMatches(text).length;
  }

  double get targetProgress => (wordCount / 250).clamp(0, 1);

  int get essaysThisMonth => essays.length;

  int get averageScore {
    if (essays.isEmpty) {
      return user?.writingHealthScore ?? 0;
    }

    return essays
            .map((essay) => essay.normalizedScore)
            .reduce((value, element) => value + element) ~/
        essays.length;
  }

  int get repeatedMistakes {
    if (essays.isEmpty) {
      return 0;
    }

    return essays
        .expand((essay) => essay.analysis.errorStats)
        .fold(0, (total, stat) => total + stat.count);
  }

  factory WritingCoachState.initial({UserProfile? user}) {
    return WritingCoachState(
      user: user,
      essays: [],
      challenges: const [
        ChallengeProgress(
          title: '5-Day Writing Streak',
          description: 'Write one essay per day for five days.',
          progress: 0,
          total: 5,
          rewardCredits: 1,
        ),
        ChallengeProgress(
          title: 'Article Error Reduction',
          description: 'Cut article mistakes in your next three essays.',
          progress: 0,
          total: 3,
          rewardCredits: 2,
        ),
        ChallengeProgress(
          title: 'Vocabulary Upgrade',
          description: 'Use ten stronger academic collocations.',
          progress: 0,
          total: 10,
          rewardCredits: 1,
        ),
      ],
      draftEssay: '',
      latestAnalysis: null,
      themeMode: WritingCoachThemeMode.dark,
      isAuthenticating: false,
      isLoadingEssays: false,
      isSubmittingEssay: false,
      authError: null,
      essayError: null,
    );
  }

  WritingCoachState copyWith({
    UserProfile? user,
    List<EssayRecord>? essays,
    List<ChallengeProgress>? challenges,
    String? draftEssay,
    EssayAnalysis? latestAnalysis,
    WritingCoachThemeMode? themeMode,
    bool? isAuthenticating,
    bool? isLoadingEssays,
    bool? isSubmittingEssay,
    String? authError,
    String? essayError,
    bool clearAuthError = false,
    bool clearEssayError = false,
  }) {
    return WritingCoachState(
      user: user ?? this.user,
      essays: essays ?? this.essays,
      challenges: challenges ?? this.challenges,
      draftEssay: draftEssay ?? this.draftEssay,
      latestAnalysis: latestAnalysis ?? this.latestAnalysis,
      themeMode: themeMode ?? this.themeMode,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      isLoadingEssays: isLoadingEssays ?? this.isLoadingEssays,
      isSubmittingEssay: isSubmittingEssay ?? this.isSubmittingEssay,
      authError: clearAuthError ? null : authError ?? this.authError,
      essayError: clearEssayError ? null : essayError ?? this.essayError,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.nickname,
    required this.examType,
    required this.credits,
    required this.writingHealthScore,
    required this.currentStreak,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String nickname;
  final ExamType examType;
  final int credits;
  final int writingHealthScore;
  final int currentStreak;
  final DateTime createdAt;

  String get initials {
    final parts = nickname.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'WC';
    }

    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? nickname,
    ExamType? examType,
    int? credits,
    int? writingHealthScore,
    int? currentStreak,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      examType: examType ?? this.examType,
      credits: credits ?? this.credits,
      writingHealthScore: writingHealthScore ?? this.writingHealthScore,
      currentStreak: currentStreak ?? this.currentStreak,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum AuthProvider { google, apple }

enum ExamType {
  ielts('IELTS', 'Band', '7.5'),
  toefl('TOEFL', 'Score', '28');

  const ExamType(this.label, this.scoreLabel, this.goalLabel);

  final String label;
  final String scoreLabel;
  final String goalLabel;
}

class EssayRecord {
  const EssayRecord({
    required this.id,
    required this.prompt,
    required this.essayText,
    required this.wordCount,
    required this.rawScore,
    required this.normalizedScore,
    required this.createdAt,
    required this.analysis,
  });

  final String id;
  final String prompt;
  final String essayText;
  final int wordCount;
  final String rawScore;
  final int normalizedScore;
  final DateTime createdAt;
  final EssayAnalysis analysis;
}

class EssayAnalysis {
  const EssayAnalysis({
    required this.rawScore,
    required this.normalizedScore,
    required this.generalFeedback,
    required this.skillScores,
    required this.corrections,
    required this.vocabularySuggestions,
    required this.errorStats,
  });

  final String rawScore;
  final int normalizedScore;
  final String generalFeedback;
  final List<SkillScore> skillScores;
  final List<Correction> corrections;
  final List<String> vocabularySuggestions;
  final List<ErrorStat> errorStats;

  factory EssayAnalysis.mockFor(String essayText) {
    final wordCount = RegExp(r'\S+').allMatches(essayText.trim()).length;
    final hasArticleIssue =
        essayText.contains('Government should') ||
        essayText.contains('the traffic');
    final hasCommaSplice = essayText.contains('pollution, they');
    final hasCollocationIssue = essayText.contains('make a big advantage');
    final issuePenalty =
        [
          hasArticleIssue,
          hasCommaSplice,
          hasCollocationIssue,
        ].where((issue) => issue).length *
        4;
    final lengthBonus = wordCount >= 250 ? 10 : (wordCount / 25).floor();
    final normalizedScore = (64 + lengthBonus - issuePenalty)
        .clamp(45, 88)
        .toInt();
    final rawScore = (4 + (normalizedScore / 100) * 5).toStringAsFixed(1);

    return EssayAnalysis(
      rawScore: rawScore,
      normalizedScore: normalizedScore,
      generalFeedback:
          'Your position is understandable and the essay has a usable structure. '
          'The fastest improvement will come from cleaner article usage, more '
          'natural collocations, and stronger links between claims.',
      skillScores: [
        SkillScore('Task Achievement', normalizedScore + 4),
        SkillScore('Coherence', normalizedScore),
        SkillScore('Vocabulary', normalizedScore - 7),
        SkillScore('Grammar', normalizedScore - 3),
      ],
      corrections: [
        if (hasArticleIssue)
          const Correction(
            type: 'Article usage',
            original:
                'Government should invest in public transport to reduce the traffic.',
            corrected:
                'The government should invest in public transport to reduce traffic.',
            explanation:
                'Use "the" before a specific institution, and no article before uncountable "traffic" in a general sense.',
          ),
        if (hasCollocationIssue)
          const Correction(
            type: 'Collocation',
            original: 'This will make a big advantage for people.',
            corrected:
                'This would offer a significant advantage to daily commuters.',
            explanation:
                'Prefer natural verb-noun pairs such as "offer an advantage" and a more formal noun phrase.',
          ),
        if (hasCommaSplice)
          const Correction(
            type: 'Sentence structure',
            original: 'Cars cause pollution, they should be limited.',
            corrected:
                'Cars cause pollution; therefore, they should be limited.',
            explanation:
                'Two independent clauses need a semicolon, full stop, or conjunction.',
          ),
      ],
      vocabularySuggestions: const [
        'reduce traffic -> ease congestion',
        'people who travel every day -> daily commuters',
        'big advantage -> significant advantage',
      ],
      errorStats: [
        ErrorStat('Articles', hasArticleIssue ? 2 : 0),
        ErrorStat('Word choice', hasCollocationIssue ? 1 : 0),
        ErrorStat('Sentence structure', hasCommaSplice ? 1 : 0),
      ].where((stat) => stat.count > 0).toList(),
    );
  }
}

class SkillScore {
  const SkillScore(this.label, this.score);

  final String label;
  final int score;
}

class Correction {
  const Correction({
    required this.type,
    required this.original,
    required this.corrected,
    required this.explanation,
  });

  final String type;
  final String original;
  final String corrected;
  final String explanation;
}

class ErrorStat {
  const ErrorStat(this.label, this.count);

  final String label;
  final int count;
}

class ChallengeProgress {
  const ChallengeProgress({
    required this.title,
    required this.description,
    required this.progress,
    required this.total,
    required this.rewardCredits,
  });

  final String title;
  final String description;
  final int progress;
  final int total;
  final int rewardCredits;

  double get ratio =>
      total == 0 ? 0 : (progress / total).clamp(0, 1).toDouble();
}
