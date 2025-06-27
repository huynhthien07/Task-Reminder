import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskService {
  static Future<void> addTask({
    required BuildContext context,
    required String title,
    required String description,
    required String priority,
    required String time,
    DateTime? date,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').add({
        'title': title,
        'description': description,
        'priority': priority,
        'date': date != null
            ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
            : '',
        'time': time,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task: \\${e.toString()}')),
      );
    }
  }

  static Future<void> updateTask({
    required String id,
    required String title,
    required String description,
    required String priority,
    required String date,
    required String time,
  }) async {
    await FirebaseFirestore.instance.collection('tasks').doc(id).update({
      'title': title,
      'description': description,
    });
  }

  static Future<void> deleteTask({required String id}) async {
    await FirebaseFirestore.instance.collection('tasks').doc(id).delete();
  }
}
