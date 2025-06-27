// import 'package:firebase_auth/firebase_auth.dart';

// abstract class AuthenticationDatasource {
//   Future<void> register(String email, String password, String passwordConfirm);
//   Future<void> login(String email, String password);
// }

// class AuthenticationRemote extends AuthenticationDatasource {
//   @override
//   Future<void> login(String email, String password) async {
//     await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: email.trim(),
//       password: password.trim(),
//     );
//   }

//   @override
//   Future<void> register(
//     String email,
//     String password,
//     String passwordConfirm,
//   ) async {
//     if (password == passwordConfirm) {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );
//     }
//   }
// }

//test
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenticationDatasource {
  Future<void> register(String email, String password, String passwordConfirm);
  Future<void> login(String email, String password);
}

class AuthenticationRemote extends AuthenticationDatasource {
  @override
  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  @override
  Future<void> register(
    String email,
    String password,
    String passwordConfirm,
  ) async {
    print("🔥 REGISTER DEBUG: Starting registration");
    print("🔥 Email: $email");
    print("🔥 Password length: ${password.length}");
    print("🔥 Password confirm length: ${passwordConfirm.length}");

    if (password != passwordConfirm) {
      print("🔥 REGISTER DEBUG: Password mismatch detected");
      throw FirebaseAuthException(
        code: 'password-mismatch',
        message: 'Passwords do not match.',
      );
    }

    print("🔥 REGISTER DEBUG: Passwords match, calling Firebase");
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
      print("🔥 REGISTER DEBUG: Firebase registration successful");
      print("🔥 User ID: ${userCredential.user?.uid}");
      print("🔥 User Email: ${userCredential.user?.email}");
    } catch (e) {
      print("🔥 REGISTER DEBUG: Firebase registration failed: $e");
      rethrow;
    }
  }
}
