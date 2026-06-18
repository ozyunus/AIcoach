import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/core/design/app_theme.dart';
import 'package:ai_coach/src/features/auth/presentation/auth_screen.dart';
import 'package:ai_coach/src/features/shell/presentation/writing_coach_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WritingCoachApp extends ConsumerWidget {
  const WritingCoachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(
      writingCoachProvider.select((state) => state.isSignedIn),
    );

    return MaterialApp(
      title: 'Writing Coach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: isSignedIn ? const WritingCoachShell() : const AuthScreen(),
    );
  }
}
