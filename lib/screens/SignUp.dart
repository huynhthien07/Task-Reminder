// import 'package:flutter/material.dart';
// import 'package:task_remider_app/const/color.dart';
// import 'package:task_remider_app/data/auth_data.dart';

// class SignUp_Screen extends StatefulWidget {
//   final VoidCallback show;
//   const SignUp_Screen(this.show, {super.key});

//   @override
//   State<SignUp_Screen> createState() => _SignUp_ScreenState();
// }

// class _SignUp_ScreenState extends State<SignUp_Screen> {
//   FocusNode _focusNode1 = FocusNode();
//   FocusNode _focusNode2 = FocusNode();
//   FocusNode _focusNode3 = FocusNode();

//   final email = TextEditingController();
//   final password = TextEditingController();
//   final passwordConfirm = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _focusNode1.addListener(() {
//       setState(() {});
//     });
//     _focusNode2.addListener(() {
//       setState(() {});
//     });
//     _focusNode3.addListener(() {
//       setState(() {});
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 20),
//               image(),
//               SizedBox(height: 50),
//               textfield(email, _focusNode1, 'Email', Icons.email),
//               SizedBox(height: 16),
//               textfield(password, _focusNode2, 'Password', Icons.lock),
//               SizedBox(height: 16),
//               textfield(
//                 passwordConfirm,
//                 _focusNode3,
//                 'Confirm Password',
//                 Icons.lock,
//               ),
//               SizedBox(height: 20),
//               account(),
//               SizedBox(height: 30),
//               SignUp_bottom(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget account() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           Text(
//             "Already have an account?",
//             style: TextStyle(color: Colors.grey[700], fontSize: 16),
//           ),
//           SizedBox(width: 5),
//           GestureDetector(
//             onTap: widget.show,
//             child: Text(
//               'Log In',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget SignUp_bottom() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: GestureDetector(
//         onTap: () {
//           AuthenticationRemote().register(
//             email.text,
//             password.text,
//             passwordConfirm.text,
//           );
//         },
//         child: Container(
//           alignment: Alignment.center,
//           width: double.infinity,
//           height: 55,
//           decoration: BoxDecoration(
//             color: primaryColor,
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: [
//               BoxShadow(
//                 color: primaryColor.withOpacity(0.3),
//                 blurRadius: 10,
//                 spreadRadius: 3,
//               ),
//             ],
//           ),
//           child: Text(
//             'Sign Up',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget textfield(
//     TextEditingController _controller,
//     FocusNode _focusNode,
//     String label,
//     IconData icon,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 5,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         child: TextField(
//           controller: _controller,
//           focusNode: _focusNode,
//           style: TextStyle(fontSize: 16, color: Colors.black),
//           obscureText: label.toLowerCase().contains('password'),
//           decoration: InputDecoration(
//             prefixIcon: Icon(
//               icon,
//               color: _focusNode.hasFocus ? primaryColor : Color(0xffc5c5c5),
//             ),
//             contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
//             hintText: label,
//             hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Color(0xffe0e0e0), width: 1.5),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: primaryColor, width: 2.5),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget image() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Container(
//         width: double.infinity,
//         height: 250,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('images/1.jpg'),
//             fit: BoxFit.cover,
//           ),
//           borderRadius: BorderRadius.circular(20),
//         ),
//       ),
//     );
//   }
// }

//test
import 'package:flutter/material.dart';
import 'package:task_remider_app/const/color.dart';
import 'package:task_remider_app/data/auth_data.dart';
import 'package:task_remider_app/services/notification_service.dart';

class SignUp_Screen extends StatefulWidget {
  final VoidCallback show;
  const SignUp_Screen(this.show, {super.key});

  @override
  State<SignUp_Screen> createState() => _SignUp_ScreenState();
}

class _SignUp_ScreenState extends State<SignUp_Screen> {
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode3 = FocusNode();

  final email = TextEditingController();
  final password = TextEditingController();
  final passwordConfirm = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(() => setState(() {}));
    _focusNode2.addListener(() => setState(() {}));
    _focusNode3.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              image(),
              SizedBox(height: 50),
              textfield(email, _focusNode1, 'Email', Icons.email),
              SizedBox(height: 16),
              textfield(password, _focusNode2, 'Password', Icons.lock),
              SizedBox(height: 16),
              textfield(
                passwordConfirm,
                _focusNode3,
                'Confirm Password',
                Icons.lock,
              ),
              SizedBox(height: 20),
              account(),
              SizedBox(height: 30),
              SignUp_bottom(),
            ],
          ),
        ),
      ),
    );
  }

  Widget account() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Already have an account?",
            style: TextStyle(color: Colors.grey[700], fontSize: 16),
          ),
          SizedBox(width: 5),
          GestureDetector(
            onTap: widget.show,
            child: Text(
              'Log In',
              style: TextStyle(
                color: primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget SignUp_bottom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          setState(() {
            isLoading = true;
          });

          try {
            await AuthenticationRemote().register(
              email.text,
              password.text,
              passwordConfirm.text,
            );

            if (mounted) {
              NotificationService().showAuthNotification(
                context,
                const AuthEventData(event: AuthEvent.signupSuccess),
              );
              await Future.delayed(Duration(seconds: 2));
              widget.show(); // Switch to login screen
            }
          } catch (e, stackTrace) {
            print("🔥 SIGNUP ERROR: $e");
            print("🔥 STACK TRACE: $stackTrace");

            if (mounted) {
              NotificationService().showAuthNotification(
                context,
                AuthEventData(
                  event: AuthEvent.signupFailure,
                  errorCode: e.toString(),
                ),
              );
            }
          } finally {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          child: isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget textfield(
    TextEditingController _controller,
    FocusNode _focusNode,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: TextStyle(fontSize: 16, color: Colors.black),
          obscureText: label.toLowerCase().contains('password'),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: _focusNode.hasFocus ? primaryColor : Color(0xffc5c5c5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xffe0e0e0), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget image() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/1.jpg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
