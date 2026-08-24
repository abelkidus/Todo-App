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
      final task = db.toDoList[index];
      db.toDoList[index] = task.copyWith(
        isCompleted: value ?? !task.isCompleted,
      );
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
    final taskTitle =
        (title != null && title.isNotEmpty) ? title : _controller.text;
    if (taskTitle.trim().isNotEmpty) {
      setState(() {
        db.toDoList.add(
          Task(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: taskTitle.trim(),
            isCompleted: false,
            priority: priority ?? Priority.medium,
            category: category ?? 'General',
            dueDate: dueDate,
          ),
        );
        _controller.clear();
        db.updateDataBase();
      });
    }
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
          final task = db.toDoList[index];

          return ToDoTile.fromTask(
            task: task,
            onChanged: (value) => checkBoxChanged(value, index),
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
    );
  }
}