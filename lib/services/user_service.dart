import 'package:firebase_auth/firebase_auth.dart';

/// Event types for user operations
enum UserEvent {
  logoutSuccess,
  logoutError,
  userDataLoaded,
  userDataError,
}

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

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user stream
  Stream<User?> get userStream => _auth.authStateChanges();

  /// Logout user
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

  /// Get user data
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

  /// Get user display name
  String getUserDisplayName() {
    final user = currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    } else if (user?.email != null) {
      // Extract name from email (part before @)
      return user!.email!.split('@')[0];
    }
    return 'User';
  }

  /// Get user email
  String getUserEmail() {
    return currentUser?.email ?? 'No email';
  }

  /// Get user initials for avatar
  String getUserInitials() {
    final displayName = getUserDisplayName();
    if (displayName.length >= 2) {
      return displayName.substring(0, 2).toUpperCase();
    } else if (displayName.isNotEmpty) {
      return displayName[0].toUpperCase();
    }
    return 'U';
  }

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Get user creation date
  DateTime? getUserCreationDate() {
    return currentUser?.metadata.creationTime;
  }

  /// Get last sign in date
  DateTime? getLastSignInDate() {
    return currentUser?.metadata.lastSignInTime;
  }
}
