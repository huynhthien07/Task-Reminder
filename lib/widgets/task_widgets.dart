import 'package:flutter/material.dart';
import 'package:task_remider_app/const/color.dart';
import 'package:task_remider_app/models/task_model.dart';
import 'package:task_remider_app/screens/edit_task.dart';

/// Data class for clean task display
class TaskDisplayData {
  final String title;
  final String description;
  final String priority;
  final String date;
  final String time;
  final bool isCompleted;
  final String id;

  const TaskDisplayData({
    required this.title,
    required this.description,
    required this.priority,
    required this.date,
    required this.time,
    required this.isCompleted,
    required this.id,
  });
}

class Task_Widget extends StatefulWidget {
  final TaskModel? task;
  final Map<String, dynamic>? taskData; // Keep for backward compatibility
  final VoidCallback? onToggleComplete;

  const Task_Widget({Key? key, this.task, this.taskData, this.onToggleComplete})
    : super(key: key);

  @override
  State<Task_Widget> createState() => _Task_WidgetState();
}

class _Task_WidgetState extends State<Task_Widget> {
  // Extract task data with clean code principles
  TaskDisplayData get _taskData {
    final task = widget.task;
    final data = widget.taskData;

    return TaskDisplayData(
      title: task?.title ?? data?['title'] ?? 'Task Title',
      description:
          task?.description ??
          data?['description'] ??
          'Task Subtitle or Description here',
      priority: task?.priority ?? data?['priority'] ?? 'High',
      date: task?.date ?? data?['date'] ?? '',
      time: task?.time ?? data?['time'] ?? '',
      isCompleted: task?.isCompleted ?? data?['isCompleted'] ?? false,
      id: task?.id ?? data?['id'] ?? '',
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return priorityHigh;
    }
  }

  void _onTaskTap() {
    final taskData = _taskData;
    final taskDataForEdit = {
      'id': taskData.id,
      'title': taskData.title,
      'description': taskData.description,
      'priority': taskData.priority,
      'date': taskData.date,
      'time': taskData.time,
      'isCompleted': taskData.isCompleted,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTask(taskData: taskDataForEdit),
      ),
    );
  }

  void _onCheckboxChanged() {
    if (widget.onToggleComplete != null) {
      widget.onToggleComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskData = _taskData;
    final priorityColor = _getPriorityColor(taskData.priority);
    return GestureDetector(
      onTap: _onTaskTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 8,
        ), // Reduced vertical padding
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              12,
            ), // Slightly smaller border radius
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(
                  0.1,
                ), // Lighter shadow for a clean look
                spreadRadius: 3,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                // Task image as icon, smaller size
                imageIcon(),
                SizedBox(width: 15),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            taskData.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily:
                                  'Poppins', // Font Poppins for modern look
                            ),
                          ),
                          Checkbox(
                            value: taskData.isCompleted,
                            onChanged: (value) => _onCheckboxChanged(),
                            activeColor: primaryColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        taskData.description,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Priority Level
                      Row(
                        children: [
                          Text(
                            'Priority: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            taskData.priority,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  priorityColor, // Red color for high priority
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          // Time button with flexible width
                          priorityButton(
                            '${taskData.date} ${taskData.time}',
                            Icons.access_time,
                            timeButtonColor,
                          ),
                          SizedBox(width: 8),
                          // Edit button with fixed width
                          Flexible(
                            child: GestureDetector(
                              onTap: _onTaskTap,
                              child: _buildEditButton(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Create button with icon
  Widget priorityButton(String label, IconData icon, Color color) {
    return Flexible(
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build edit button
  Widget _buildEditButton() {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                'Edit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Task image using an Icon, with smaller size
  Widget imageIcon() {
    return Container(
      height: 110, // Reduced height
      width: 85, // Adjusted width
      decoration: BoxDecoration(
        color: primaryColor.withValues(
          alpha: 0.1,
        ), // Light background for the icon
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          Icons.task, // Using a task icon
          size: 40, // Smaller icon size
          color: primaryColor,
        ),
      ),
    );
  }
}
