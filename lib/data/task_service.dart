import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_remider_app/models/task_model.dart';
import 'package:task_remider_app/services/user_service.dart';

/// Event types for task operations
enum TaskEvent { taskAdded, taskUpdated, taskDeleted, taskCompleted, taskError }

/// Event data for task operations
class TaskEventData {
  final TaskEvent event;
  final TaskModel? task;
  final String? message;
  final String? errorCode;

  const TaskEventData({
    required this.event,
    this.task,
    this.message,
    this.errorCode,
  });
}

/// Event-driven task service following clean architecture principles
class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  static const String _collection = 'tasks';

  /// Add a new task
  Future<TaskEventData> addTask(TaskModel task) async {
    try {
      // Ensure the task has the current user's ID
      final currentUser = _userService.currentUser;
      if (currentUser == null) {
        return const TaskEventData(
          event: TaskEvent.taskError,
          message: 'User must be logged in to add tasks',
          errorCode: 'no_user',
        );
      }

      final taskWithUserId = task.copyWith(userId: currentUser.uid);
      final docRef = await _firestore
          .collection(_collection)
          .add(taskWithUserId.toFirestore());
      final newTask = taskWithUserId.copyWith(id: docRef.id);

      return TaskEventData(
        event: TaskEvent.taskAdded,
        task: newTask,
        message: 'Task added successfully!',
      );
    } catch (e) {
      return TaskEventData(
        event: TaskEvent.taskError,
        message: 'Failed to add task',
        errorCode: e.toString(),
      );
    }
  }

  /// Update an existing task
  Future<TaskEventData> updateTask(TaskModel task) async {
    try {
      if (task.id == null) {
        return TaskEventData(
          event: TaskEvent.taskError,
          message: 'Task ID is required for update',
          errorCode: 'missing_id',
        );
      }

      // Ensure the current user owns this task
      final currentUser = _userService.currentUser;
      if (currentUser == null) {
        return const TaskEventData(
          event: TaskEvent.taskError,
          message: 'User must be logged in to update tasks',
          errorCode: 'no_user',
        );
      }

      // Verify task ownership before updating
      final existingTask = await getTaskById(task.id!);
      if (existingTask == null) {
        return const TaskEventData(
          event: TaskEvent.taskError,
          message: 'Task not found',
          errorCode: 'task_not_found',
        );
      }

      if (existingTask.userId != currentUser.uid) {
        return const TaskEventData(
          event: TaskEvent.taskError,
          message: 'You can only update your own tasks',
          errorCode: 'unauthorized',
        );
      }

      // Ensure the task maintains the correct userId
      final taskWithUserId = task.copyWith(userId: currentUser.uid);
      await _firestore
          .collection(_collection)
          .doc(task.id)
          .update(taskWithUserId.toFirestore());

      return TaskEventData(
        event: TaskEvent.taskUpdated,
        task: taskWithUserId,
        message: 'Task updated successfully!',
      );
    } catch (e) {
      return TaskEventData(
        event: TaskEvent.taskError,
        message: 'Failed to update task',
        errorCode: e.toString(),
      );
    }
  }

  /// Delete a task
  Future<TaskEventData> deleteTask(String taskId) async {
    try {
      // Ensure the current user owns this task
      final currentUser = _userService.currentUser;
      if (currentUser == null) {
        return const TaskEventData(
          event: TaskEvent.taskError,
          message: 'User must be logged in to delete tasks',
          errorCode: 'no_user',
        );
      }

      // Verify task ownership before deleting
      final existingTask = await getTaskById(taskId);
      if (existingTask == null) {
        return const TaskEventData(
          event: TaskEvent.taskError,
          message: 'Task not found',
          errorCode: 'task_not_found',
        );
      }

      if (existingTask.userId != currentUser.uid) {
        return const TaskEventData(
          event: TaskEvent.taskError,
          message: 'You can only delete your own tasks',
          errorCode: 'unauthorized',
        );
      }

      await _firestore.collection(_collection).doc(taskId).delete();

      return TaskEventData(
        event: TaskEvent.taskDeleted,
        message: 'Task deleted successfully!',
      );
    } catch (e) {
      return TaskEventData(
        event: TaskEvent.taskError,
        message: 'Failed to delete task',
        errorCode: e.toString(),
      );
    }
  }

  /// Toggle task completion status
  Future<TaskEventData> toggleTaskCompletion(TaskModel task) async {
    try {
      if (task.id == null) {
        return TaskEventData(
          event: TaskEvent.taskError,
          message: 'Task ID is required',
          errorCode: 'missing_id',
        );
      }

      // Ensure the current user owns this task
      final currentUser = _userService.currentUser;
      if (currentUser == null) {
        return const TaskEventData(
          event: TaskEvent.taskError,
          message: 'User must be logged in to update tasks',
          errorCode: 'no_user',
        );
      }

      if (task.userId != currentUser.uid) {
        return const TaskEventData(
          event: TaskEvent.taskError,
          message: 'You can only update your own tasks',
          errorCode: 'unauthorized',
        );
      }

      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await _firestore.collection(_collection).doc(task.id).update({
        'isCompleted': updatedTask.isCompleted,
      });

      return TaskEventData(
        event: TaskEvent.taskCompleted,
        task: updatedTask,
        message: updatedTask.isCompleted
            ? 'Task completed!'
            : 'Task marked as incomplete',
      );
    } catch (e) {
      return TaskEventData(
        event: TaskEvent.taskError,
        message: 'Failed to update task status',
        errorCode: e.toString(),
      );
    }
  }

  /// Get all tasks as a stream for the current user
  Stream<List<TaskModel>> getTasksStream() {
    final currentUser = _userService.currentUser;
    if (currentUser == null) {
      // Return empty stream if no user is logged in
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs
              .map((doc) => TaskModel.fromFirestore(doc))
              .toList();
          // Sort tasks by createdAt in the client to avoid composite index requirement
          tasks.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          return tasks;
        });
  }

  /// Get tasks stream as QuerySnapshot for compatibility with existing UI
  Stream<QuerySnapshot> getTasksQueryStream() {
    final currentUser = _userService.currentUser;
    if (currentUser == null) {
      // Return empty stream if no user is logged in
      return Stream.empty();
    }

    // Note: Removed orderBy to avoid composite index requirement
    // Tasks will be sorted in the UI layer instead
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots();
  }

  /// Get a single task by ID (only if it belongs to the current user)
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      final currentUser = _userService.currentUser;
      if (currentUser == null) {
        return null;
      }

      final doc = await _firestore.collection(_collection).doc(taskId).get();
      if (doc.exists) {
        final task = TaskModel.fromFirestore(doc);
        // Only return the task if it belongs to the current user
        if (task.userId == currentUser.uid) {
          return task;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
