import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:ai_coach/src/core/design/app_spacing.dart';
import 'package:flutter/material.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({
    required this.title,
    required this.children,
    this.subtitle,
    this.trailing,
    this.screenKey,
    super.key,
  });

  final Key? screenKey;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      key: screenKey,
      decoration: BoxDecoration(
        color: colors.background,
        gradient: colors.isDark && !colors.isHighContrast
            ? RadialGradient(
                center: const Alignment(0, -1.18),
                radius: 0.9,
                colors: [
                  colors.primary.withValues(alpha: 0.22),
                  colors.background,
                ],
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  10,
                  AppSpacing.screenX,
                  18,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colors.ink3,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 12),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                0,
                AppSpacing.screenX,
                AppSpacing.bottomNavHeight + 28,
              ),
              sliver: SliverList.separated(
                itemCount: children.length,
                itemBuilder: (context, index) => children[index],
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.cardGap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DesignCard extends StatelessWidget {
  const DesignCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: colors.line,
          width: colors.isHighContrast ? 2 : 1,
        ),
        boxShadow: colors.isHighContrast
            ? const []
            : [
                BoxShadow(
                  color: colors.isDark
                      ? Colors.black.withValues(alpha: 0.24)
                      : const Color(0x221D2A48),
                  blurRadius: 38,
                  spreadRadius: -28,
                  offset: const Offset(0, 18),
                ),
              ],
      ),
      child: child,
    );
  }
}

class GradientCard extends StatelessWidget {
  const GradientCard({
    required this.child,
    this.padding = const EdgeInsets.all(21),
    this.accent,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = accent ?? colors.primary;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colors.isHighContrast
              ? colors.line
              : tint.withValues(alpha: colors.isDark ? 0.22 : 0.16),
          width: colors.isHighContrast ? 2 : 1,
        ),
        gradient: colors.isHighContrast
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors.isDark
                    ? [
                        tint.withValues(alpha: 0.22),
                        colors.card,
                        colors.background,
                      ]
                    : [tint.withValues(alpha: 0.1), colors.card, colors.sunken],
              ),
        color: colors.isHighContrast ? colors.card : null,
        boxShadow: colors.isHighContrast
            ? const []
            : [
                BoxShadow(
                  color: tint.withValues(alpha: colors.isDark ? 0.26 : 0.18),
                  blurRadius: 54,
                  spreadRadius: -36,
                  offset: const Offset(0, 24),
                ),
              ],
      ),
      child: child,
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppPill extends StatelessWidget {
  const AppPill({
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = foregroundColor ?? colors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.chipX,
        vertical: AppSpacing.chipY,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.primaryTint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: (foreground).withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: foreground, size: 15),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    required this.value,
    this.color,
    this.height = 8,
    super.key,
  });

  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: colors.isHighContrast ? height + 2 : height,
      decoration: BoxDecoration(
        color: colors.isDark
            ? Colors.white.withValues(
                alpha: colors.isHighContrast ? 0.18 : 0.07,
              )
            : colors.sunken,
        borderRadius: BorderRadius.circular(height),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0, 1).toDouble(),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? colors.primary,
            borderRadius: BorderRadius.circular(height),
          ),
        ),
      ),
    );
  }
}

class AppMetricTile extends StatelessWidget {
  const AppMetricTile({
    required this.value,
    required this.label,
    this.accent,
    super.key,
  });

  final String value;
  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppSpacing.mediumRadius,
        border: Border.all(color: colors.line),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: accent ?? colors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.ink2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge({
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 44,
    super.key,
  });

  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.primaryTint,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: colors.line),
      ),
      child: Icon(
        icon,
        color: foregroundColor ?? colors.primary,
        size: size * 0.48,
      ),
    );
  }
}

class ScoreRing extends StatelessWidget {
  const ScoreRing({
    required this.value,
    required this.child,
    this.size = 132,
    this.strokeWidth = 11,
    this.color,
    super.key,
  });

  final int value;
  final Widget child;
  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = value.clamp(0, 100) / 100;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              color: color ?? colors.primary,
              backgroundColor: colors.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : colors.sunken,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class FeaturePlaceholderCard extends StatelessWidget {
  const FeaturePlaceholderCard({
    required this.icon,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DesignCard(
      child: SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconTile(icon: icon),
              const SizedBox(height: 14),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: colors.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 25, color: colors.primary),
    );
  }
}
