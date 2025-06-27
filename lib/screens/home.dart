import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:task_remider_app/const/color.dart';
import 'package:task_remider_app/widgets/task_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_remider_app/screens/add_task.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

bool show = true;

class _Home_ScreenState extends State<Home_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: Visibility(
        visible: show,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTaskScreen()),
            );
          },
          backgroundColor: primaryColor,
          child: Icon(Icons.add, size: 30),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No tasks found'));
            }
            return NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.forward) {
                  setState(() {
                    show = true;
                  });
                }
                if (notification.direction == ScrollDirection.reverse) {
                  setState(() {
                    show = false;
                  });
                }
                return true;
              },
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  return Task_Widget(
                    taskData: doc.data() as Map<String, dynamic>,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
