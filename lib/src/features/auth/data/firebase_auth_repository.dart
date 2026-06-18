import 'dart:convert';
import 'dart:math';

import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/features/auth/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  bool get isFirebaseBacked => true;

  @override
  UserProfile? get currentUser {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    return _profileFromFirebaseUser(user);
  }

  @override
  Future<UserProfile?> refreshCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    return _ensureUserDocument(user);
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    if (!_googleSignIn.supportsAuthenticate()) {
      throw const AuthRepositoryException(
        'Google Sign-In is not available on this platform.',
      );
    }

    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;

    if (idToken == null) {
      throw const AuthRepositoryException(
        'Google Sign-In did not return an ID token.',
      );
    }

    final credential = firebase_auth.GoogleAuthProvider.credential(
      idToken: idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) {
      throw const AuthRepositoryException(
        'Firebase did not return a signed-in Google user.',
      );
    }

    return _ensureUserDocument(user);
  }

  @override
  Future<UserProfile> signInWithApple() async {
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );
    final identityToken = appleCredential.identityToken;

    if (identityToken == null) {
      throw const AuthRepositoryException(
        'Apple Sign-In did not return an identity token.',
      );
    }

    final credential = firebase_auth.OAuthProvider(
      'apple.com',
    ).credential(idToken: identityToken, rawNonce: rawNonce);
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) {
      throw const AuthRepositoryException(
        'Firebase did not return a signed-in Apple user.',
      );
    }

    final profile = await _ensureUserDocument(user);
    final fullName = _appleDisplayName(appleCredential);

    if (fullName == null || profile.nickname != 'Writer') {
      return profile;
    }

    await _users.doc(profile.id).set({
      'nickname': fullName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return profile.copyWith(nickname: fullName);
  }

  @override
  Future<void> updateExamType(ExamType examType) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return;
    }

    await _users.doc(uid).set({
      'examType': examType.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_googleSignIn.signOut(), _auth.signOut()]);
  }

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<UserProfile> _ensureUserDocument(firebase_auth.User user) async {
    final docRef = _users.doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      final profile = _profileFromFirebaseUser(user);
      await docRef.set({
        'id': profile.id,
        'email': profile.email,
        'nickname': profile.nickname,
        'examType': profile.examType.name,
        'credits': 3,
        'writingHealthScore': profile.writingHealthScore,
        'currentStreak': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return profile;
    }

    await docRef.set({
      'email': user.email ?? '',
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return _profileFromSnapshot(user.uid, snapshot.data() ?? {});
  }

  UserProfile _profileFromFirebaseUser(firebase_auth.User user) {
    return UserProfile(
      id: user.uid,
      email: user.email ?? '',
      nickname: _displayName(user),
      examType: ExamType.ielts,
      credits: 3,
      writingHealthScore: 62,
      currentStreak: 0,
      createdAt: DateTime.now(),
    );
  }

  UserProfile _profileFromSnapshot(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      email: data['email'] as String? ?? '',
      nickname: data['nickname'] as String? ?? 'Writer',
      examType: _examTypeFromString(data['examType'] as String?),
      credits: data['credits'] as int? ?? 3,
      writingHealthScore: data['writingHealthScore'] as int? ?? 62,
      currentStreak: data['currentStreak'] as int? ?? 0,
      createdAt: _dateTimeFromFirestore(data['createdAt']) ?? DateTime.now(),
    );
  }

  String _displayName(firebase_auth.User user) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Writer';
  }

  String? _appleDisplayName(AuthorizationCredentialAppleID credential) {
    final parts = [
      credential.givenName?.trim(),
      credential.familyName?.trim(),
    ].whereType<String>().where((part) => part.isNotEmpty).toList();

    if (parts.isEmpty) {
      return null;
    }

    return parts.join(' ');
  }

  ExamType _examTypeFromString(String? value) {
    return ExamType.values.firstWhere(
      (examType) => examType.name == value,
      orElse: () => ExamType.ielts,
    );
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

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();

    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
