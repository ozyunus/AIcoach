import 'package:ai_coach/src/app/writing_coach_app.dart';
import 'package:ai_coach/src/core/firebase/firebase_bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseBootstrap = await FirebaseBootstrap.initialize();

  runApp(
    ProviderScope(
      overrides: [
        firebaseBootstrapProvider.overrideWithValue(firebaseBootstrap),
      ],
      child: const WritingCoachApp(),
    ),
  );
}
