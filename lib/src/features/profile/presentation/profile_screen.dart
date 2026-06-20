import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:ai_coach/src/core/design/app_components.dart';
import 'package:ai_coach/src/core/design/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(writingCoachProvider);
    final user = state.user;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return AppScreen(
      screenKey: const ValueKey('screen-profile'),
      title: 'Profile',
      children: [
        _ProfileHeader(user: user),
        Row(
          children: [
            Expanded(
              child: AppMetricTile(
                value: '${user.writingHealthScore}',
                label: 'Health',
                accent: context.colors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppMetricTile(
                value: '${state.essays.length}',
                label: 'Essays',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppMetricTile(
                value: '${user.currentStreak}',
                label: 'Streak',
                accent: context.colors.warn,
              ),
            ),
          ],
        ),
        const AppSectionHeader(title: 'Exam target'),
        DesignCard(
          child: Column(
            children: [
              _ExamOption(
                title: 'IELTS Academic',
                subtitle: 'Band target ${ExamType.ielts.goalLabel}',
                selected: user.examType == ExamType.ielts,
                onTap: () => ref
                    .read(writingCoachProvider.notifier)
                    .selectExam(ExamType.ielts),
              ),
              Divider(height: 24, color: context.colors.line),
              _ExamOption(
                title: 'TOEFL iBT',
                subtitle: 'Score target ${ExamType.toefl.goalLabel}',
                selected: user.examType == ExamType.toefl,
                onTap: () => ref
                    .read(writingCoachProvider.notifier)
                    .selectExam(ExamType.toefl),
              ),
            ],
          ),
        ),
        const AppSectionHeader(title: 'Account'),
        DesignCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingsRow(
                icon: Icons.bolt_rounded,
                label: 'Credit balance',
                detail: '${user.credits} remaining',
              ),
              Divider(height: 1, indent: 62, color: context.colors.line),
              _SettingsRow(
                icon: Icons.email_outlined,
                label: 'Email',
                detail: user.email,
              ),
              Divider(height: 1, indent: 62, color: context.colors.line),
              _SettingsRow(
                icon: Icons.notifications_none_rounded,
                label: 'Reminders',
                detail: 'Daily 9:00',
              ),
              Divider(height: 1, indent: 62, color: context.colors.line),
              _SettingsRow(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                danger: true,
                onTap: () => ref.read(writingCoachProvider.notifier).signOut(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GradientCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primaryTintStrong, colors.primary],
              ),
            ),
            child: Center(
              child: Text(
                user.initials,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.primaryInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    AppPill(label: '${user.examType.label} Academic'),
                    AppPill(label: 'Target ${user.examType.goalLabel}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamOption extends StatelessWidget {
  const _ExamOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      borderRadius: AppSpacing.mediumRadius,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? colors.primary : colors.ink4,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.ink2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.detail,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = danger ? colors.bad : colors.ink3;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            IconBadge(
              icon: icon,
              size: 32,
              backgroundColor: danger ? colors.badTint : colors.sunken,
              foregroundColor: accent,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: danger ? colors.bad : colors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (detail != null)
              Flexible(
                child: Text(
                  detail!,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.ink3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (!danger) Icon(Icons.chevron_right_rounded, color: colors.ink4),
          ],
        ),
      ),
    );
  }
}
