import 'dart:convert';

/// Priority levels for a [Task].
enum Priority {
  low,
  medium,
  high;

  /// Returns the human-readable capitalized display name.
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  /// Parses a string into a [Priority] enum safely and case-insensitively.
  static Priority fromString(String? value) {
    if (value == null) return Priority.medium;
    final normalized = value.trim().toLowerCase();
    return Priority.values.firstWhere(
      (p) => p.name.toLowerCase() == normalized,
      orElse: () => Priority.medium,
    );
  }
}

/// Represents a todo task item.
class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final Priority priority;
  final String category;

  const Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.priority = Priority.medium,
    this.category = 'General',
  });

  /// Creates a copy of this [Task] with the given fields replaced by new values.
  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    Priority? priority,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }

  /// Converts this [Task] instance into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,
      'category': category,
    };
  }

  /// Creates a [Task] instance from a Map.
  factory Task.fromMap(Map<String, dynamic> map) {
    DateTime? parsedDueDate;
    if (map['dueDate'] != null) {
      if (map['dueDate'] is DateTime) {
        parsedDueDate = map['dueDate'] as DateTime;
      } else if (map['dueDate'] is String) {
        parsedDueDate = DateTime.tryParse(map['dueDate'] as String);
      } else if (map['dueDate'] is int) {
        parsedDueDate =
            DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int);
      }
    }

    Priority parsedPriority = Priority.medium;
    if (map['priority'] != null) {
      if (map['priority'] is Priority) {
        parsedPriority = map['priority'] as Priority;
      } else if (map['priority'] is String) {
        parsedPriority = Priority.fromString(map['priority'] as String);
      } else if (map['priority'] is int) {
        final index = map['priority'] as int;
        if (index >= 0 && index < Priority.values.length) {
          parsedPriority = Priority.values[index];
        }
      }
    }

    return Task(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      isCompleted: map['isCompleted'] is bool
          ? map['isCompleted'] as bool
          : (map['isCompleted'] == 1 ||
              map['isCompleted']?.toString().toLowerCase() == 'true'),
      dueDate: parsedDueDate,
      priority: parsedPriority,
      category: map['category']?.toString() ?? 'General',
    );
  }

  /// Converts this [Task] instance to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates a [Task] instance from a JSON string.
  factory Task.fromJson(String source) =>
      Task.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted, dueDate: $dueDate, priority: $priority, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.isCompleted == isCompleted &&
        other.dueDate == dueDate &&
        other.priority == priority &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        isCompleted.hashCode ^
        dueDate.hashCode ^
        priority.hashCode ^
        category.hashCode;
  }
}
