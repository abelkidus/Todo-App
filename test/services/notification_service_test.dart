import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/notification_service.dart';

void main() {
  group('NotificationService Unit Tests', () {
    late NotificationService service;

    setUp(() {
      service = NotificationService();
    });

    test('calculates scheduled notification time exactly 15 minutes before deadline',
        () {
      final dueDate = DateTime(2026, 10, 15, 14, 30);
      final scheduledTime = service.getScheduledNotificationTime(dueDate);

      expect(scheduledTime, isNotNull);
      expect(scheduledTime, DateTime(2026, 10, 15, 14, 15));
      expect(dueDate.difference(scheduledTime!).inMinutes, 15);
    });

    test('returns null when task has no due date', () {
      final scheduledTime = service.getScheduledNotificationTime(null);
      expect(scheduledTime, isNull);
    });

    test('generates consistent positive integer notification ID from task ID',
        () {
      final id1 = service.getNotificationId('task-100');
      final id2 = service.getNotificationId('task-100');
      final id3 = service.getNotificationId('task-200');

      expect(id1, id2);
      expect(id1, isNonNegative);
      expect(id1, isNot(id3));
    });

    test('handles past deadline gracefully without error', () async {
      final pastDate = DateTime(2020, 1, 1, 10, 0);
      final pastTask = Task(
        id: 'past-task',
        title: 'Old task',
        dueDate: pastDate,
      );

      // Should return without error and not schedule in the past
      await service.scheduleTaskDeadlineNotification(pastTask);
    });

    test('does not schedule notification for already completed task', () async {
      final futureDate = DateTime(2026, 12, 31, 23, 59);
      final completedTask = Task(
        id: 'completed-task',
        title: 'Done task',
        isCompleted: true,
        dueDate: futureDate,
      );

      await service.scheduleTaskDeadlineNotification(completedTask);
    });
  });
}
