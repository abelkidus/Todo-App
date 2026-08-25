import 'package:flutter/material.dart';
import 'package:todo_app/data/database.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/util/dialog_box.dart';
import 'package:todo_app/util/todo_tile.dart';

class HomePage extends StatefulWidget {
  final ToDoDataBase? database;
  const HomePage({super.key, this.database});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ToDoDataBase db;

  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = widget.database ?? ToDoDataBase();
    db.loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    final deletedTask = db.toDoList[index];
    final deletedIndex = index;

    setState(() {
      db.toDoList.removeAt(index);
      db.updateDataBase();
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${deletedTask.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              final insertIndex = deletedIndex.clamp(0, db.toDoList.length);
              db.toDoList.insert(insertIndex, deletedTask);
              db.updateDataBase();
            });
          },
        ),
      ),
    );
  }

  Widget _buildDismissBackground({
    required Alignment alignment,
    required EdgeInsets padding,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 16, right: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: padding,
      child: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
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

          return Dismissible(
            key: Key(task.id),
            background: _buildDismissBackground(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
            ),
            secondaryBackground: _buildDismissBackground(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
            ),
            onDismissed: (direction) => deleteTask(index),
            child: ToDoTile.fromTask(
              task: task,
              onChanged: (value) => checkBoxChanged(value, index),
              deleteFunction: (context) => deleteTask(index),
            ),
          );
        },
      ),
    );
  }
}