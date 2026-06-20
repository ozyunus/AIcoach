import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:ai_coach/src/core/design/app_components.dart';
import 'package:ai_coach/src/core/design/app_typography.dart';
import 'package:ai_coach/src/features/shell/application/app_tab.dart';
import 'package:ai_coach/src/features/shell/application/selected_tab_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoachScreen extends ConsumerWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(writingCoachProvider);
    final latest = state.lastEssay;

    return AppScreen(
      screenKey: const ValueKey('screen-coach'),
      title: 'AI Coach',
      subtitle: 'Week of May 25',
      trailing: IconBadge(
        icon: Icons.auto_awesome_rounded,
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.primaryInk,
      ),
      children: [
        if (latest == null)
          _CoachEmptyCard(
            onWrite: () =>
                ref.read(selectedTabProvider.notifier).select(AppTab.write),
          )
        else ...[
          _CoachHero(essay: latest),
          _PredictionCard(essay: latest),
          const AppSectionHeader(title: 'Priority plan'),
          const _PlanRow(
            day: 'MON',
            title: 'Tense drills + 5 corrections',
            meta: '15 min',
          ),
          const _PlanRow(
            day: 'WED',
            title: 'Rewrite an essay, focus on articles',
            meta: '25 min',
          ),
          const _PlanRow(
            day: 'FRI',
            title: 'Learn 10 academic collocations',
            meta: '15 min',
          ),
          const _PlanRow(
            day: 'SUN',
            title: 'Timed Task 2 under exam conditions',
            meta: '40 min',
          ),
          _CoachQuote(essay: latest),
        ],
        const AppSectionHeader(title: 'Challenge focus'),
        ...state.challenges.map((challenge) => _ChallengeTile(challenge)),
      ],
    );
  }
}

class _CoachEmptyCard extends StatelessWidget {
  const _CoachEmptyCard({required this.onWrite});

  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GradientCard(
      accent: colors.good,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(
            icon: Icons.psychology_alt_outlined,
            backgroundColor: colors.goodTint,
            foregroundColor: colors.good,
          ),
          const SizedBox(height: 14),
          Text(
            'Your coach needs one essay first.',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Submit a response and the coach screen will turn that analysis into a focused practice plan.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.ink2, height: 1.45),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onWrite,
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Write essay'),
          ),
        ],
      ),
    );
  }
}

class _CoachHero extends StatelessWidget {
  const _CoachHero({required this.essay});

  final EssayRecord essay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final weakest = essay.analysis.skillScores.reduce(
      (a, b) => a.score < b.score ? a : b,
    );

    return GradientCard(
      accent: colors.good,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(
            icon: Icons.verified_rounded,
            backgroundColor: colors.good,
            foregroundColor: colors.background,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are on track for ${essay.analysis.rawScore == '0' ? 'your goal' : 'Band 7.5'}.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your ideas are organized. ${weakest.label} is the biggest lever for the next score lift.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.ink2,
                    height: 1.55,
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

class _PredictionCard extends StatelessWidget {
  const _PredictionCard({required this.essay});

  final EssayRecord essay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Predicted exam band',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.ink4,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                essay.rawScore,
                style: AppTypography.number(
                  colors: colors,
                  size: 28,
                  color: colors.ink3,
                  weight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, color: colors.good, size: 26),
              const SizedBox(width: 10),
              Text(
                '7.5',
                style: AppTypography.number(
                  colors: colors,
                  size: 40,
                  color: colors.good,
                  weight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              AppPill(
                label: '+8 weeks',
                backgroundColor: colors.goodTint,
                foregroundColor: colors.good,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.day, required this.title, required this.meta});

  final String day;
  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DesignCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.line),
            ),
            child: Center(
              child: Text(
                day,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.primaryTintStrong,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 13),
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
                  meta,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.ink3,
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

class _CoachQuote extends StatelessWidget {
  const _CoachQuote({required this.essay});

  final EssayRecord essay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GradientCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, color: colors.primaryTintStrong),
          const SizedBox(height: 8),
          Text(
            'Your structure is clean now. Tighten the correction categories from your last essay and the next band becomes realistic.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.ink,
              height: 1.45,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Writing Coach',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.ink3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  const _ChallengeTile(this.challenge);

  final ChallengeProgress challenge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DesignCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              AppPill(
                icon: Icons.bolt_rounded,
                label: '+${challenge.rewardCredits}',
                backgroundColor: colors.goodTint,
                foregroundColor: colors.good,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.ink2, height: 1.4),
          ),
          const SizedBox(height: 12),
          AppProgressBar(value: challenge.ratio),
        ],
      ),
    );
  }
}
