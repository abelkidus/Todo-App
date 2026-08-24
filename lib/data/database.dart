import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/models/task.dart';

class ToDoDataBase {
  List<Task> toDoList = [];

  late final Box _myBox;

  ToDoDataBase([Box? box]) {
    _myBox = box ?? Hive.box('mybox');
  }

  // run this method if this is the first time ever opening this app
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

  void loadData() {
    final savedData = _myBox.get('TODOLIST');

    if (savedData == null) {
      createInitialData();
      updateDataBase();
    } else {
      toDoList = (savedData as List).map<Task>((item) {
        if (item is Task) return item;
        if (item is Map) {
          return Task.fromMap(Map<String, dynamic>.from(item));
        }
        if (item is String) {
          return Task.fromJson(item);
        }
        if (item is List) {
          // Backward compatibility for legacy list format: [title, isCompleted, priority?, category?, dueDate?]
          final title = item.isNotEmpty ? item[0]?.toString() ?? '' : '';
          final completed = item.length > 1 ? item[1] == true : false;
          Priority priority = Priority.medium;
          if (item.length > 2 && item[2] != null) {
            if (item[2] is Priority) {
              priority = item[2] as Priority;
            } else if (item[2] is String) {
              priority = Priority.fromString(item[2] as String);
            }
          }
          String category = 'General';
          if (item.length > 3 && item[3] != null) {
            category = item[3].toString();
          }
          DateTime? dueDate;
          if (item.length > 4 && item[4] != null) {
            if (item[4] is DateTime) {
              dueDate = item[4] as DateTime;
            } else if (item[4] is String) {
              dueDate = DateTime.tryParse(item[4] as String);
            }
          }
          return Task(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            isCompleted: completed,
            priority: priority,
            category: category,
            dueDate: dueDate,
          );
        }
        return Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: item.toString(),
        );
      }).toList();
    }
  }

  void updateDataBase() {
    _myBox.put(
      'TODOLIST',
      toDoList.map((task) => task.toMap()).toList(),
    );
  }
}