import 'package:flutter/material.dart';

/// Event types for authentication notifications
enum AuthEvent { loginSuccess, loginFailure, signupSuccess, signupFailure }

/// Data class for authentication events
class AuthEventData {
  final AuthEvent event;
  final String? message;
  final String? errorCode;

  const AuthEventData({required this.event, this.message, this.errorCode});
}

/// Service for handling authentication notifications
/// Follows event-driven programming principles
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Show notification based on authentication event
  void showAuthNotification(BuildContext context, AuthEventData eventData) {
    final (message, color, duration) = getNotificationDetails(eventData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Get notification details based on event type and error code
  (String message, Color color, Duration duration) getNotificationDetails(
    AuthEventData eventData,
  ) {
    switch (eventData.event) {
      case AuthEvent.loginSuccess:
        return ('Login successful!', Colors.green, const Duration(seconds: 2));

      case AuthEvent.signupSuccess:
        return (
          'Sign up successful!',
          Colors.green,
          const Duration(seconds: 2),
        );

      case AuthEvent.loginFailure:
        return (
          _getLoginErrorMessage(eventData.errorCode),
          Colors.red,
          const Duration(seconds: 3),
        );

      case AuthEvent.signupFailure:
        return (
          _getSignupErrorMessage(eventData.errorCode),
          Colors.red,
          const Duration(seconds: 3),
        );
    }
  }

  /// Get specific error message for login failures
  String _getLoginErrorMessage(String? errorCode) {
    if (errorCode == null) return 'Login failed';

    if (errorCode.contains('user-not-found')) {
      return 'No user found with this email';
    } else if (errorCode.contains('wrong-password')) {
      return 'Incorrect password';
    } else if (errorCode.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (errorCode.contains('user-disabled')) {
      return 'This account has been disabled';
    } else if (errorCode.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later';
    }

    return 'Login failed';
  }

  /// Get specific error message for signup failures
  String _getSignupErrorMessage(String? errorCode) {
    if (errorCode == null) return 'Sign up failed';

    if (errorCode.contains('email-already-in-use')) {
      return 'An account with this email already exists';
    } else if (errorCode.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters';
    } else if (errorCode.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (errorCode.contains('password-mismatch')) {
      return 'Passwords do not match';
    } else if (errorCode.contains('operation-not-allowed')) {
      return 'Email/password accounts are not enabled';
    }

    return 'Sign up failed';
  }
}
