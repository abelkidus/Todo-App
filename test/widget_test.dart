import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:todo_app/data/database.dart';

void main() {
  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp('todo_hive_test_');
    Hive.init(tempDir.path);
    await Hive.openBox('mybox');
  });

  tearDown(() async {
    await Hive.close();
  });

  test('database creates and persists the todo list', () async {
    final db = ToDoDataBase();

    db.loadData();

    expect(db.toDoList, [
      ['watch tutorial', false],
      ['exercise', false],
    ]);

    db.toDoList.add(['Read book', true]);
    db.updateDataBase();

    final savedTasks = Hive.box('mybox').get('TODOLIST');
    expect(savedTasks, db.toDoList);
  });
}
