import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:ai_coach/src/core/design/app_components.dart';
import 'package:ai_coach/src/core/design/app_spacing.dart';
import 'package:ai_coach/src/features/shell/application/app_tab.dart';
import 'package:ai_coach/src/features/shell/application/selected_tab_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(writingCoachProvider);
    final latest = state.lastEssay;

    return AppScreen(
      screenKey: const ValueKey('screen-progress'),
      title: 'Progress',
      children: [
        DesignCard(
          child: Row(
            children: [
              Expanded(
                child: AppMetricTile(
                  value: '${state.averageScore}',
                  label: 'Health score',
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
                  value: '${state.repeatedMistakes}',
                  label: 'Errors',
                  accent: context.colors.bad,
                ),
              ),
            ],
          ),
        ),
        if (latest == null)
          _EmptyProgressCard(
            onWrite: () =>
                ref.read(selectedTabProvider.notifier).select(AppTab.write),
          )
        else ...[
          const AppSectionHeader(title: 'Latest skill breakdown'),
          _SkillBreakdown(analysis: latest.analysis),
          const AppSectionHeader(title: 'Repeated mistakes'),
          _ErrorStats(analysis: latest.analysis),
          const AppSectionHeader(title: 'Essay history'),
          ...state.essays.map((essay) => _EssayHistoryTile(essay: essay)),
        ],
      ],
    );
  }
}

class _EmptyProgressCard extends StatelessWidget {
  const _EmptyProgressCard({required this.onWrite});

  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.stacked_line_chart_rounded,
            color: colors.primary,
            size: 34,
          ),
          const SizedBox(height: 14),
          Text(
            'Progress starts after your first essay.',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Submit an essay to generate skill scores, recurring error categories, and your first Writing Health update.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.ink2, height: 1.45),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onWrite,
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Write first essay'),
          ),
        ],
      ),
    );
  }
}

class _SkillBreakdown extends StatelessWidget {
  const _SkillBreakdown({required this.analysis});

  final EssayAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      child: Column(
        children: analysis.skillScores
            .map(
              (skill) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SkillProgress(skill: skill),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SkillProgress extends StatelessWidget {
  const _SkillProgress({required this.skill});

  final SkillScore skill;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final score = skill.score.clamp(0, 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                skill.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$score',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        AppProgressBar(value: score / 100, height: 7),
      ],
    );
  }
}

class _ErrorStats extends StatelessWidget {
  const _ErrorStats({required this.analysis});

  final EssayAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (analysis.errorStats.isEmpty) {
      return DesignCard(
        child: Text(
          'No repeated categories detected in the latest mock analysis.',
          style: TextStyle(color: colors.ink2),
        ),
      );
    }

    return DesignCard(
      child: Column(
        children: analysis.errorStats
            .map(
              (stat) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        stat.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    AppPill(
                      label: '${stat.count}',
                      backgroundColor: colors.badTint,
                      foregroundColor: colors.bad,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _EssayHistoryTile extends StatelessWidget {
  const _EssayHistoryTile({required this.essay});

  final EssayRecord essay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DesignCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: AppSpacing.mediumRadius,
            ),
            child: Icon(Icons.article_outlined, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  essay.prompt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${essay.wordCount} words · ${essay.normalizedScore}/100',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.ink2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            essay.rawScore,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
