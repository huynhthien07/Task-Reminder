import 'package:flutter/material.dart';

import '../const/color.dart';
import '../data/task_service.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';

/// Event types for edit task operations
enum EditTaskEvent {
  editModeToggled,
  taskFieldChanged,
  dateSelected,
  timeSelected,
  priorityChanged,
  taskSaved,
  taskDeleted,
  validationError,
}

/// Event data for edit task operations
class EditTaskEventData {
  final EditTaskEvent event;
  final String? message;
  final dynamic data;

  const EditTaskEventData({required this.event, this.message, this.data});
}

/// Edit task screen following event-driven architecture and clean code principles
class EditTask extends StatefulWidget {
  final Map<String, dynamic> taskData;
  const EditTask({Key? key, required this.taskData}) : super(key: key);

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  // Controllers for text fields
  late TextEditingController _titleController;
  late TextEditingController _descController;

  // Task properties
  late String _selectedPriority;
  late String _selectedTime;
  late String _selectedDate;

  // State management
  bool _isEditing = false;
  bool _isLoading = false;

  // Services
  final TaskService _taskService = TaskService();
  final UserService _userService = UserService();

  // Event stream controller for edit task events
  final List<EditTaskEventData> _eventHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeTaskData();
    _emitEvent(
      EditTaskEventData(
        event: EditTaskEvent.editModeToggled,
        message: 'Edit task screen initialized',
        data: {'taskId': widget.taskData['id']},
      ),
    );
  }

  /// Initialize text controllers with task data
  void _initializeControllers() {
    _titleController = TextEditingController(
      text: widget.taskData['title'] ?? '',
    );
    _descController = TextEditingController(
      text: widget.taskData['description'] ?? '',
    );
  }

  /// Initialize task data properties
  void _initializeTaskData() {
    _selectedPriority = widget.taskData['priority'] ?? 'High';
    _selectedTime = widget.taskData['time'] ?? '';
    _selectedDate = widget.taskData['date'] ?? '';
  }

  /// Emit edit task event for event-driven architecture
  void _emitEvent(EditTaskEventData eventData) {
    _eventHistory.add(eventData);
    debugPrint('[EditTask] Event: ${eventData.event} - ${eventData.message}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Update task with validation and event emission
  Future<void> _updateTask() async {
    // Validate task data
    if (!_validateTaskData()) {
      return;
    }

    final id = widget.taskData['id'];
    if (!_validateTaskId(id)) {
      return;
    }

    _setLoadingState(true);

    try {
      final currentUser = _userService.currentUser;
      if (!_validateCurrentUser(currentUser)) {
        return;
      }

      final updatedTask = _createUpdatedTaskModel(id, currentUser!.uid);
      final result = await _taskService.updateTask(updatedTask);

      if (mounted) {
        _setLoadingState(false);
        _handleUpdateResult(result);
      }
    } catch (e) {
      _handleUpdateError(e);
    }
  }

  /// Validate task data before update
  bool _validateTaskData() {
    if (_titleController.text.trim().isEmpty) {
      _emitEvent(
        EditTaskEventData(
          event: EditTaskEvent.validationError,
          message: 'Task title cannot be empty',
        ),
      );
      _showErrorMessage('Task title cannot be empty');
      return false;
    }
    return true;
  }

  /// Validate task ID
  bool _validateTaskId(dynamic id) {
    if (id == null || (id is String && id.isEmpty)) {
      _emitEvent(
        EditTaskEventData(
          event: EditTaskEvent.validationError,
          message: 'Task ID is missing',
        ),
      );
      _showErrorMessage('Task ID is missing, cannot update!');
      return false;
    }
    return true;
  }

  /// Validate current user
  bool _validateCurrentUser(dynamic currentUser) {
    if (currentUser == null) {
      _emitEvent(
        EditTaskEventData(
          event: EditTaskEvent.validationError,
          message: 'User not logged in',
        ),
      );
      _showErrorMessage('You must be logged in to edit tasks');
      return false;
    }
    return true;
  }

  /// Create updated task model
  TaskModel _createUpdatedTaskModel(String id, String userId) {
    return TaskModel(
      id: id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      priority: _selectedPriority,
      date: _selectedDate,
      time: _selectedTime,
      isCompleted: widget.taskData['isCompleted'] ?? false,
      userId: widget.taskData['userId'] ?? userId,
    );
  }

  /// Handle update result
  void _handleUpdateResult(dynamic result) {
    NotificationService().showTaskNotification(context, result);

    if (result.event == TaskEvent.taskUpdated) {
      _emitEvent(
        EditTaskEventData(
          event: EditTaskEvent.taskSaved,
          message: 'Task updated successfully',
          data: {'taskId': widget.taskData['id']},
        ),
      );
      Navigator.of(context).pop();
    }
  }

  /// Handle update error
  void _handleUpdateError(dynamic error) {
    if (mounted) {
      _setLoadingState(false);
      _emitEvent(
        EditTaskEventData(
          event: EditTaskEvent.validationError,
          message: 'Failed to update task: ${error.toString()}',
        ),
      );
      _showErrorMessage('Failed to update task: ${error.toString()}');
    }
  }

  /// Set loading state
  void _setLoadingState(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  /// Show error message
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Delete task with validation and event emission
  Future<void> _deleteTaskFromApi() async {
    final taskId = widget.taskData['id']?.toString();
    if (!_validateTaskIdForDeletion(taskId)) {
      return;
    }

    _setLoadingState(true);

    try {
      final result = await _taskService.deleteTask(taskId!);

      if (mounted) {
        _setLoadingState(false);
        _handleDeleteResult(result);
      }
    } catch (e) {
      _handleDeleteError(e);
    }
  }

  /// Validate task ID for deletion
  bool _validateTaskIdForDeletion(String? taskId) {
    if (taskId == null || taskId.isEmpty) {
      _emitEvent(
        EditTaskEventData(
          event: EditTaskEvent.validationError,
          message: 'Task ID is missing for deletion',
        ),
      );
      _showErrorMessage('Task ID is missing');
      return false;
    }
    return true;
  }

  /// Handle delete result
  void _handleDeleteResult(dynamic result) {
    NotificationService().showTaskNotification(context, result);

    if (result.event == TaskEvent.taskDeleted) {
      _emitEvent(
        EditTaskEventData(
          event: EditTaskEvent.taskDeleted,
          message: 'Task deleted successfully',
          data: {'taskId': widget.taskData['id']},
        ),
      );
      Navigator.of(context).pop();
    }
  }

  /// Handle delete error
  void _handleDeleteError(dynamic error) {
    if (mounted) {
      _setLoadingState(false);
      _emitEvent(
        EditTaskEventData(
          event: EditTaskEvent.validationError,
          message: 'Failed to delete task: ${error.toString()}',
        ),
      );
      _showErrorMessage('Failed to delete task: ${error.toString()}');
    }
  }

  void _saveEdit() {
    _updateTask();
  }

  void _deleteTask() {
    _deleteTaskFromApi();
  }

  Future<void> _selectDate() async {
    if (!_isEditing) return;

    _logEvent('Date picker opened');
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final formattedDate =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      _onDateChanged(formattedDate);
    }
  }

  Future<void> _selectTime() async {
    if (!_isEditing) return;

    _logEvent('Time picker opened');
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      final formattedTime = picked.format(context);
      _onTimeChanged(formattedTime);
    }
  }

  /// Handle date change with event emission
  void _onDateChanged(String date) {
    setState(() {
      _selectedDate = date;
    });
    _emitEvent(
      EditTaskEventData(
        event: EditTaskEvent.dateSelected,
        message: 'Task date changed',
        data: {'date': date},
      ),
    );
  }

  /// Handle time change with event emission
  void _onTimeChanged(String time) {
    setState(() {
      _selectedTime = time;
    });
    _emitEvent(
      EditTaskEventData(
        event: EditTaskEvent.timeSelected,
        message: 'Task time changed',
        data: {'time': time},
      ),
    );
  }

  /// Handle priority change with event emission
  void _onPriorityChanged(String priority) {
    setState(() {
      _selectedPriority = priority;
    });
    _emitEvent(
      EditTaskEventData(
        event: EditTaskEvent.priorityChanged,
        message: 'Task priority changed',
        data: {'priority': priority},
      ),
    );
  }

  /// Log event for debugging (deprecated - use _emitEvent instead)
  void _logEvent(String event) {
    debugPrint('[EditTask Event] $event at ${DateTime.now()}');
  }

  void _showEditDialog() async {
    final titleController = TextEditingController(text: _titleController.text);
    final descController = TextEditingController(text: _descController.text);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF363636),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Edit Task Title And Description',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Divider(
              color: Colors.white24,
              thickness: 1,
              height: 8, // Sát lại với title
            ),
          ],
        ),
        content: SizedBox(
          width: 340, // Rộng hơn mặc định
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF363636),
                  hintText: 'Task title',
                  hintStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8687E7)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF363636),
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8687E7)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          SizedBox(
            width: 140,
            height: 48,
            child: TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8687E7), fontSize: 16),
              ),
            ),
          ),
          SizedBox(
            width: 140,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8687E7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(180, 48),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                setState(() {
                  _titleController.text = titleController.text;
                  _descController.text = descController.text;
                });
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Edit',
                style: TextStyle(fontSize: 16, color: Colors.white),
                selectionColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    if (result == true) {
      _saveEdit();
    }
  }

  void _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF363636),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 20,
        ), // giảm padding hai bên
        insetPadding: EdgeInsets.symmetric(
          horizontal: 12,
        ), // giảm padding ngoài
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Delete Task',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Divider(color: Colors.white24, thickness: 1, height: 8),
          ],
        ),
        content: SizedBox(
          width: 370,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete this task?',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                'Task title: ${_titleController.text}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          SizedBox(
            width: 140,
            height: 48,
            child: TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8687E7), fontSize: 16),
              ),
            ),
          ),
          SizedBox(
            width: 140,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8687E7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(180, 48),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
    if (result == true) {
      _deleteTask();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 375,
          height: 812,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              // Close button
              Positioned(
                left: 24,
                top: 55,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFCBCBCB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 24,
                top: 114,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.radio_button_unchecked,
                          size: 24,
                          color: Colors.black87,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _titleController.text,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Text(
                        _descController.text,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 24,
                top: 243,
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Task Time :',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        height: 1.31,
                        letterSpacing: -0.32,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 220,
                right: 25,
                top: 235,
                child: Row(
                  children: [
                    // Date picker
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: ShapeDecoration(
                            color: _isEditing
                                ? const Color(0xFFBBD5F3)
                                : Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.black87,
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _selectedDate.isEmpty
                                      ? 'Date'
                                      : _selectedDate,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 10,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    // Time picker
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: ShapeDecoration(
                            color: _isEditing
                                ? const Color(0xFFBBD5F3)
                                : Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.black87,
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _selectedTime.isEmpty
                                      ? 'Time'
                                      : _selectedTime,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 10,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Task Priority
              Positioned(
                left: 23,
                top: 306,
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, color: Colors.grey, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Task Priority :',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        height: 1.31,
                        letterSpacing: -0.32,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 259,
                top: 299,
                child: Container(
                  width: 90,
                  decoration: ShapeDecoration(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: IgnorePointer(
                    ignoring: !_isEditing,
                    child: PopupMenuButton<String>(
                      color: Colors.white,
                      onSelected: (value) {
                        _onPriorityChanged(value);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'High',
                          child: Text(
                            'High',
                            style: TextStyle(
                              color: priorityHigh,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Medium',
                          child: Text(
                            'Medium',
                            style: TextStyle(
                              color: priorityMedium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Low',
                          child: Text(
                            'Low',
                            style: TextStyle(
                              color: priorityLow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      child: Container(
                        width: 120,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedPriority == 'High'
                              ? priorityHigh
                              : _selectedPriority == 'Medium'
                              ? priorityMedium
                              : priorityLow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _selectedPriority,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_drop_down, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Delete Task
              Positioned(
                left: 24,
                top: 370,
                child: GestureDetector(
                  onTap: _showDeleteDialog,
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Task', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
              // Enhanced Edit Button
              Positioned(left: 24, top: 724, child: _buildEnhancedEditButton()),
            ],
          ),
        ),
      ),
    );
  }

  /// Build enhanced edit button with comprehensive editing capabilities
  Widget _buildEnhancedEditButton() {
    return GestureDetector(
      onTap: _showComprehensiveEditDialog,
      child: Container(
        width: 327,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: ShapeDecoration(
          color: const Color(0xFF8687E7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.edit, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Edit Task Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.51,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show comprehensive edit dialog for all task properties
  void _showComprehensiveEditDialog() async {
    _emitEvent(
      EditTaskEventData(
        event: EditTaskEvent.editModeToggled,
        message: 'Comprehensive edit dialog opened',
      ),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _buildComprehensiveEditDialog(),
    );

    if (result == true) {
      _saveEdit();
    }
  }

  /// Build comprehensive edit dialog
  Widget _buildComprehensiveEditDialog() {
    final titleController = TextEditingController(text: _titleController.text);
    final descController = TextEditingController(text: _descController.text);
    String tempPriority = _selectedPriority;
    String tempDate = _selectedDate;
    String tempTime = _selectedTime;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          backgroundColor: Color(0xFF363636),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Edit Task Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.white24, thickness: 1, height: 16),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditField(
                  controller: titleController,
                  label: 'Task Title',
                  hint: 'Enter task title',
                ),
                SizedBox(height: 16),
                _buildEditField(
                  controller: descController,
                  label: 'Description',
                  hint: 'Enter task description',
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                _buildPrioritySelector(tempPriority, (value) {
                  setDialogState(() {
                    tempPriority = value;
                  });
                }),
                SizedBox(height: 16),
                _buildDateTimeSelectors(
                  tempDate,
                  tempTime,
                  (date) {
                    setDialogState(() {
                      tempDate = date;
                    });
                  },
                  (time) {
                    setDialogState(() {
                      tempTime = time;
                    });
                  },
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            _buildDialogButton(
              'Cancel',
              () => Navigator.of(context).pop(false),
              isSecondary: true,
            ),
            _buildDialogButton('Save Changes', () {
              _titleController.text = titleController.text;
              _descController.text = descController.text;
              _selectedPriority = tempPriority;
              _selectedDate = tempDate;
              _selectedTime = tempTime;
              Navigator.of(context).pop(true);
            }),
          ],
        );
      },
    );
  }

  /// Build edit field widget
  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFF2A2A2A),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white38),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8687E7)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  /// Build priority selector widget
  Widget _buildPrioritySelector(
    String currentPriority,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            _buildPriorityChip(
              'High',
              priorityHigh,
              currentPriority,
              onChanged,
            ),
            SizedBox(width: 8),
            _buildPriorityChip(
              'Medium',
              priorityMedium,
              currentPriority,
              onChanged,
            ),
            SizedBox(width: 8),
            _buildPriorityChip('Low', priorityLow, currentPriority, onChanged),
          ],
        ),
      ],
    );
  }

  /// Build priority chip widget
  Widget _buildPriorityChip(
    String priority,
    Color color,
    String currentPriority,
    Function(String) onChanged,
  ) {
    final isSelected = currentPriority == priority;
    return GestureDetector(
      onTap: () => onChanged(priority),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
        ),
        child: Text(
          priority,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Build date time selectors widget
  Widget _buildDateTimeSelectors(
    String currentDate,
    String currentTime,
    Function(String) onDateChanged,
    Function(String) onTimeChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeButton(
                label: currentDate.isEmpty ? 'Select Date' : currentDate,
                icon: Icons.calendar_today,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    final formattedDate =
                        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                    onDateChanged(formattedDate);
                  }
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildDateTimeButton(
                label: currentTime.isEmpty ? 'Select Time' : currentTime,
                icon: Icons.access_time,
                onTap: () async {
                  final currentContext = context;
                  final picked = await showTimePicker(
                    context: currentContext,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null && currentContext.mounted) {
                    final formattedTime = picked.format(currentContext);
                    onTimeChanged(formattedTime);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build date time button widget
  Widget _buildDateTimeButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white38),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build dialog button widget
  Widget _buildDialogButton(
    String text,
    VoidCallback onPressed, {
    bool isSecondary = false,
  }) {
    return SizedBox(
      width: 140,
      height: 48,
      child: isSecondary
          ? TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onPressed,
              child: Text(
                text,
                style: TextStyle(color: Color(0xFF8687E7), fontSize: 16),
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8687E7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(180, 48),
                padding: EdgeInsets.zero,
              ),
              onPressed: onPressed,
              child: Text(
                text,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
    );
  }
}
