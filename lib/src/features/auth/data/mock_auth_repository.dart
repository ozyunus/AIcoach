import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/features/auth/data/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserProfile? _currentUser;

  @override
  bool get isFirebaseBacked => false;

  @override
  UserProfile? get currentUser => _currentUser;

  @override
  Future<UserProfile?> refreshCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    return _signIn(
      id: 'mock-google-user',
      email: 'yunus@example.com',
      nickname: 'Yunus',
    );
  }

  @override
  Future<UserProfile> signInWithApple() async {
    return _signIn(
      id: 'mock-apple-user',
      email: 'writer@icloud.com',
      nickname: 'Apple Writer',
    );
  }

  @override
  Future<void> updateExamType(ExamType examType) async {
    final user = _currentUser;
    if (user == null) {
      return;
    }

    _currentUser = user.copyWith(examType: examType);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  UserProfile _signIn({
    required String id,
    required String email,
    required String nickname,
  }) {
    _currentUser = UserProfile(
      id: id,
      email: email,
      nickname: nickname,
      examType: ExamType.ielts,
      credits: 3,
      writingHealthScore: 62,
      currentStreak: 0,
      createdAt: DateTime.now(),
    );

    return _currentUser!;
  }
}
