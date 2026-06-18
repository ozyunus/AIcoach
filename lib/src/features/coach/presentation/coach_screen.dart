import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:ai_coach/src/core/design/app_components.dart';
import 'package:ai_coach/src/core/design/app_spacing.dart';
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
      title: 'Coach',
      children: [
        if (latest == null)
          _CoachEmptyCard(
            onWrite: () =>
                ref.read(selectedTabProvider.notifier).select(AppTab.write),
          )
        else ...[
          _CoachReportCard(essay: latest),
          const AppSectionHeader(title: 'Recommended drills'),
          ..._recommendationsFor(
            latest.analysis,
          ).map((item) => _RecommendationTile(item: item)),
        ],
        const AppSectionHeader(title: 'Challenge focus'),
        ...state.challenges.map((challenge) => _ChallengeTile(challenge)),
      ],
    );
  }

  List<_Recommendation> _recommendationsFor(EssayAnalysis analysis) {
    final focusSkill = analysis.skillScores
        .reduce((a, b) => a.score < b.score ? a : b)
        .label;

    return [
      _Recommendation(
        icon: Icons.auto_fix_high_rounded,
        title: 'Rewrite your weakest paragraph',
        meta: '10 min · $focusSkill',
      ),
      const _Recommendation(
        icon: Icons.menu_book_rounded,
        title: 'Upgrade 10 academic collocations',
        meta: '15 min · Vocabulary',
      ),
      const _Recommendation(
        icon: Icons.rule_rounded,
        title: 'Fix article usage in five sentences',
        meta: '8 min · Grammar',
      ),
    ];
  }
}

class _CoachEmptyCard extends StatelessWidget {
  const _CoachEmptyCard({required this.onWrite});

  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.psychology_alt_outlined, color: colors.primary, size: 36),
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

class _CoachReportCard extends StatelessWidget {
  const _CoachReportCard({required this.essay});

  final EssayRecord essay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final weakest = essay.analysis.skillScores.reduce(
      (a, b) => a.score < b.score ? a : b,
    );

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPill(
            icon: Icons.calendar_month_outlined,
            label: 'Mock report',
          ),
          const SizedBox(height: 14),
          Text(
            'Your next score lift is ${weakest.label.toLowerCase()}.',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(
            'You submitted ${essay.wordCount} words and scored ${essay.normalizedScore}/100. '
            'Keep the structure, then focus on the correction categories below before the next essay.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.ink2, height: 1.45),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: AppSpacing.mediumRadius,
            ),
            child: Row(
              children: [
                Icon(Icons.track_changes_rounded, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Focus area: ${weakest.label} (${weakest.score}/100)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.ink,
                      fontWeight: FontWeight.w900,
                    ),
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

class _Recommendation {
  const _Recommendation({
    required this.icon,
    required this.title,
    required this.meta,
  });

  final IconData icon;
  final String title;
  final String meta;
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.item});

  final _Recommendation item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DesignCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.violetTint,
              borderRadius: AppSpacing.mediumRadius,
            ),
            child: Icon(item.icon, color: colors.violet),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.meta,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.ink2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.ink4),
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
