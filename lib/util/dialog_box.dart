import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/util/my_button.dart';

class DialogBox extends StatefulWidget {
  final TextEditingController controller;
  final dynamic onSave;
  final VoidCallback onCancel;
  final String initialCategory;
  final Priority initialPriority;
  final DateTime? initialDueDate;

  const DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
    this.initialCategory = 'Work',
    this.initialPriority = Priority.medium,
    this.initialDueDate,
  });

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  late String _selectedCategory;
  late Priority _selectedPriority;
  DateTime? _selectedDueDate;

  static const List<String> _categories = [
    'Work',
    'Personal',
    'Fitness',
    'Study',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedPriority = widget.initialPriority;
    _selectedDueDate = widget.initialDueDate;
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  void _handleSave() {
    if (widget.onSave != null) {
      try {
        (widget.onSave as dynamic)(
          widget.controller.text,
          _selectedCategory,
          _selectedPriority,
          _selectedDueDate,
        );
      } catch (_) {
        (widget.onSave as dynamic)();
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF242424) : Colors.yellow[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Add New Task',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task title input
            TextField(
              controller: widget.controller,
              autofocus: true,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                hintText: 'Add a new task',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Selection (ChoiceChips)
            Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: isDark ? Colors.amber : Colors.yellow[700],
                  backgroundColor:
                      isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.black87)
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Priority Selection (SegmentedButton)
            Text(
              'Priority',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<Priority>(
                segments: const [
                  ButtonSegment<Priority>(
                    value: Priority.low,
                    label: Text('Low'),
                    icon: Icon(Icons.arrow_downward, size: 16),
                  ),
                  ButtonSegment<Priority>(
                    value: Priority.medium,
                    label: Text('Medium'),
                    icon: Icon(Icons.remove, size: 16),
                  ),
                  ButtonSegment<Priority>(
                    value: Priority.high,
                    label: Text('High'),
                    icon: Icon(Icons.arrow_upward, size: 16),
                  ),
                ],
                selected: {_selectedPriority},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedPriority = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(WidgetState.selected)) {
                        return isDark ? Colors.amber : Colors.yellow[700];
                      }
                      return isDark ? const Color(0xFF1E1E1E) : Colors.white;
                    },
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.black;
                      }
                      return isDark ? Colors.white70 : Colors.black87;
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // DatePicker Button (Deadline)
            Text(
              'Deadline',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDueDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _selectedDueDate == null
                          ? 'Set Deadline'
                          : 'Due: ${_formatDate(_selectedDueDate!)}',
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      foregroundColor:
                          isDark ? Colors.white70 : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_selectedDueDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    tooltip: 'Clear deadline',
                    onPressed: () {
                      setState(() {
                        _selectedDueDate = null;
                      });
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Action Buttons (Save & Cancel)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyButton(text: 'Save', onPressed: _handleSave),
                const SizedBox(width: 8),
                MyButton(text: 'Cancel', onPressed: widget.onCancel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}