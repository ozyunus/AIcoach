import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/core/config/app_runtime_config.dart';
import 'package:ai_coach/src/core/firebase/firebase_bootstrap.dart';
import 'package:ai_coach/src/features/auth/data/firebase_auth_repository.dart';
import 'package:ai_coach/src/features/auth/data/mock_auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppRuntimeConfig.autoPreviewSignIn) {
    return MockAuthRepository(signedIn: true);
  }

  final bootstrap = ref.watch(firebaseBootstrapProvider);

  if (bootstrap.isReady) {
    return FirebaseAuthRepository();
  }

  return MockAuthRepository();
});

abstract class AuthRepository {
  bool get isFirebaseBacked;

  UserProfile? get currentUser;

  Future<UserProfile?> refreshCurrentUser();

  Future<UserProfile> signInWithGoogle();

  Future<UserProfile> signInWithApple();

  Future<void> updateExamType(ExamType examType);

  Future<void> signOut();
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
