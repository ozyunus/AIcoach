import 'package:ai_coach/src/features/shell/application/app_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTabProvider = NotifierProvider<SelectedTabController, AppTab>(
  SelectedTabController.new,
);

class SelectedTabController extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.home;

  void select(AppTab tab) {
    state = tab;
  }
}
