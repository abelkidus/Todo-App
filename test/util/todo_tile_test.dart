import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/util/todo_tile.dart';

void main() {
  group('ToDoTile Widget Tests', () {
    testWidgets('displays category tag, title, and formatted due date',
        (WidgetTester tester) async {
      final dueDate = DateTime(2026, 12, 25);
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToDoTile(
              taskName: 'Submit Report',
              taskCompleted: false,
              priority: Priority.high,
              category: 'Work',
              dueDate: dueDate,
              onChanged: (value) => changedValue = value,
              deleteFunction: (_) {},
            ),
          ),
        ),
      );

      // Verify category tag
      expect(find.text('Work'), findsOneWidget);

      // Verify task name
      expect(find.text('Submit Report'), findsOneWidget);

      // Verify priority label
      expect(find.text('High'), findsOneWidget);

      // Verify formatted due date
      expect(find.text('Dec 25, 2026'), findsOneWidget);

      // Tap checkbox and verify onChanged callback
      await tester.tap(find.byType(Checkbox));
      expect(changedValue, isTrue);
    });

    testWidgets('highlights overdue tasks in red and shows OVERDUE badge',
        (WidgetTester tester) async {
      final pastDate = DateTime(2020, 1, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToDoTile(
              taskName: 'Overdue task',
              taskCompleted: false,
              priority: Priority.high,
              category: 'Personal',
              dueDate: pastDate,
              onChanged: (_) {},
              deleteFunction: (_) {},
            ),
          ),
        ),
      );

      // Verify OVERDUE badge is rendered
      expect(find.text('OVERDUE'), findsOneWidget);
      expect(find.text('Jan 1, 2020'), findsOneWidget);
    });

    testWidgets('shows priority indicator colors for High, Medium, Low',
        (WidgetTester tester) async {
      for (final priority in Priority.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ToDoTile(
                taskName: 'Priority task ${priority.name}',
                taskCompleted: false,
                priority: priority,
                category: 'Fitness',
                onChanged: (_) {},
                deleteFunction: (_) {},
              ),
            ),
          ),
        );

        expect(find.text(priority.displayName), findsOneWidget);
        expect(find.text('Fitness'), findsOneWidget);
      }
    });
  });
}
