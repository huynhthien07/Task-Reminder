import 'package:flutter/material.dart';
import 'package:task_remider_app/const/color.dart';

class Task_Widget extends StatefulWidget {
  const Task_Widget({super.key});

  @override
  State<Task_Widget> createState() => _Task_WidgetState();
}

bool isDone = false;

class _Task_WidgetState extends State<Task_Widget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
                          'Task Title',
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
                      'Task Subtitle or Description here',
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
                          'High',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: priorityHigh, // Red color for high priority
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        // Time button with smaller size
                        priorityButton(
                          'Time',
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
    );
  }

  // Create button with icon
  Widget priorityButton(String label, IconData icon, Color color) {
    return Container(
      width: 80, // Slightly smaller width
      height: 30, // Adjusted height for smaller buttons
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
