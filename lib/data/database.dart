import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  List toDoList = [];

  late final Box _myBox;

  ToDoDataBase() {
    _myBox = Hive.box('mybox');
  }

  // run this method if this is the first time ever opening this app
  void createInitialData() {
    toDoList = [
      ['watch tutorial', false],
      ['exercise', false],
    ];
  }

  void loadData() {
    final savedData = _myBox.get('TODOLIST');

    if (savedData == null) {
      createInitialData();
      updateDataBase();
    } else {
      toDoList = List.from(savedData);
    }
  }

  void updateDataBase() {
    _myBox.put('TODOLIST', toDoList);
  }
}