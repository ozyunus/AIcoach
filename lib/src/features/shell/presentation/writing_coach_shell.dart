import 'dart:ui';

import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:ai_coach/src/core/design/app_spacing.dart';
import 'package:ai_coach/src/features/coach/presentation/coach_screen.dart';
import 'package:ai_coach/src/features/home/presentation/home_screen.dart';
import 'package:ai_coach/src/features/profile/presentation/profile_screen.dart';
import 'package:ai_coach/src/features/progress/presentation/progress_screen.dart';
import 'package:ai_coach/src/features/shell/application/app_tab.dart';
import 'package:ai_coach/src/features/shell/application/selected_tab_controller.dart';
import 'package:ai_coach/src/features/write/presentation/write_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WritingCoachShell extends ConsumerWidget {
  const WritingCoachShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(selectedTabProvider);
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colors.card,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: colors.background,
        body: IndexedStack(
          index: activeTab.index,
          children: const [
            HomeScreen(),
            ProgressScreen(),
            WriteScreen(),
            CoachScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: _BottomTabBar(activeTab: activeTab),
      ),
    );
  }
}

class _BottomTabBar extends StatelessWidget {
  const _BottomTabBar({required this.activeTab});

  final AppTab activeTab;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: AppSpacing.bottomNavHeight,
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 26),
          decoration: BoxDecoration(
            color: colors.card.withValues(alpha: 0.82),
            border: Border(top: BorderSide(color: colors.line2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TabButton(tab: AppTab.home, activeTab: activeTab),
              _TabButton(tab: AppTab.progress, activeTab: activeTab),
              _TabButton(tab: AppTab.write, activeTab: activeTab, center: true),
              _TabButton(tab: AppTab.coach, activeTab: activeTab),
              _TabButton(tab: AppTab.profile, activeTab: activeTab),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends ConsumerWidget {
  const _TabButton({
    required this.tab,
    required this.activeTab,
    this.center = false,
  });

  final AppTab tab;
  final AppTab activeTab;
  final bool center;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final selected = tab == activeTab;
    final iconColor = selected || center ? colors.primary : colors.ink4;
    final labelColor = selected ? colors.primary : colors.ink4;

    return SizedBox(
      width: 64,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('tab-${tab.name}'),
          borderRadius: BorderRadius.circular(18),
          onTap: () => ref.read(selectedTabProvider.notifier).select(tab),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (center)
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Container(
                      width: 50,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.34),
                            blurRadius: 22,
                            spreadRadius: -8,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(tab.icon, color: colors.primaryInk, size: 22),
                    ),
                  )
                else
                  Icon(tab.icon, color: iconColor, size: 23),
                const SizedBox(height: 4),
                Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: labelColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on AppTab {
  String get label => switch (this) {
    AppTab.home => 'Home',
    AppTab.progress => 'Progress',
    AppTab.write => 'Write',
    AppTab.coach => 'Coach',
    AppTab.profile => 'Profile',
  };

  IconData get icon => switch (this) {
    AppTab.home => Icons.home_outlined,
    AppTab.progress => Icons.bar_chart_rounded,
    AppTab.write => Icons.edit_rounded,
    AppTab.coach => Icons.schedule_rounded,
    AppTab.profile => Icons.person_outline_rounded,
  };
}
