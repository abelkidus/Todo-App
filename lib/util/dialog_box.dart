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
  final String title;

  const DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
    this.initialCategory = 'Work',
    this.initialPriority = Priority.medium,
    this.initialDueDate,
    this.title = 'Add New Task',
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
      backgroundColor:
          isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Text(
        widget.title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
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
                fontSize: 15,
                color: isDark
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                hintText: 'What needs to be done?',
                hintStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFF59E0B),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Selection (ChoiceChips)
            Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 6.0,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? (isDark
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFF0F172A))
                        : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0)),
                  ),
                  selectedColor: isDark
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFF0F172A),
                  backgroundColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                        : (isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF475569)),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<Priority>(
                segments: const [
                  ButtonSegment<Priority>(
                    value: Priority.low,
                    label: Text('Low'),
                    icon: Icon(Icons.arrow_downward, size: 14),
                  ),
                  ButtonSegment<Priority>(
                    value: Priority.medium,
                    label: Text('Medium'),
                    icon: Icon(Icons.remove, size: 14),
                  ),
                  ButtonSegment<Priority>(
                    value: Priority.high,
                    label: Text('High'),
                    icon: Icon(Icons.arrow_upward, size: 14),
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
                        return isDark
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFF0F172A);
                      }
                      return isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC);
                    },
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(WidgetState.selected)) {
                        return isDark
                            ? const Color(0xFF0F172A)
                            : Colors.white;
                      }
                      return isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569);
                    },
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDueDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _selectedDueDate == null
                          ? 'Set Deadline'
                          : 'Due: ${_formatDate(_selectedDueDate!)}',
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      foregroundColor: isDark
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFF0F172A),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_selectedDueDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
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
            const SizedBox(height: 24),

            // Action Buttons (Save & Cancel)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyButton(
                  text: 'Cancel',
                  onPressed: widget.onCancel,
                ),
                const SizedBox(width: 10),
                MyButton(
                  text: 'Save',
                  isPrimary: true,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}