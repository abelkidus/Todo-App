import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/data/database.dart';
import 'package:todo_app/models/task.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('todo_hive_test_');
    Hive.init(tempDir.path);
    await Hive.openBox('mybox');
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ToDoDataBase Persistence Tests', () {
    test('creates and persists initial default tasks when storage is empty', () {
      final db = ToDoDataBase();
      db.loadData();

      expect(db.toDoList.length, 2);
      expect(db.toDoList[0].title, 'Watch tutorial');
      expect(db.toDoList[0].isCompleted, isFalse);
      expect(db.toDoList[0].category, 'Learning');
      expect(db.toDoList[1].title, 'Exercise');
      expect(db.toDoList[1].isCompleted, isFalse);
      expect(db.toDoList[1].category, 'Fitness');

      // Verify that data was serialized to Hive box
      final savedData = Hive.box('mybox').get('TODOLIST') as List;
      expect(savedData.length, 2);
      expect(savedData[0]['title'], 'Watch tutorial');
      expect(savedData[0]['isCompleted'], false);
      expect(savedData[1]['title'], 'Exercise');
      expect(savedData[1]['isCompleted'], false);
    });

    test('serializes and persists new tasks to Hive and reloads properly', () {
      final db = ToDoDataBase();
      db.loadData();

      final dueDate = DateTime(2026, 11, 15, 14, 0);
      final newTask = Task(
        id: 'task-100',
        title: 'Learn Hive Storage',
        isCompleted: false,
        priority: Priority.high,
        category: 'Study',
        dueDate: dueDate,
      );

      db.toDoList.add(newTask);
      db.updateDataBase();

      // Create a fresh database instance to verify reloading from Hive
      final newDbInstance = ToDoDataBase();
      newDbInstance.loadData();

      expect(newDbInstance.toDoList.length, 3);
      final loadedTask = newDbInstance.toDoList.last;
      expect(loadedTask.id, 'task-100');
      expect(loadedTask.title, 'Learn Hive Storage');
      expect(loadedTask.isCompleted, isFalse);
      expect(loadedTask.priority, Priority.high);
      expect(loadedTask.category, 'Study');
      expect(loadedTask.dueDate, dueDate);
    });

    test('persists task updates (e.g. completion toggle)', () {
      final db = ToDoDataBase();
      db.loadData();

      // Toggle first task completion
      db.toDoList[0] = db.toDoList[0].copyWith(isCompleted: true);
      db.updateDataBase();

      // Reload in fresh instance
      final freshDb = ToDoDataBase();
      freshDb.loadData();

      expect(freshDb.toDoList[0].isCompleted, isTrue);
    });

    test('persists task deletions', () {
      final db = ToDoDataBase();
      db.loadData();
      expect(db.toDoList.length, 2);

      db.toDoList.removeAt(0);
      db.updateDataBase();

      // Reload in fresh instance
      final freshDb = ToDoDataBase();
      freshDb.loadData();

      expect(freshDb.toDoList.length, 1);
      expect(freshDb.toDoList[0].title, 'Exercise');
    });

    test('loads legacy list-formatted data seamlessly', () {
      final box = Hive.box('mybox');
      box.put('TODOLIST', [
        ['Legacy Task 1', true, 'high', 'Work'],
        ['Legacy Task 2', false],
      ]);

      final db = ToDoDataBase();
      db.loadData();

      expect(db.toDoList.length, 2);
      expect(db.toDoList[0].title, 'Legacy Task 1');
      expect(db.toDoList[0].isCompleted, isTrue);
      expect(db.toDoList[0].priority, Priority.high);
      expect(db.toDoList[0].category, 'Work');

      expect(db.toDoList[1].title, 'Legacy Task 2');
      expect(db.toDoList[1].isCompleted, isFalse);
    });
  });
}
