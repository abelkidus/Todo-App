import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_app/models/task.dart' as model;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotificationService._internal([FlutterLocalNotificationsPlugin? plugin])
      : _notificationsPlugin = plugin ?? FlutterLocalNotificationsPlugin();

  // Test factory to inject custom plugin
  factory NotificationService.withPlugin(
          FlutterLocalNotificationsPlugin plugin) =>
      NotificationService._internal(plugin);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Todo App',
      appUserModelId: 'com.example.todo_app',
      guid: 'd9b7348e-2cfb-4a57-8d02-a1f9e2b19db1',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    try {
      await _notificationsPlugin.initialize(settings: initSettings);
      _initialized = true;
    } catch (_) {
      // Gracefully handle unit test environments or platforms where channels are absent
    }
  }

  int getNotificationId(String taskId) {
    return taskId.hashCode.abs() % 2147483647;
  }

  DateTime? getScheduledNotificationTime(DateTime? dueDate) {
    if (dueDate == null) return null;
    return dueDate.subtract(const Duration(minutes: 15));
  }

  Future<void> scheduleTaskDeadlineNotification(model.Task task) async {
    if (task.dueDate == null || task.isCompleted) return;

    final scheduledTime = getScheduledNotificationTime(task.dueDate);
    if (scheduledTime == null || scheduledTime.isBefore(DateTime.now())) {
      return;
    }

    final id = getNotificationId(task.id);
    final tzScheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'task_deadlines',
      'Task Deadlines',
      channelDescription: 'Notifications for upcoming task deadlines',
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'Upcoming Task Deadline',
        body: 'Your task "${task.title}" is due in 15 minutes!',
        scheduledDate: tzScheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // Gracefully handle missing platform channels in test isolates
    }
  }

  Future<void> cancelTaskNotification(String taskId) async {
    final id = getNotificationId(taskId);
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }
}
