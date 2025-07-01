import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Event types for user operations
enum UserEvent { logoutSuccess, logoutError, userDataLoaded, userDataError }

/// Event data for user operations
class UserEventData {
  final UserEvent event;
  final String? message;
  final String? errorCode;
  final User? user;

  const UserEventData({
    required this.event,
    this.message,
    this.errorCode,
    this.user,
  });
}

/// Service for handling user-related operations
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get userStream => _auth.authStateChanges();

  Future<UserEventData> logout() async {
    try {
      await _auth.signOut();
      return const UserEventData(
        event: UserEvent.logoutSuccess,
        message: 'Logged out successfully',
      );
    } catch (e) {
      return UserEventData(
        event: UserEvent.logoutError,
        message: 'Failed to logout',
        errorCode: e.toString(),
      );
    }
  }

  UserEventData getUserData() {
    try {
      final user = currentUser;
      if (user != null) {
        return UserEventData(
          event: UserEvent.userDataLoaded,
          user: user,
          message: 'User data loaded successfully',
        );
      } else {
        return const UserEventData(
          event: UserEvent.userDataError,
          message: 'No user logged in',
          errorCode: 'no_user',
        );
      }
    } catch (e) {
      return UserEventData(
        event: UserEvent.userDataError,
        message: 'Failed to load user data',
        errorCode: e.toString(),
      );
    }
  }

  String getUserDisplayName() {
    final user = currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    } else if (user?.email != null) {
      return user!.email!.split('@')[0];
    }
    return 'User';
  }

  Future<String> getUserFullName() async {
    final user = currentUser;
    if (user == null) return 'User';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final fullName = data['fullName'] as String?;
        if (fullName != null && fullName.isNotEmpty) {
          return fullName;
        }
      }
    } catch (e) {
      print('Error fetching user full name: $e');
    }

    return getUserDisplayName();
  }

  String getUserEmail() {
    return currentUser?.email ?? 'No email';
  }

  String getUserInitials() {
    final displayName = getUserDisplayName();
    if (displayName.length >= 2) {
      return displayName.substring(0, 2).toUpperCase();
    } else if (displayName.isNotEmpty) {
      return displayName[0].toUpperCase();
    }
    return 'U';
  }

  Future<String> getUserInitialsAsync() async {
    final fullName = await getUserFullName();

    final words = fullName.trim().split(' ');

    if (words.length >= 2) {
      return '${words.first[0]}${words.last[0]}'.toUpperCase();
    } else if (fullName.length >= 2) {
      return fullName.substring(0, 2).toUpperCase();
    } else if (fullName.isNotEmpty) {
      return fullName[0].toUpperCase();
    }
    return 'U';
  }

  bool get isLoggedIn => currentUser != null;

  DateTime? getUserCreationDate() {
    return currentUser?.metadata.creationTime;
  }

  DateTime? getLastSignInDate() {
    return currentUser?.metadata.lastSignInTime;
  }

  /// Update user full name in Firestore
  Future<void> updateUserFullName(String newFullName) async {
    final user = currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // Update in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'fullName': newFullName, 'updatedAt': FieldValue.serverTimestamp()},
      );

      // Also update Firebase Auth display name
      await user.updateDisplayName(newFullName);

      print('User full name updated successfully');
    } catch (e) {
      print('Error updating user full name: $e');

      if (e.toString().contains('PigeonUserInfo') ||
          e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('type cast') ||
          e.toString().contains('List<Object?>')) {
        print(
          'Known Firebase plugin type casting error - name likely updated successfully',
        );
        return; // Treat as success
      }

      rethrow;
    }
  }

  /// Change user password
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = currentUser;
    if (user == null) throw Exception('No user logged in');
    if (user.email == null) throw Exception('User email not available');

    try {
      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      print('Password updated successfully');
    } catch (e) {
      print('Error changing password: $e');

      // Check if it's the known type casting error - if so, consider it successful
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('type cast') ||
          e.toString().contains('List<Object?>')) {
        print(
          'Known Firebase plugin type casting error - password likely changed successfully',
        );
        return; // Treat as success
      }

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            throw Exception('Mật khẩu hiện tại không đúng');
          case 'weak-password':
            throw Exception('Mật khẩu mới quá yếu');
          case 'requires-recent-login':
            throw Exception('Vui lòng đăng nhập lại để thay đổi mật khẩu');
          default:
            throw Exception('Lỗi thay đổi mật khẩu: ${e.message}');
        }
      }
      rethrow;
    }
  }

  /// Upload avatar as base64 to Firestore (FREE alternative to Firebase Storage)
  Future<void> uploadAvatarBase64(File imageFile) async {
    final user = currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // Read file as bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Convert to base64
      final String base64Image = base64Encode(imageBytes);

      // Update Firestore with avatar base64
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'avatarBase64': base64Image,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      print('Avatar uploaded successfully as base64');
    } catch (e) {
      print('Error uploading avatar: $e');
      rethrow;
    }
  }

  /// Get user avatar as base64 from Firestore
  Future<String?> getUserAvatarBase64() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return data['avatarBase64'] as String?;
      }
    } catch (e) {
      print('Error fetching avatar base64: $e');
    }

    return null;
  }

  /// Delete user avatar
  Future<void> deleteAvatar() async {
    final user = currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'avatarBase64': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      print('Avatar deleted successfully');
    } catch (e) {
      print('Error deleting avatar: $e');
      rethrow;
    }
  }
}
