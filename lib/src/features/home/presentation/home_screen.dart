import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:ai_coach/src/core/design/app_components.dart';
import 'package:ai_coach/src/core/design/app_spacing.dart';
import 'package:ai_coach/src/core/design/app_typography.dart';
import 'package:ai_coach/src/core/design/app_theme_mode.dart';
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

    return DecoratedBox(
      key: const ValueKey('screen-home'),
      decoration: BoxDecoration(
        color: context.colors.background,
        gradient: context.colors.isDark && !context.colors.isHighContrast
            ? RadialGradient(
                center: const Alignment(0, -1.15),
                radius: 0.9,
                colors: [
                  context.colors.primary.withValues(alpha: 0.22),
                  context.colors.background,
                ],
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                10,
                AppSpacing.screenX,
                AppSpacing.bottomNavHeight + 28,
              ),
              sliver: SliverList.list(
                children: [
                  _HomeHeader(state: state),
                  const SizedBox(height: 20),
                  _HealthHero(state: state),
                  const SizedBox(height: 14),
                  _TodayGoalCard(
                    onStart: () => ref
                        .read(selectedTabProvider.notifier)
                        .select(AppTab.write),
                  ),
                  AppSectionHeader(
                    title: 'Active challenges',
                    actionLabel: 'See all',
                    onAction: () => ref
                        .read(selectedTabProvider.notifier)
                        .select(AppTab.progress),
                  ),
                  SizedBox(
                    height: 156,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.challenges.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) => _ChallengeMini(
                        challenge: state.challenges[index],
                        index: index,
                      ),
                    ),
                  ),
                  AppSectionHeader(
                    title: 'Last essay',
                    actionLabel: 'Open',
                    onAction: () => ref
                        .read(selectedTabProvider.notifier)
                        .select(AppTab.write),
                  ),
                  _LastEssayCard(
                    essay: state.lastEssay,
                    examType: user.examType,
                  ),
                  const AppSectionHeader(title: 'This month'),
                  Row(
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
                          value: '+${(state.averageScore - 55).clamp(0, 99)}',
                          label: 'Health pts',
                          accent: context.colors.good,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppMetricTile(
                          value: '${user.currentStreak}',
                          label: 'Day streak',
                          accent: context.colors.warn,
                        ),
                      ),
                    ],
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

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.state});

  final WritingCoachState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = state.user!;
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.ink3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 7),
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
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppPill(
              icon: Icons.bolt_rounded,
              label: '${user.credits}',
              backgroundColor: colors.warnTint,
              foregroundColor: colors.warn,
            ),
            const SizedBox(width: 7),
            _ThemeCycleButton(themeMode: state.themeMode),
            const SizedBox(width: 7),
            _Avatar(initials: user.initials),
          ],
        ),
      ],
    );
  }
}

class _ThemeCycleButton extends ConsumerWidget {
  const _ThemeCycleButton({required this.themeMode});

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
            color: _themeIconColor(colors, themeMode),
            size: 22,
          ),
        ),
      ),
    );
  }

  Color _themeIconColor(WritingCoachColors colors, WritingCoachThemeMode mode) {
    return switch (mode) {
      WritingCoachThemeMode.dark => colors.primaryTintStrong,
      WritingCoachThemeMode.day => colors.warn,
      WritingCoachThemeMode.accessible => colors.primary,
    };
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryTintStrong, colors.primary],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: colors.primaryInk,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _HealthHero extends StatelessWidget {
  const _HealthHero({required this.state});

  final WritingCoachState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = state.user!;
    final score = user.writingHealthScore.clamp(0, 100);

    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Writing Health Score',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.ink4,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
              AppPill(
                icon: Icons.trending_up_rounded,
                label: '+${(score - 55).clamp(0, 99)} this week',
                backgroundColor: colors.goodTint,
                foregroundColor: colors.good,
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$score',
                          style: AppTypography.number(
                            colors: colors,
                            size: colors.isHighContrast ? 60 : 66,
                            weight: FontWeight.w800,
                            height: 0.88,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 6),
                          child: Text(
                            '/100',
                            style: AppTypography.number(
                              colors: colors,
                              size: 18,
                              color: colors.ink4,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        AppPill(
                          label:
                              '${user.examType.scoreLabel} ${_estimatedScore(user.examType, score)} now',
                        ),
                        AppPill(label: '${user.examType.goalLabel} goal'),
                      ],
                    ),
                  ],
                ),
              ),
              _MiniSparkline(
                color: colors.primaryTintStrong,
                backgroundColor: colors.background,
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppProgressBar(value: score / 100, color: colors.good, height: 8),
        ],
      ),
    );
  }

  String _estimatedScore(ExamType examType, int score) {
    return switch (examType) {
      ExamType.ielts => (4 + (score / 100) * 5).toStringAsFixed(1),
      ExamType.toefl => '${(18 + (score / 100) * 12).round()}',
    };
  }
}

class _MiniSparkline extends StatelessWidget {
  const _MiniSparkline({required this.color, required this.backgroundColor});

  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 60,
      child: CustomPaint(painter: _SparklinePainter(color, backgroundColor)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.color, this.backgroundColor);

  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset(0, size.height * 0.74),
      Offset(size.width * 0.18, size.height * 0.68),
      Offset(size.width * 0.32, size.height * 0.62),
      Offset(size.width * 0.48, size.height * 0.46),
      Offset(size.width * 0.64, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.24),
      Offset(size.width, size.height * 0.14),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.26), color.withValues(alpha: 0)],
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
    canvas.drawCircle(points.last, 4.5, Paint()..color = backgroundColor);
    canvas.drawCircle(
      points.last,
      4.5,
      Paint()
        ..color = color
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _TodayGoalCard extends StatelessWidget {
  const _TodayGoalCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GradientCard(
      accent: colors.primary,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Today\'s Goal',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.ink3,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
              AppPill(
                icon: Icons.timer_outlined,
                label: '40 min',
                backgroundColor: colors.primaryTint,
                foregroundColor: colors.primaryTintStrong,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Write 1 Task 2 essay',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
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
  const _ChallengeMini({required this.challenge, required this.index});

  final ChallengeProgress challenge;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = switch (index % 3) {
      0 => colors.warn,
      1 => colors.good,
      _ => colors.violet,
    };
    final tint = switch (index % 3) {
      0 => colors.warnTint,
      1 => colors.goodTint,
      _ => colors.violetTint,
    };
    final icon = switch (index % 3) {
      0 => Icons.local_fire_department_rounded,
      1 => Icons.track_changes_rounded,
      _ => Icons.menu_book_rounded,
    };

    return SizedBox(
      width: 176,
      child: DesignCard(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(
                  icon: icon,
                  backgroundColor: tint,
                  foregroundColor: accent,
                  size: 36,
                ),
                const Spacer(),
                Text(
                  '${challenge.progress}/${challenge.total}',
                  style: AppTypography.number(
                    colors: colors,
                    size: 13,
                    color: accent,
                    weight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              challenge.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            AppProgressBar(value: challenge.ratio, height: 6, color: accent),
            const SizedBox(height: 8),
            Text(
              '+${challenge.rewardCredits} credit reward',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.ink3,
                fontWeight: FontWeight.w800,
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
            IconBadge(icon: Icons.note_add_outlined),
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
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.line),
            ),
            child: Center(
              child: Text(
                latestEssay.rawScore,
                style: AppTypography.number(
                  colors: colors,
                  size: 16,
                  color: colors.primaryTintStrong,
                  weight: FontWeight.w800,
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
                  latestEssay.prompt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${examType.label} Task 2 - ${latestEssay.wordCount} words - ${latestEssay.normalizedScore}/100',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.ink3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: colors.ink4),
        ],
      ),
    );
  }
}
