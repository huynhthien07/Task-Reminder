import 'package:flutter/material.dart';
import '../const/color.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> taskData;
  const TaskDetailScreen({Key? key, required this.taskData}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedPriority;
  late String _selectedTime;
  late String _selectedDate;

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

  void _saveEdit() {
    // TODO: Implement update logic to Firestore or local DB
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Task updated (demo)!')));
  }

  void _deleteTask() {
    // TODO: Implement delete logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Task deleted (demo)!')));
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
              // Title
              Positioned(
                left: 24,
                top: 114,
                child: Container(
                  width: 324,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xDD818181),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Task title',
                        hintStyle: TextStyle(
                          color: const Color(0xFFD9D9D9),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                          letterSpacing: -0.32,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: -0.32,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                    ),
                  ),
                ),
              ),
              // Description
              Positioned(
                left: 24,
                top: 172,
                child: Container(
                  width: 324,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xDD818181),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _descController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Description',
                        hintStyle: TextStyle(
                          color: const Color(0xFFD9D9D9),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                          letterSpacing: -0.32,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: -0.32,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                    ),
                  ),
                ),
              ),
              // Task Time
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
                left: 55,
                top: 307,
                child: Text(
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
              // Delete Task
              Positioned(
                left: 24,
                top: 370,
                child: GestureDetector(
                  onTap: _deleteTask,
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
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
                  onTap: _saveEdit,
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
