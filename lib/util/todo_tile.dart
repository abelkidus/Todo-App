import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final Priority priority;
  final String category;
  final DateTime? dueDate;
  final ValueChanged<bool?>? onChanged;
  final void Function(BuildContext)? deleteFunction;
  final VoidCallback? onEdit;

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    this.priority = Priority.medium,
    this.category = 'General',
    this.dueDate,
    required this.onChanged,
    this.deleteFunction,
    this.onEdit,
  });

  factory ToDoTile.fromTask({
    Key? key,
    required Task task,
    required ValueChanged<bool?>? onChanged,
    void Function(BuildContext)? deleteFunction,
    VoidCallback? onEdit,
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
      onEdit: onEdit,
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
        return const Color(0xFFEF4444); // Red 500
      case Priority.medium:
        return const Color(0xFFF59E0B); // Amber 500
      case Priority.low:
        return const Color(0xFF10B981); // Emerald 500
    }
  }

  Color _getCategoryBgColor(bool isDark) {
    switch (category.toLowerCase()) {
      case 'work':
        return isDark ? const Color(0x263B82F6) : const Color(0xFFEFF6FF);
      case 'personal':
        return isDark ? const Color(0x26A855F7) : const Color(0xFFFAF5FF);
      case 'fitness':
        return isDark ? const Color(0x2610B981) : const Color(0xFFECFDF5);
      case 'study':
      case 'learning':
        return isDark ? const Color(0x26F97316) : const Color(0xFFFFF7ED);
      default:
        return isDark ? const Color(0x2664748B) : const Color(0xFFF1F5F9);
    }
  }

  Color _getCategoryTextColor(bool isDark) {
    switch (category.toLowerCase()) {
      case 'work':
        return isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB);
      case 'personal':
        return isDark ? const Color(0xFFD8B4FE) : const Color(0xFF9333EA);
      case 'fitness':
        return isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669);
      case 'study':
      case 'learning':
        return isDark ? const Color(0xFFFDBA74) : const Color(0xFFEA580C);
      default:
        return isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 12, right: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : const Color(0x0A0F172A),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Colored left border indicator for priority
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: _priorityColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            activeColor: isDark
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFFF59E0B),
                            checkColor: isDark
                                ? const Color(0xFF0F172A)
                                : Colors.white,
                            side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                              width: 1.5,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Content: Category tag, Title, Due Date
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onEdit,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Category tag & Priority label
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getCategoryBgColor(isDark),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              _getCategoryTextColor(isDark),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _priorityColor
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        priority.displayName,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: _priorityColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Task title
                                Text(
                                  taskName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                    decoration: taskCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: taskCompleted
                                        ? (isDark
                                            ? const Color(0xFF64748B)
                                            : const Color(0xFF94A3B8))
                                        : (isDark
                                            ? const Color(0xFFF8FAFC)
                                            : const Color(0xFF0F172A)),
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
                                            ? const Color(0xFFEF4444)
                                            : (isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B)),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(dueDate!),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: _isOverdue
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: _isOverdue
                                              ? const Color(0xFFEF4444)
                                              : (isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(
                                                      0xFF64748B)),
                                        ),
                                      ),
                                      if (_isOverdue) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0x33EF4444)
                                                : const Color(0xFFFEF2F2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                              color: isDark
                                                  ? const Color(0x66EF4444)
                                                  : const Color(0xFFFECACA),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: const Text(
                                            'OVERDUE',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.3,
                                              color: Color(0xFFEF4444),
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
    );
  }
}