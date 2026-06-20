import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:ai_coach/src/core/design/app_components.dart';
import 'package:ai_coach/src/core/design/app_spacing.dart';
import 'package:ai_coach/src/core/design/app_theme_mode.dart';
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
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          gradient: colors.isDark && !colors.isHighContrast
              ? RadialGradient(
                  center: const Alignment(0, -1.08),
                  radius: 0.95,
                  colors: [
                    colors.primary.withValues(alpha: 0.26),
                    colors.background,
                  ],
                )
              : null,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 720;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      22,
                      compact ? 10 : 14,
                      22,
                      compact ? 20 : 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconBadge(
                              icon: Icons.edit_note_rounded,
                              backgroundColor: colors.primary,
                              foregroundColor: colors.primaryInk,
                              size: 48,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Writing Coach',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colors.ink,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'IELTS & TOEFL prep',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colors.ink3,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _AuthThemeCycleButton(
                              themeMode: authState.themeMode,
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 16 : 28),
                        GradientCard(
                          padding: EdgeInsets.all(compact ? 18 : 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppPill(
                                icon: Icons.auto_awesome_rounded,
                                label: 'AI writing analysis',
                                backgroundColor: colors.primaryTint,
                                foregroundColor: colors.primaryTintStrong,
                              ),
                              SizedBox(height: compact ? 12 : 18),
                              Text(
                                'Practice smarter before exam day.',
                                style: textTheme.displaySmall?.copyWith(
                                  height: 1.02,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Track repeated mistakes, spend essay credits, and get structured feedback that matches the new Writing Health dashboard.',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colors.ink2,
                                  height: 1.42,
                                ),
                              ),
                              if (!compact) ...[
                                const SizedBox(height: 22),
                                Row(
                                  children: [
                                    ScoreRing(
                                      value: 82,
                                      size: 96,
                                      strokeWidth: 8,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '82',
                                            style: textTheme.headlineSmall
                                                ?.copyWith(
                                                  color: colors.ink,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                          Text(
                                            'Health',
                                            style: textTheme.labelSmall
                                                ?.copyWith(
                                                  color: colors.ink3,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          _AuthMetric(
                                            value: '3',
                                            label: 'free credits',
                                            color: colors.warn,
                                          ),
                                          const SizedBox(height: 10),
                                          _AuthMetric(
                                            value: '24h',
                                            label: 'daily goal rhythm',
                                            color: colors.good,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 7,
                                  runSpacing: 7,
                                  children: [
                                    AppPill(
                                      icon: Icons.bolt_rounded,
                                      label: '3 credits',
                                      backgroundColor: colors.warnTint,
                                      foregroundColor: colors.warn,
                                    ),
                                    AppPill(
                                      icon: Icons.insights_rounded,
                                      label: 'Health score',
                                      backgroundColor: colors.goodTint,
                                      foregroundColor: colors.good,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!compact) ...[
                          const SizedBox(height: 14),
                          DesignCard(
                            child: Column(
                              children: [
                                _BenefitRow(
                                  icon: Icons.check_circle_outline_rounded,
                                  text:
                                      '3 free essay analysis credits for new users',
                                ),
                                const SizedBox(height: 12),
                                _BenefitRow(
                                  icon: Icons.insights_rounded,
                                  text:
                                      'Writing Health Score and repeated error tracking',
                                ),
                                const SizedBox(height: 12),
                                _BenefitRow(
                                  icon: Icons.school_outlined,
                                  text:
                                      'IELTS Task 2 and TOEFL writing practice flow',
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: compact ? 14 : 22),
                        if (!bootstrap.isReady) ...[
                          _SetupNotice(message: bootstrap.message),
                          const SizedBox(height: 12),
                          _AuthButton(
                            key: const ValueKey('sign-in-preview'),
                            icon: Icons.visibility_outlined,
                            label: 'Continue with local preview',
                            busy: authState.isAuthenticating,
                            onPressed: () =>
                                controller.signIn(AuthProvider.google),
                          ),
                        ] else ...[
                          _AuthButton(
                            key: const ValueKey('sign-in-google'),
                            icon: Icons.g_mobiledata_rounded,
                            label: 'Continue with Google',
                            busy: authState.isAuthenticating,
                            onPressed: () =>
                                controller.signIn(AuthProvider.google),
                          ),
                          const SizedBox(height: 12),
                          _AuthButton(
                            key: const ValueKey('sign-in-apple'),
                            icon: Icons.apple_rounded,
                            label: 'Continue with Apple',
                            dark: true,
                            busy: authState.isAuthenticating,
                            onPressed: () =>
                                controller.signIn(AuthProvider.apple),
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
            },
          ),
        ),
      ),
    );
  }
}

class _AuthThemeCycleButton extends ConsumerWidget {
  const _AuthThemeCycleButton({required this.themeMode});

  final WritingCoachThemeMode themeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final icon = switch (themeMode) {
      WritingCoachThemeMode.dark => Icons.dark_mode_rounded,
      WritingCoachThemeMode.day => Icons.wb_sunny_rounded,
      WritingCoachThemeMode.accessible => Icons.cloud_rounded,
    };

    return Tooltip(
      message: '${themeMode.label} mode',
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => ref.read(writingCoachProvider.notifier).cycleThemeMode(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.isDark
                ? Colors.white.withValues(alpha: 0.055)
                : colors.sunken,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: colors.line,
              width: colors.isHighContrast ? 2 : 1,
            ),
          ),
          child: Icon(
            icon,
            color: switch (themeMode) {
              WritingCoachThemeMode.dark => colors.primaryTintStrong,
              WritingCoachThemeMode.day => colors.warn,
              WritingCoachThemeMode.accessible => colors.primary,
            },
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _AuthMetric extends StatelessWidget {
  const _AuthMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: colors.isDark ? 0.12 : 0.09),
        borderRadius: AppSpacing.smallRadius,
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.ink2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
    final background = dark
        ? (colors.isDark ? Colors.white : colors.ink)
        : colors.primary;
    final foreground = dark
        ? (colors.isDark ? colors.background : colors.primaryInk)
        : colors.primaryInk;

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
                  color: foreground,
                ),
              )
            : Icon(icon, size: 24),
        label: Text(busy ? 'Signing in...' : label),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.mediumRadius,
          ),
        ),
      ),
    );
  }
}
