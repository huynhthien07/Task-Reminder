import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AuthenticationDatasource {
  Future<void> register(
    String email,
    String password,
    String passwordConfirm, {
    String? fullName,
  });
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
    String passwordConfirm, {
    String? fullName,
  }) async {
    print("🔥 REGISTER DEBUG: Starting registration");
    print("🔥 Email: $email");
    print("🔥 Password length: ${password.length}");
    print("🔥 Password confirm length: ${passwordConfirm.length}");
    print("🔥 Full name: $fullName");

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

      if (fullName != null && fullName.isNotEmpty) {
        try {
          await userCredential.user?.updateDisplayName(fullName);
        } catch (e) {
          print("🔥 REGISTER DEBUG: Failed to update display name: $e");
        }
      }

      if (userCredential.user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'fullName': fullName,
                'email': email.trim(),
                'createdAt': FieldValue.serverTimestamp(),
              });
          print(
            "🔥 REGISTER DEBUG: Firestore user document created successfully",
          );
        } catch (e) {
          print("🔥 REGISTER DEBUG: Failed to create Firestore document: $e");
        }
      }
    } catch (e) {
      print("🔥 REGISTER DEBUG: Firebase registration failed: $e");

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print(
          "🔥 REGISTER DEBUG: User was created despite error, creating Firestore document",
        );
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .set({
                'fullName': fullName,
                'email': email.trim(),
                'createdAt': FieldValue.serverTimestamp(),
              });
          print(
            "🔥 REGISTER DEBUG: Firestore user document created in catch block",
          );

          if (fullName != null && fullName.isNotEmpty) {
            try {
              await currentUser.updateDisplayName(fullName);
            } catch (displayNameError) {
              print(
                "🔥 REGISTER DEBUG: Failed to update display name in catch: $displayNameError",
              );
            }
          }

          return;
        } catch (firestoreError) {
          print(
            "🔥 REGISTER DEBUG: Failed to create Firestore document in catch: $firestoreError",
          );
        }
      }

      rethrow;
    }
  }
}
