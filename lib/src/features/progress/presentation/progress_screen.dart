import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:ai_coach/src/core/design/app_components.dart';
import 'package:ai_coach/src/core/design/app_spacing.dart';
import 'package:ai_coach/src/core/design/app_typography.dart';
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
      subtitle: 'Last 8 weeks',
      children: [
        _TrendCard(score: state.averageScore),
        _ReadinessCard(score: state.averageScore),
        const AppSectionHeader(title: 'Metric changes'),
        Row(
          children: [
            Expanded(
              child: AppMetricTile(
                value: '+12',
                label: 'Grammar',
                accent: context.colors.bad,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppMetricTile(
                value: '+8',
                label: 'Vocabulary',
                accent: context.colors.primary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: AppMetricTile(
                value: '+6',
                label: 'Coherence',
                accent: context.colors.warn,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppMetricTile(
                value: '-41%',
                label: 'Errors / essay',
                accent: context.colors.good,
              ),
            ),
          ],
        ),
        if (latest == null)
          _EmptyProgressCard(
            onWrite: () =>
                ref.read(selectedTabProvider.notifier).select(AppTab.write),
          )
        else ...[
          const AppSectionHeader(title: 'Error frequency'),
          _ErrorStats(analysis: latest.analysis),
          const AppSectionHeader(title: 'Latest skill breakdown'),
          _SkillBreakdown(analysis: latest.analysis),
          const AppSectionHeader(title: 'Essay history'),
          ...state.essays.map((essay) => _EssayHistoryTile(essay: essay)),
        ],
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.score});

  final int score;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Writing Health Score',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Trending up steadily',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.ink3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$score',
                    style: AppTypography.number(
                      colors: colors,
                      size: 34,
                      weight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '+14 pts',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.good,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 136,
            child: CustomPaint(
              painter: _ProgressChartPainter(colors.primaryTintStrong),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressChartPainter extends CustomPainter {
  const _ProgressChartPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset(0, size.height * 0.76),
      Offset(size.width * 0.14, size.height * 0.7),
      Offset(size.width * 0.28, size.height * 0.74),
      Offset(size.width * 0.43, size.height * 0.57),
      Offset(size.width * 0.58, size.height * 0.6),
      Offset(size.width * 0.74, size.height * 0.36),
      Offset(size.width * 0.88, size.height * 0.32),
      Offset(size.width, size.height * 0.18),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height - 16)
      ..lineTo(0, size.height - 16)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressChartPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final readiness = (score + 8).clamp(0, 100);

    return GradientCard(
      accent: colors.good,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exam readiness',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.ink3,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Nearly there',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Closing the grammar gap takes you past 90% readiness.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.ink2,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          ScoreRing(
            value: readiness,
            size: 104,
            color: colors.good,
            child: Text(
              '$readiness%',
              style: AppTypography.number(
                colors: colors,
                size: 26,
                weight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
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
          IconBadge(icon: Icons.stacked_line_chart_rounded),
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
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stat.label,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: colors.ink,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Text(
                          '${stat.count}x',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: colors.bad,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppProgressBar(
                      value: (stat.count / 6).clamp(0, 1).toDouble(),
                      color: colors.bad,
                      height: 7,
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
          IconBadge(icon: Icons.article_outlined),
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
                  '${essay.wordCount} words - ${essay.normalizedScore}/100',
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
            style: AppTypography.number(
              colors: colors,
              size: 22,
              color: colors.primary,
              weight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
