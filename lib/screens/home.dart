import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:task_remider_app/const/color.dart';
import 'package:task_remider_app/widgets/task_widgets.dart';

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
          onPressed: () {},
          backgroundColor: primaryColor,
          child: Icon(Icons.add, size: 30),
        ),
      ),
      body: SafeArea(
        child: NotificationListener<UserScrollNotification>(
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
            itemBuilder: (context, index) {
              return Task_Widget(); // Task_Widget here will now work fine
            },
            itemCount: 10,
          ),
        ),
      ),
    );
  }
}
