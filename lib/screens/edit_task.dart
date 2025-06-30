import 'package:flutter/material.dart';
import '../const/color.dart';
import '../data/task_service.dart';
import '../models/task_model.dart';
// import '../services/notification_service.dart';
import '../services/user_service.dart';

class EditTask extends StatefulWidget {
  final Map<String, dynamic> taskData;
  const EditTask({Key? key, required this.taskData}) : super(key: key);

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedPriority;
  late String _selectedTime;
  late String _selectedDate;
  bool _isEditing = false;
  final TaskService _taskService = TaskService();
  final UserService _userService = UserService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.taskData['title'] ?? '',
    );
    _descController = TextEditingController(
      text: widget.taskData['description'] ?? '',
    );
    _selectedPriority = widget.taskData['priority'] ?? 'High';
    _selectedTime = widget.taskData['time'] ?? '';
    _selectedDate = widget.taskData['date'] ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _updateTask() async {
    final id = widget.taskData['id'];
    if (id == null || (id is String && id.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task ID is missing, cannot update!')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      final currentUser = _userService.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You must be logged in to edit tasks'),
            ),
          );
        }
        return;
      }

      // Create updated TaskModel
      final updatedTask = TaskModel(
        id: id,
        title: _titleController.text,
        description: _descController.text,
        priority: _selectedPriority,
        date: _selectedDate,
        time: _selectedTime,
        isCompleted: widget.taskData['isCompleted'] ?? false,
        userId:
            widget.taskData['userId'] ??
            currentUser.uid, // Preserve original userId or use current user
      );

      final result = await _taskService.updateTask(updatedTask);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // NotificationService().showTaskNotification(context, result);

        if (result.event == TaskEvent.taskUpdated) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteTaskFromApi() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final taskId = widget.taskData['id']?.toString();
      if (taskId == null) {
        throw Exception('Task ID is missing');
      }

      final result = await _taskService.deleteTask(taskId);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // NotificationService().showTaskNotification(context, result);

        if (result.event == TaskEvent.taskDeleted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete task: ${e.toString()}')),
        );
      }
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

  void _onDateChanged(String date) {
    setState(() {
      _selectedDate = date;
    });
    _logEvent('Date changed to: $date');
  }

  void _onTimeChanged(String time) {
    setState(() {
      _selectedTime = time;
    });
    _logEvent('Time changed to: $time');
  }

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
                'Task title : ' + _titleController.text,
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
                        setState(() {
                          _selectedPriority = value;
                        });
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
              // Edit Task Button
              Positioned(
                left: 24,
                top: 724,
                child: GestureDetector(
                  onTap: _showEditDialog,
                  child: Container(
                    width: 327,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF8687E7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Edit Task',
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
