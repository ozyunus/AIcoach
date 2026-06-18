import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/core/firebase/firebase_bootstrap.dart';
import 'package:ai_coach/src/features/write/data/firebase_essay_repository.dart';
import 'package:ai_coach/src/features/write/data/firebase_functions_essay_repository.dart';
import 'package:ai_coach/src/features/write/data/mock_essay_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _useFunctionsEssaySubmit = bool.fromEnvironment('AI_COACH_USE_FUNCTIONS');

final essayRepositoryProvider = Provider<EssayRepository>((ref) {
  final bootstrap = ref.watch(firebaseBootstrapProvider);

  if (bootstrap.isReady && _useFunctionsEssaySubmit) {
    return FirebaseFunctionsEssayRepository();
  }

  if (bootstrap.isReady) {
    return FirebaseEssayRepository();
  }

  return MockEssayRepository();
});

abstract class EssayRepository {
  bool get isFirebaseBacked;

  Future<List<EssayRecord>> fetchRecentEssays(String userId);

  Future<EssaySubmissionResult> submitEssay({
    required UserProfile user,
    required String prompt,
    required String essayText,
  });
}

class EssaySubmissionResult {
  const EssaySubmissionResult({required this.user, required this.essay});

  final UserProfile user;
  final EssayRecord essay;
}

class EssayRepositoryException implements Exception {
  const EssayRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
