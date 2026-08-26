import 'package:flutter/material.dart';
import 'package:todo_app/data/database.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:todo_app/services/theme_service.dart';
import 'package:todo_app/util/dashboard_banner.dart';
import 'package:todo_app/util/dialog_box.dart';
import 'package:todo_app/util/todo_tile.dart';

enum TaskStatusFilter {
  all('All'),
  active('Active'),
  done('Done');

  final String label;
  const TaskStatusFilter(this.label);
}

enum SortOption {
  none('Default'),
  priority('Priority'),
  dueDate('Due Date');

  final String label;
  const SortOption(this.label);
}

class HomePage extends StatefulWidget {
  final ToDoDataBase? database;
  final NotificationService? notifications;
  const HomePage({super.key, this.database, this.notifications});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ToDoDataBase db;
  late NotificationService notifications;

  final _controller = TextEditingController();
  final _searchController = TextEditingController();

  bool _isSearching = false;
  String _searchQuery = '';
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;
  String _selectedCategory = 'All';
  SortOption _sortOption = SortOption.none;

  static const List<String> _predefinedCategories = [
    'All',
    'General',
    'Work',
    'Personal',
    'Fitness',
    'Study',
    'Learning',
  ];

  @override
  void initState() {
    super.initState();
    db = widget.database ?? ToDoDataBase();
    notifications = widget.notifications ?? NotificationService();
    db.loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _availableCategories {
    final categories = <String>{'All', ..._predefinedCategories};
    for (final task in db.toDoList) {
      if (task.category.isNotEmpty) {
        categories.add(task.category);
      }
    }
    return categories.toList();
  }

  List<Task> get _filteredAndSortedTasks {
    List<Task> list = List.from(db.toDoList);

    // Filter by search query keywords
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((t) => t.title.toLowerCase().contains(query)).toList();
    }

    // Filter by completion status
    if (_statusFilter == TaskStatusFilter.active) {
      list = list.where((t) => !t.isCompleted).toList();
    } else if (_statusFilter == TaskStatusFilter.done) {
      list = list.where((t) => t.isCompleted).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      list = list.where((t) => t.category == _selectedCategory).toList();
    }

    // Sort
    if (_sortOption == SortOption.priority) {
      list.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    } else if (_sortOption == SortOption.dueDate) {
      list.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    }

    return list;
  }

  void checkBoxChanged(bool? value, Task task) {
    final index = db.toDoList.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final updatedTask = task.copyWith(
        isCompleted: value ?? !task.isCompleted,
      );
      setState(() {
        db.toDoList[index] = updatedTask;
        db.updateDataBase();
      });

      if (updatedTask.isCompleted) {
        notifications.cancelTaskNotification(updatedTask.id);
      } else {
        notifications.scheduleTaskDeadlineNotification(updatedTask);
      }
    }
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
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: taskTitle.trim(),
        isCompleted: false,
        priority: priority ?? Priority.medium,
        category: category ?? 'General',
        dueDate: dueDate,
      );
      setState(() {
        db.toDoList.add(newTask);
        _controller.clear();
        db.updateDataBase();
      });
      notifications.scheduleTaskDeadlineNotification(newTask);
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

  void deleteTask(Task task) {
    final deletedIndex = db.toDoList.indexWhere((t) => t.id == task.id);
    if (deletedIndex == -1) return;

    final deletedTask = db.toDoList[deletedIndex];

    setState(() {
      db.toDoList.removeAt(deletedIndex);
      db.updateDataBase();
    });

    notifications.cancelTaskNotification(deletedTask.id);

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
            if (!deletedTask.isCompleted) {
              notifications.scheduleTaskDeadlineNotification(deletedTask);
            }
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
    final tasks = _filteredAndSortedTasks;
    final totalCount = db.toDoList.length;
    final completedCount = db.toDoList.where((t) => t.isCompleted).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 18,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text('TO DO'),
        centerTitle: !_isSearching,
        elevation: 0,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
        actions: [
          if (_isSearching) ...[
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear search',
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search tasks',
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          ],
          IconButton(
            icon: Icon(
              ThemeService().isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: ThemeService().isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
            onPressed: () {
              setState(() {
                ThemeService().toggleTheme();
              });
            },
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort tasks',
            initialValue: _sortOption,
            onSelected: (SortOption option) {
              setState(() {
                _sortOption = option;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: SortOption.none,
                child: Text('Default Order'),
              ),
              const PopupMenuItem(
                value: SortOption.priority,
                child: Text('Sort by Priority'),
              ),
              const PopupMenuItem(
                value: SortOption.dueDate,
                child: Text('Sort by Due Date'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filter Chips Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Status filters
                  for (final status in TaskStatusFilter.values) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status.label),
                        selected: _statusFilter == status,
                        selectedColor: isDark ? Colors.amber : Colors.black,
                        labelStyle: TextStyle(
                          color: _statusFilter == status
                              ? (isDark ? Colors.black : Colors.yellow)
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        backgroundColor: isDark
                            ? const Color(0xFF2C2C2C)
                            : Colors.yellow[300],
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _statusFilter = status;
                            });
                          }
                        },
                      ),
                    ),
                  ],

                  // Divider between status and category
                  Container(
                    height: 24,
                    width: 1.5,
                    color: isDark ? Colors.white24 : Colors.black26,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                  ),

                  // Category filters
                  for (final category in _availableCategories) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        selectedColor: isDark ? Colors.amber : Colors.black,
                        labelStyle: TextStyle(
                          color: _selectedCategory == category
                              ? (isDark ? Colors.black : Colors.yellow)
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        backgroundColor: isDark
                            ? const Color(0xFF2C2C2C)
                            : Colors.yellow[300],
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Dashboard Progress Banner
          DashboardBanner(
            completedCount: completedCount,
            totalCount: totalCount,
          ),

          // Tasks List
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      'No tasks found',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

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
                        onDismissed: (direction) => deleteTask(task),
                        child: ToDoTile.fromTask(
                          task: task,
                          onChanged: (value) => checkBoxChanged(value, task),
                          deleteFunction: (context) => deleteTask(task),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}