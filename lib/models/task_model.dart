import 'package:cloud_firestore/cloud_firestore.dart';

/// Task model representing a task entity
class TaskModel {
  final String? id;
  final String title;
  final String description;
  final String priority;
  final String date;
  final String time;
  final bool isCompleted;
  final DateTime? createdAt;
  final String userId;

  const TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.date,
    required this.time,
    this.isCompleted = false,
    this.createdAt,
    required this.userId,
  });

  /// Create TaskModel from Firestore document
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      priority: data['priority'] ?? 'Medium',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      userId: data['userId'] ?? '',
    );
  }

  /// Convert TaskModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'date': date,
      'time': time,
      'isCompleted': isCompleted,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'userId': userId,
    };
  }

  /// Create a copy of TaskModel with updated fields
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? date,
    String? time,
    bool? isCompleted,
    DateTime? createdAt,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.priority == priority &&
        other.date == date &&
        other.time == time &&
        other.isCompleted == isCompleted &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      priority,
      date,
      time,
      isCompleted,
      userId,
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, description: $description, priority: $priority, date: $date, time: $time, isCompleted: $isCompleted, createdAt: $createdAt, userId: $userId)';
  }
}
