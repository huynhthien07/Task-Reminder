import 'package:flutter/material.dart';
import 'package:task_remider_app/const/color.dart';
import 'package:task_remider_app/screens/edit_task.dart';

class Task_Widget extends StatefulWidget {
  final Map<String, dynamic>? taskData;
  const Task_Widget({Key? key, this.taskData}) : super(key: key);

  @override
  State<Task_Widget> createState() => _Task_WidgetState();
}

bool isDone = false;

class _Task_WidgetState extends State<Task_Widget> {
  @override
  Widget build(BuildContext context) {
    final data = widget.taskData;
    final title = data?['title'] ?? 'Task Title';
    final description =
        data?['description'] ?? 'Task Subtitle or Description here';
    final priority = data?['priority'] ?? 'High';
    final date = data?['date'] ?? '';
    final time = data?['time'] ?? '';
    Color priorityColor = priority == 'High'
        ? priorityHigh
        : priority == 'Medium'
        ? priorityMedium
        : priorityLow;
    return GestureDetector(
      onTap: () {
        if (data != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditTask(taskData: data)),
          );
        }
      },
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
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily:
                                  'Poppins', // Font Poppins for modern look
                            ),
                          ),
                          Checkbox(
                            value: isDone,
                            onChanged: (value) {
                              setState(() {
                                isDone = !isDone;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        description,
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
                            priority,
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
                          // Time button with smaller size
                          priorityButton(
                            '$date $time',
                            Icons.access_time,
                            timeButtonColor,
                          ),
                          SizedBox(width: 8),
                          // Edit button with adjusted color
                          priorityButton('Edit', Icons.edit, primaryColor),
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
    final isEdit = label == 'Edit';
    return Container(
      constraints: BoxConstraints(maxWidth: isEdit ? 100 : 120),
      height: 30,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
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
        color: primaryColor.withOpacity(0.1), // Light background for the icon
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
