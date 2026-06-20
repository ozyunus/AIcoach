import 'package:ai_coach/src/app/writing_coach_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('signs in, opens tabs, and analyzes a mock essay', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: WritingCoachApp()));

    final previewSignIn = find.byKey(const ValueKey('sign-in-preview'));
    if (previewSignIn.evaluate().isNotEmpty) {
      await tester.tap(previewSignIn);
      await tester.pumpAndSettle();
    }

    expect(find.byKey(const ValueKey('screen-home')), findsOneWidget);
    expect(find.byKey(const ValueKey('tab-home')), findsOneWidget);
    expect(find.byKey(const ValueKey('tab-progress')), findsOneWidget);
    expect(find.byKey(const ValueKey('tab-write')), findsOneWidget);
    expect(find.byKey(const ValueKey('tab-coach')), findsOneWidget);
    expect(find.byKey(const ValueKey('tab-profile')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tab-progress')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('screen-progress')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tab-write')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('screen-write')), findsOneWidget);

    await tester.tap(find.text('Sample'));
    await tester.pumpAndSettle();

    final writeScrollable = find
        .descendant(
          of: find.byKey(const ValueKey('screen-write')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('submit-essay')),
      260,
      scrollable: writeScrollable,
    );
    await tester.drag(writeScrollable, const Offset(0, -320));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('submit-essay')));
    await tester.pumpAndSettle();

    expect(find.text('Skill breakdown'), findsOneWidget);
    expect(find.text('Corrections'), findsOneWidget);
  });
}
