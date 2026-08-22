import 'package:flutter/material.dart';
import 'package:todo_app/data/database.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/util/dialog_box.dart';
import 'package:todo_app/util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ToDoDataBase db = ToDoDataBase();

  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    db.loadData();
  }

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      final item = db.toDoList[index];
      if (item is Task) {
        db.toDoList[index] = item.copyWith(isCompleted: !(item.isCompleted));
      } else if (item is List) {
        item[1] = !item[1];
      }
      db.updateDataBase();
    });
  }

  // saving the new task
  void saveNewTask([
    String? title,
    String? category,
    Priority? priority,
    DateTime? dueDate,
  ]) {
    setState(() {
      final taskTitle =
          (title != null && title.isNotEmpty) ? title : _controller.text;
      db.toDoList.add([
        taskTitle,
        false,
        priority ?? Priority.medium,
        category ?? 'General',
        dueDate,
      ]);
      _controller.clear();
      db.updateDataBase();
    });
    Navigator.of(context).pop();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
      db.updateDataBase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Center(child: Text('TO DO')),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          final item = db.toDoList[index];
          String name = '';
          bool completed = false;
          Priority priority = Priority.medium;
          String category = 'General';
          DateTime? dueDate;

          if (item is Task) {
            name = item.title;
            completed = item.isCompleted;
            priority = item.priority;
            category = item.category;
            dueDate = item.dueDate;
          } else if (item is List) {
            name = item[0] as String;
            completed = item[1] as bool;
            if (item.length > 2 && item[2] is Priority) {
              priority = item[2] as Priority;
            }
            if (item.length > 3 && item[3] is String) {
              category = item[3] as String;
            }
            if (item.length > 4 && item[4] is DateTime?) {
              dueDate = item[4] as DateTime?;
            }
          }

          return ToDoTile(
            taskName: name,
            taskCompleted: completed,
            priority: priority,
            category: category,
            dueDate: dueDate,
            onChanged: (value) => checkBoxChanged(value, index),
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
    );
  }
}