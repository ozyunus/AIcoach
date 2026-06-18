import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:ai_coach/src/core/design/app_components.dart';
import 'package:ai_coach/src/core/design/app_spacing.dart';
import 'package:ai_coach/src/core/firebase/firebase_bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(firebaseBootstrapProvider);
    final authState = ref.watch(writingCoachProvider);
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final controller = ref.read(writingCoachProvider.notifier);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: colors.primaryInk,
                  size: 34,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'AI IELTS & TOEFL Writing Coach',
                style: textTheme.displaySmall?.copyWith(height: 1.05),
              ),
              const SizedBox(height: 12),
              Text(
                'Track repeated writing mistakes, spend essay credits, and get structured feedback before exam day.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.ink2,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              DesignCard(
                child: Column(
                  children: [
                    _BenefitRow(
                      icon: Icons.check_circle_outline_rounded,
                      text: '3 free essay analysis credits for new users',
                    ),
                    const SizedBox(height: 12),
                    _BenefitRow(
                      icon: Icons.insights_rounded,
                      text: 'Writing Health Score and repeated error tracking',
                    ),
                    const SizedBox(height: 12),
                    _BenefitRow(
                      icon: Icons.school_outlined,
                      text: 'IELTS Task 2 and TOEFL writing practice flow',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!bootstrap.isReady) ...[
                _SetupNotice(message: bootstrap.message),
                const SizedBox(height: 12),
                _AuthButton(
                  key: const ValueKey('sign-in-preview'),
                  icon: Icons.visibility_outlined,
                  label: 'Continue with local preview',
                  busy: authState.isAuthenticating,
                  onPressed: () => controller.signIn(AuthProvider.google),
                ),
              ] else ...[
                _AuthButton(
                  key: const ValueKey('sign-in-google'),
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  busy: authState.isAuthenticating,
                  onPressed: () => controller.signIn(AuthProvider.google),
                ),
                const SizedBox(height: 12),
                _AuthButton(
                  key: const ValueKey('sign-in-apple'),
                  icon: Icons.apple_rounded,
                  label: 'Continue with Apple',
                  dark: true,
                  busy: authState.isAuthenticating,
                  onPressed: () => controller.signIn(AuthProvider.apple),
                ),
              ],
              if (authState.authError != null) ...[
                const SizedBox(height: 12),
                Text(
                  authState.authError!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.bad,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(icon, size: 20, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SetupNotice extends StatelessWidget {
  const _SetupNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DesignCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colors.warn, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Firebase setup is waiting for config files.',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.ink2,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.dark = false,
    this.busy = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool dark;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: busy ? null : onPressed,
        icon: busy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: colors.primaryInk,
                ),
              )
            : Icon(icon, size: 24),
        label: Text(busy ? 'Signing in...' : label),
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? colors.ink : colors.primary,
          foregroundColor: colors.primaryInk,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.mediumRadius,
          ),
        ),
      ),
    );
  }
}
