import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/util/dialog_box.dart';

void main() {
  testWidgets('DialogBox displays all inputs, chips, segmented button, and date picker',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    String? savedTitle;
    String? savedCategory;
    Priority? savedPriority;
    DateTime? savedDueDate;
    bool cancelled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DialogBox(
            controller: controller,
            initialCategory: 'Work',
            initialPriority: Priority.medium,
            onSave: (String title, String category, Priority priority,
                DateTime? dueDate) {
              savedTitle = title;
              savedCategory = category;
              savedPriority = priority;
              savedDueDate = dueDate;
            },
            onCancel: () {
              cancelled = true;
            },
          ),
        ),
      ),
    );

    // Verify Title input
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Prepare presentation');

    // Verify ChoiceChips for categories
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Fitness'), findsOneWidget);
    expect(find.text('Study'), findsOneWidget);

    // Tap 'Study' chip
    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();

    // Verify SegmentedButton for priority
    expect(find.text('Low'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);

    // Tap 'High' priority
    await tester.tap(find.text('High'));
    await tester.pumpAndSettle();

    // Verify Deadline button
    expect(find.text('Set Deadline'), findsOneWidget);

    // Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedTitle, 'Prepare presentation');
    expect(savedCategory, 'Study');
    expect(savedPriority, Priority.high);
    expect(savedDueDate, isNull);

    // Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(cancelled, isTrue);
  });
}
