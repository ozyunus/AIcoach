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
        const AppSectionHeader(title: 'Exam target'),
        DesignCard(
          child: Column(
            children: [
              _ExamOption(
                title: 'IELTS Writing',
                subtitle: 'Band target ${ExamType.ielts.goalLabel}',
                selected: user.examType == ExamType.ielts,
                onTap: () => ref
                    .read(writingCoachProvider.notifier)
                    .selectExam(ExamType.ielts),
              ),
              Divider(height: 24, color: context.colors.line2),
              _ExamOption(
                title: 'TOEFL Writing',
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
          child: Column(
            children: [
              _InfoRow(label: 'Email', value: user.email),
              const SizedBox(height: 12),
              _InfoRow(label: 'Plan', value: 'Free MVP'),
              const SizedBox(height: 12),
              _InfoRow(label: 'Credits', value: '${user.credits} remaining'),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const ValueKey('sign-out'),
                  onPressed: () =>
                      ref.read(writingCoachProvider.notifier).signOut(),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
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

    return DesignCard(
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(20),
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
          const SizedBox(width: 14),
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
                const SizedBox(height: 5),
                Text(
                  '${user.examType.label} candidate · ${user.currentStreak} day streak',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.ink2,
                    fontWeight: FontWeight.w700,
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.ink2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
