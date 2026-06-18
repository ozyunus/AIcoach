import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseBootstrapProvider = Provider<FirebaseBootstrapResult>(
  (ref) => FirebaseBootstrapResult.notConfigured(
    'Firebase has not been initialized for this app session.',
  ),
);

abstract final class FirebaseBootstrap {
  static Future<FirebaseBootstrapResult> initialize() async {
    try {
      await Firebase.initializeApp();
      await GoogleSignIn.instance.initialize();
      return const FirebaseBootstrapResult.ready();
    } on Object catch (error) {
      return FirebaseBootstrapResult.notConfigured(error.toString());
    }
  }
}

class FirebaseBootstrapResult {
  const FirebaseBootstrapResult._({
    required this.isReady,
    required this.message,
  });

  const FirebaseBootstrapResult.ready()
    : this._(isReady: true, message: 'Firebase is ready.');

  const FirebaseBootstrapResult.notConfigured(String message)
    : this._(isReady: false, message: message);

  final bool isReady;
  final String message;
}
