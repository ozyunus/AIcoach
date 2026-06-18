import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:ai_coach/src/core/design/app_components.dart';
import 'package:ai_coach/src/features/shell/application/app_tab.dart';
import 'package:ai_coach/src/features/shell/application/selected_tab_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(writingCoachProvider);
    final user = state.user;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return AppScreen(
      screenKey: const ValueKey('screen-home'),
      title: 'Good morning, ${user.nickname}',
      children: [
        _HealthCard(state: state),
        _TodayGoalCard(
          onStart: () =>
              ref.read(selectedTabProvider.notifier).select(AppTab.write),
        ),
        const AppSectionHeader(title: 'Active challenges'),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: state.challenges.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _ChallengeMini(challenge: state.challenges[index]);
            },
          ),
        ),
        const AppSectionHeader(title: 'Latest essay'),
        _LastEssayCard(essay: state.lastEssay, examType: user.examType),
        const AppSectionHeader(title: 'This month'),
        DesignCard(
          child: Row(
            children: [
              Expanded(
                child: AppMetricTile(
                  value: '${state.essaysThisMonth}',
                  label: 'Essays',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppMetricTile(
                  value: '${state.averageScore}',
                  label: 'Health',
                  accent: context.colors.good,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppMetricTile(
                  value: '${user.currentStreak}',
                  label: 'Streak',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.state});

  final WritingCoachState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = state.user!;

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppPill(
                icon: Icons.shield_outlined,
                label: 'Writing Health',
              ),
              const Spacer(),
              AppPill(
                icon: Icons.bolt_rounded,
                label: '${user.credits} credits',
                backgroundColor: colors.goodTint,
                foregroundColor: colors.good,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.writingHealthScore}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '/100',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.ink3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppProgressBar(value: user.writingHealthScore / 100),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HealthInfo(label: 'Exam', value: user.examType.label),
              ),
              Expanded(
                child: _HealthInfo(
                  label: 'Goal',
                  value:
                      '${user.examType.scoreLabel} ${user.examType.goalLabel}',
                ),
              ),
              Expanded(
                child: _HealthInfo(
                  label: 'Mistakes',
                  value: '${state.repeatedMistakes}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthInfo extends StatelessWidget {
  const _HealthInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colors.ink3,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TodayGoalCard extends StatelessWidget {
  const _TodayGoalCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPill(
            icon: Icons.timer_outlined,
            label: '40 min practice',
            backgroundColor: colors.primaryTintStrong,
          ),
          const SizedBox(height: 12),
          Text(
            'Write one Task 2 essay today',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            WritingCoachController.samplePrompt,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.ink2, height: 1.45),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            key: const ValueKey('home-start-writing'),
            onPressed: onStart,
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Start writing'),
          ),
        ],
      ),
    );
  }
}

class _ChallengeMini extends StatelessWidget {
  const _ChallengeMini({required this.challenge});

  final ChallengeProgress challenge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: 190,
      child: DesignCard(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_outlined, color: colors.primary, size: 20),
                const Spacer(),
                Text(
                  '${challenge.progress}/${challenge.total}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              challenge.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const Spacer(),
            AppProgressBar(value: challenge.ratio, height: 6),
            const SizedBox(height: 8),
            Text(
              '+${challenge.rewardCredits} credit reward',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.ink2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LastEssayCard extends StatelessWidget {
  const _LastEssayCard({required this.essay, required this.examType});

  final EssayRecord? essay;
  final ExamType examType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final latestEssay = essay;

    if (latestEssay == null) {
      return DesignCard(
        child: Row(
          children: [
            Icon(Icons.note_add_outlined, color: colors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No essays yet. Submit your first response to unlock analysis history.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.ink2,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return DesignCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppPill(label: '${examType.label} Task 2'),
                const SizedBox(height: 10),
                Text(
                  latestEssay.prompt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  '${latestEssay.wordCount} words · ${latestEssay.normalizedScore}/100 health',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.ink2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text(
                latestEssay.rawScore,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                examType.scoreLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.ink3,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
