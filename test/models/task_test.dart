import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('instantiates with all fields correctly', () {
      final now = DateTime(2026, 8, 22, 10, 0);
      final task = Task(
        id: 'task-1',
        title: 'Complete assignment',
        isCompleted: true,
        dueDate: now,
        priority: Priority.high,
        category: 'School',
      );

      expect(task.id, 'task-1');
      expect(task.title, 'Complete assignment');
      expect(task.isCompleted, isTrue);
      expect(task.dueDate, now);
      expect(task.priority, Priority.high);
      expect(task.category, 'School');
    });

    test('default values are set properly', () {
      final task = Task(
        id: 'task-2',
        title: 'Buy groceries',
      );

      expect(task.id, 'task-2');
      expect(task.title, 'Buy groceries');
      expect(task.isCompleted, isFalse);
      expect(task.dueDate, isNull);
      expect(task.priority, Priority.medium);
      expect(task.category, 'General');
    });

    test('toMap converts task to map accurately', () {
      final now = DateTime(2026, 8, 22, 12, 30);
      final task = Task(
        id: '101',
        title: 'Read Dart docs',
        isCompleted: false,
        dueDate: now,
        priority: Priority.low,
        category: 'Learning',
      );

      final map = task.toMap();

      expect(map, {
        'id': '101',
        'title': 'Read Dart docs',
        'isCompleted': false,
        'dueDate': now.toIso8601String(),
        'priority': 'low',
        'category': 'Learning',
      });
    });

    test('fromMap restores task from map accurately', () {
      final now = DateTime(2026, 8, 22, 12, 30);
      final map = {
        'id': '101',
        'title': 'Read Dart docs',
        'isCompleted': true,
        'dueDate': now.toIso8601String(),
        'priority': 'high',
        'category': 'Learning',
      };

      final task = Task.fromMap(map);

      expect(task.id, '101');
      expect(task.title, 'Read Dart docs');
      expect(task.isCompleted, isTrue);
      expect(task.dueDate, now);
      expect(task.priority, Priority.high);
      expect(task.category, 'Learning');
    });

    test('fromMap handles missing/null values and case variations', () {
      final map = {
        'id': '102',
        'title': 'Quick note',
        'priority': 'HIGH',
      };

      final task = Task.fromMap(map);

      expect(task.id, '102');
      expect(task.title, 'Quick note');
      expect(task.isCompleted, isFalse);
      expect(task.dueDate, isNull);
      expect(task.priority, Priority.high);
      expect(task.category, 'General');
    });

    test('copyWith updates specified fields only', () {
      final originalDate = DateTime(2026, 8, 20);
      final newDate = DateTime(2026, 8, 25);

      final task = Task(
        id: 'task-3',
        title: 'Original Title',
        isCompleted: false,
        dueDate: originalDate,
        priority: Priority.low,
        category: 'Work',
      );

      final updatedTask = task.copyWith(
        title: 'Updated Title',
        isCompleted: true,
        dueDate: newDate,
        priority: Priority.high,
        category: 'Personal',
      );

      expect(updatedTask.id, 'task-3');
      expect(updatedTask.title, 'Updated Title');
      expect(updatedTask.isCompleted, isTrue);
      expect(updatedTask.dueDate, newDate);
      expect(updatedTask.priority, Priority.high);
      expect(updatedTask.category, 'Personal');

      // Original task remains unchanged
      expect(task.title, 'Original Title');
      expect(task.isCompleted, isFalse);
      expect(task.priority, Priority.low);
    });

    test('equality and hashCode work as expected', () {
      final date = DateTime(2026, 8, 22);
      final task1 = Task(
        id: '1',
        title: 'Task A',
        isCompleted: false,
        dueDate: date,
        priority: Priority.medium,
        category: 'General',
      );

      final task2 = Task(
        id: '1',
        title: 'Task A',
        isCompleted: false,
        dueDate: date,
        priority: Priority.medium,
        category: 'General',
      );

      expect(task1, equals(task2));
      expect(task1.hashCode, equals(task2.hashCode));
    });

    test('JSON serialization roundtrip', () {
      final task = Task(
        id: '1',
        title: 'Json test',
        isCompleted: true,
        dueDate: DateTime(2026, 9, 1),
        priority: Priority.low,
        category: 'Testing',
      );

      final jsonStr = task.toJson();
      final fromJsonTask = Task.fromJson(jsonStr);

      expect(fromJsonTask, equals(task));
    });
  });
}
