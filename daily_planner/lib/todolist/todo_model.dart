import 'package:flutter/foundation.dart';

class Todo {
  final String id;
  String title;
  String? description;
  DateTime deadline;
  bool isCompleted;
  bool isDailyRecurring;
  final DateTime createdAt;
  DateTime? completedAt;

  Todo({
    required this.id,
    required this.title,
    this.description,
    required this.deadline,
    this.isCompleted = false,
    this.isDailyRecurring = false,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    bool? isDailyRecurring,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      isDailyRecurring: isDailyRecurring ?? this.isDailyRecurring,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.millisecondsSinceEpoch,
      'isCompleted': isCompleted ? 1 : 0,
      'isDailyRecurring': isDailyRecurring ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  factory Todo.fromMap(Map<String, Object?> map) {
    return Todo(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int),
      isCompleted: (map['isCompleted'] as int) == 1,
      isDailyRecurring: (map['isDailyRecurring'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      completedAt: map['completedAt'] == null ? null : DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int),
    );
  }

  @override
  String toString() => 'Todo(id: $id, title: $title)';
}
