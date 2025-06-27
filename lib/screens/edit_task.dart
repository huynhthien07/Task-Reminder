import 'package:flutter/material.dart';
import '../const/color.dart';
import '../data/task_service.dart';

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
    try {
      await TaskService.updateTask(
        id: id,
        title: _titleController.text,
        description: _descController.text,
        priority: (widget.taskData['priority'] ?? '').toString(),
        date: (widget.taskData['date'] ?? '').toString(),
        time: (widget.taskData['time'] ?? '').toString(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task updated successfully!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            elevation: 8,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: \\${e.toString()}')),
      );
    }
  }

  Future<void> _deleteTaskFromApi() async {
    try {
      await TaskService.deleteTask(id: widget.taskData['id']);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task deleted successfully!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            elevation: 8,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: \\${e.toString()}')),
      );
    }
  }

  void _saveEdit() {
    _updateTask();
  }

  void _deleteTask() {
    _deleteTaskFromApi();
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
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFBBD5F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    '${_selectedDate} ${_selectedTime}',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      height: 1.75,
                      letterSpacing: -0.32,
                    ),
                  ),
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
