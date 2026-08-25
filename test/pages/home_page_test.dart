import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/database.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/pages/home_page.dart';

class FakeToDoDataBase implements ToDoDataBase {
  @override
  List<Task> toDoList = [];

  @override
  void createInitialData() {
    toDoList = [
      const Task(
        id: '1',
        title: 'Watch tutorial',
        isCompleted: false,
        priority: Priority.medium,
        category: 'Learning',
      ),
      const Task(
        id: '2',
        title: 'Exercise',
        isCompleted: false,
        priority: Priority.low,
        category: 'Fitness',
      ),
    ];
  }

  @override
  void loadData() {
    createInitialData();
  }

  @override
  void updateDataBase() {
    // In-memory update for fast, deterministic widget testing
  }
}

void main() {
  testWidgets(
      'wraps task cards in Dismissible widgets with red background and trash icon',
      (WidgetTester tester) async {
    final db = FakeToDoDataBase();

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(database: db),
      ),
    );
    await tester.pump();

    // Verify initial tasks exist
    expect(find.text('Watch tutorial'), findsOneWidget);
    expect(find.text('Exercise'), findsOneWidget);

    // Verify Dismissible widgets are rendered for tasks
    final dismissibles = find.byType(Dismissible);
    expect(dismissibles, findsNWidgets(2));

    // Verify background and secondaryBackground configurations
    final firstDismissible = tester.widget<Dismissible>(dismissibles.first);
    expect(firstDismissible.background, isA<Container>());
    expect(firstDismissible.secondaryBackground, isA<Container>());

    final bg = firstDismissible.background as Container;
    final bgDecoration = bg.decoration as BoxDecoration;
    expect(bgDecoration.color, Colors.red);
    expect(bg.child, isA<Icon>());
    expect((bg.child as Icon).icon, Icons.delete);
    expect((bg.child as Icon).color, Colors.white);

    final secBg = firstDismissible.secondaryBackground as Container;
    final secBgDecoration = secBg.decoration as BoxDecoration;
    expect(secBgDecoration.color, Colors.red);
    expect(secBg.child, isA<Icon>());
    expect((secBg.child as Icon).icon, Icons.delete);
    expect((secBg.child as Icon).color, Colors.white);
  });

  testWidgets(
      'swipe-to-delete dismisses task, shows SnackBar with Undo, and restores upon Undo',
      (WidgetTester tester) async {
    final db = FakeToDoDataBase();

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(database: db),
      ),
    );
    await tester.pump();

    expect(find.text('Watch tutorial'), findsOneWidget);
    expect(find.text('Exercise'), findsOneWidget);

    // Fling the first task from right to left to dismiss
    await tester.fling(
      find.text('Watch tutorial'),
      const Offset(-600, 0),
      1000,
    );
    await tester.pumpAndSettle();

    // "Watch tutorial" should now be dismissed
    expect(find.text('Watch tutorial'), findsNothing);
    expect(find.text('Exercise'), findsOneWidget);
    expect(db.toDoList.length, 1);

    // SnackBar should be displayed with "Undo" button
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Task "Watch tutorial" deleted'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    // Tap Undo
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    // "Watch tutorial" should be restored at its original position
    expect(find.text('Watch tutorial'), findsOneWidget);
    expect(find.text('Exercise'), findsOneWidget);
    expect(db.toDoList.length, 2);
  });
}
