import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_app/models/task.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final Priority priority;
  final String category;
  final DateTime? dueDate;
  final ValueChanged<bool?>? onChanged;
  final void Function(BuildContext)? deleteFunction;

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    this.priority = Priority.medium,
    this.category = 'General',
    this.dueDate,
    required this.onChanged,
    required this.deleteFunction,
  });

  factory ToDoTile.fromTask({
    Key? key,
    required Task task,
    required ValueChanged<bool?>? onChanged,
    required void Function(BuildContext)? deleteFunction,
  }) {
    return ToDoTile(
      key: key,
      taskName: task.title,
      taskCompleted: task.isCompleted,
      priority: task.priority,
      category: task.category,
      dueDate: task.dueDate,
      onChanged: onChanged,
      deleteFunction: deleteFunction,
    );
  }

  bool get _isOverdue {
    if (dueDate == null || taskCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
  }

  Color get _priorityColor {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.amber.shade700;
      case Priority.low:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 16, right: 20),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.yellow,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Colored left border indicator for priority
                  Container(
                    width: 6,
                    color: _priorityColor,
                  ),

                  // Main card body
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Checkbox
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Checkbox(
                              value: taskCompleted,
                              onChanged: onChanged,
                              activeColor: Colors.black,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Content: Category tag, Title, Due Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Category tag & Priority label
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        category,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      priority.displayName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _priorityColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Task title
                                Text(
                                  taskName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    decoration: taskCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: taskCompleted
                                        ? Colors.black45
                                        : Colors.black87,
                                  ),
                                ),

                                // Due Date & Overdue highlight
                                if (dueDate != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.event,
                                        size: 14,
                                        color: _isOverdue
                                            ? Colors.red.shade700
                                            : Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(dueDate!),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: _isOverdue
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: _isOverdue
                                              ? Colors.red.shade700
                                              : Colors.black54,
                                        ),
                                      ),
                                      if (_isOverdue) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                              color: Colors.red.shade400,
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Text(
                                            'OVERDUE',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}