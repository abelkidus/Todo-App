import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/util/dashboard_banner.dart';

void main() {
  group('DashboardBanner Widget Tests', () {
    testWidgets('renders zero progress when total tasks is zero',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardBanner(
              completedCount: 0,
              totalCount: 0,
            ),
          ),
        ),
      );

      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('0 of 0 completed (0%)'), findsOneWidget);

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, 0.0);
    });

    testWidgets('renders partial completion stats and correct progress ratio',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardBanner(
              completedCount: 3,
              totalCount: 5,
            ),
          ),
        ),
      );

      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('3 of 5 completed (60%)'), findsOneWidget);

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, closeTo(0.6, 0.001));
    });

    testWidgets('renders 100% completion stats when all tasks are complete',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardBanner(
              completedCount: 4,
              totalCount: 4,
            ),
          ),
        ),
      );

      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('4 of 4 completed (100%)'), findsOneWidget);

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, 1.0);
    });
  });
}
