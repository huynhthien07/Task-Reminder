import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../const/color.dart';
import '../data/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  String _selectedPriority = 'High';
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final Map<String, Color> _priorityColors = {
    'High': Color(0xffFF5722),
    'Medium': Color(0xffFF9800),
    'Low': Color(0xff4CAF50),
  };

  Future<void> _addTaskToFirebase() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields!')));
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Are you sure you want to add this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await TaskService.addTask(
      context: context,
      title: _titleController.text,
      description: _descController.text,
      priority: _selectedPriority,
      time: _selectedTime != null ? _selectedTime!.format(context) : '',
      date: _selectedDate,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Add task successfully!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        elevation: 8,
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
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
              Positioned(
                left: 121,
                top: 799,
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                ),
              ),
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
                left: 28,
                top: 59,
                child: Container(width: 24, height: 24, child: Stack()),
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
                child: GestureDetector(
                  onTap: _pickDateTime,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _selectedDate != null && _selectedTime != null
                              ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}  ' +
                                    _selectedTime!.format(context)
                              : 'DD/MM/YY 00:00',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            height: 1.75,
                            letterSpacing: -0.32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                top: 242,
                child: Container(width: 24, height: 24, child: Stack()),
              ),
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
              Positioned(
                left: 23,
                top: 306,
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, color: Colors.grey, size: 24),
                    SizedBox(width: 8),
                    Container(width: 24, height: 24, child: Stack()),
                  ],
                ),
              ),
              Positioned(
                left: 24,
                top: 724,
                child: GestureDetector(
                  onTap: _addTaskToFirebase,
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
                          'Add Task',
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
            ],
          ),
        ),
      ),
    );
  }
}
