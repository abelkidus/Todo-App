import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/database.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/pages/home_page.dart';
import 'package:todo_app/util/todo_tile.dart';

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
        dueDate: null,
      ),
      Task(
        id: '2',
        title: 'Exercise',
        isCompleted: true,
        priority: Priority.low,
        category: 'Fitness',
        dueDate: DateTime(2026, 12, 31),
      ),
      Task(
        id: '3',
        title: 'Submit taxes',
        isCompleted: false,
        priority: Priority.high,
        category: 'Personal',
        dueDate: DateTime(2026, 9, 1),
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
    expect(find.text('Submit taxes'), findsOneWidget);

    // Verify Dismissible widgets are rendered for tasks
    final dismissibles = find.byType(Dismissible);
    expect(dismissibles, findsNWidgets(3));

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

    // Fling the first task to dismiss
    await tester.fling(
      find.text('Watch tutorial'),
      const Offset(-600, 0),
      1000,
    );
    await tester.pumpAndSettle();

    // "Watch tutorial" should now be dismissed
    expect(find.text('Watch tutorial'), findsNothing);
    expect(db.toDoList.length, 2);

    // SnackBar should be displayed with "Undo" button
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Task "Watch tutorial" deleted'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    // Tap Undo
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    // "Watch tutorial" should be restored at its original position
    expect(find.text('Watch tutorial'), findsOneWidget);
    expect(db.toDoList.length, 3);
  });

  testWidgets('filters tasks by completion status (All, Active, Done)',
      (WidgetTester tester) async {
    final db = FakeToDoDataBase();

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(database: db),
      ),
    );
    await tester.pump();

    // All: 3 tasks
    expect(find.text('Watch tutorial'), findsOneWidget);
    expect(find.text('Exercise'), findsOneWidget);
    expect(find.text('Submit taxes'), findsOneWidget);

    // Tap 'Active' filter chip
    await tester.tap(find.widgetWithText(ChoiceChip, 'Active'));
    await tester.pumpAndSettle();

    // Active tasks only: Watch tutorial & Submit taxes (Exercise is Done)
    expect(find.text('Watch tutorial'), findsOneWidget);
    expect(find.text('Submit taxes'), findsOneWidget);
    expect(find.text('Exercise'), findsNothing);

    // Tap 'Done' filter chip
    await tester.tap(find.widgetWithText(ChoiceChip, 'Done'));
    await tester.pumpAndSettle();

    // Done tasks only: Exercise
    expect(find.text('Exercise'), findsOneWidget);
    expect(find.text('Watch tutorial'), findsNothing);
    expect(find.text('Submit taxes'), findsNothing);

    // Tap 'All' filter chip (first ChoiceChip with label 'All')
    await tester.tap(find.widgetWithText(ChoiceChip, 'All').first);
    await tester.pumpAndSettle();

    expect(find.text('Watch tutorial'), findsOneWidget);
    expect(find.text('Exercise'), findsOneWidget);
    expect(find.text('Submit taxes'), findsOneWidget);
  });

  testWidgets('filters tasks by category chips', (WidgetTester tester) async {
    final db = FakeToDoDataBase();

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(database: db),
      ),
    );
    await tester.pump();

    // Scroll to and tap 'Fitness' chip
    final fitnessChip = find.widgetWithText(ChoiceChip, 'Fitness');
    await tester.ensureVisible(fitnessChip);
    await tester.tap(fitnessChip);
    await tester.pumpAndSettle();

    expect(find.text('Exercise'), findsOneWidget);
    expect(find.text('Watch tutorial'), findsNothing);
    expect(find.text('Submit taxes'), findsNothing);

    // Scroll to and tap 'Personal' chip
    final personalChip = find.widgetWithText(ChoiceChip, 'Personal');
    await tester.ensureVisible(personalChip);
    await tester.tap(personalChip);
    await tester.pumpAndSettle();

    expect(find.text('Submit taxes'), findsOneWidget);
    expect(find.text('Exercise'), findsNothing);
    expect(find.text('Watch tutorial'), findsNothing);
  });

  testWidgets('sorts tasks by priority and due date via popup menu',
      (WidgetTester tester) async {
    final db = FakeToDoDataBase();

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(database: db),
      ),
    );
    await tester.pump();

    // Open sort menu
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();

    // Tap 'Sort by Priority'
    await tester.tap(find.text('Sort by Priority'));
    await tester.pumpAndSettle();

    // Submit taxes is High, Watch tutorial is Medium, Exercise is Low
    final tilesPriority = tester
        .widgetList<ToDoTile>(find.byType(ToDoTile))
        .map((tile) => tile.taskName)
        .toList();
    expect(tilesPriority, ['Submit taxes', 'Watch tutorial', 'Exercise']);

    // Open sort menu again and sort by Due Date
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sort by Due Date'));
    await tester.pumpAndSettle();

    // Submit taxes (Sept 1) before Exercise (Dec 31) before Watch tutorial (null)
    final tilesDueDate = tester
        .widgetList<ToDoTile>(find.byType(ToDoTile))
        .map((tile) => tile.taskName)
        .toList();
    expect(tilesDueDate, ['Submit taxes', 'Exercise', 'Watch tutorial']);
  });
}
