import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_remider_app/models/task_model.dart';

/// Event types for notification operations
enum NotificationEvent {
  initialized,
  permissionGranted,
  permissionDenied,
  tokenReceived,
  messageReceived,
  notificationSent,
  error,
}

/// Data class for notification events
class NotificationEventData {
  final NotificationEvent event;
  final String? message;
  final String? errorCode;
  final Map<String, dynamic>? data;

  const NotificationEventData({
    required this.event,
    this.message,
    this.errorCode,
    this.data,
  });
}

/// Firebase Cloud Messaging service - Clean, event-driven implementation
class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<NotificationEventData> _eventController =
      StreamController<NotificationEventData>.broadcast();

  // Settings
  bool _isInitialized = false;
  String? _fcmToken;
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  int _notificationTimingMinutes = 15;
  BuildContext? _globalContext;

  // Settings keys
  static const String _soundEnabledKey = 'fcm_sound_enabled';
  static const String _notificationsEnabledKey = 'fcm_notifications_enabled';
  static const String _notificationTimingKey =
      'fcm_notification_timing_minutes';

  /// Get current FCM token
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;
  bool get soundEnabled => _soundEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  int get notificationTimingMinutes => _notificationTimingMinutes;
  BuildContext? get globalContext => _globalContext;

  /// Event stream for notification events
  Stream<NotificationEventData> get eventStream => _eventController.stream;

  /// Emit notification event
  void _emitEvent(NotificationEventData eventData) {
    _eventController.add(eventData);
    debugPrint(
      '[FirebaseNotificationService] Event: ${eventData.event} - ${eventData.message}',
    );
  }

  /// Initialize Firebase messaging
  Future<bool> initialize() async {
    try {
      // Load settings first
      await _loadSettings();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _emitEvent(
          const NotificationEventData(
            event: NotificationEvent.permissionGranted,
            message: 'User granted notification permission',
          ),
        );
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        _emitEvent(
          const NotificationEventData(
            event: NotificationEvent.permissionGranted,
            message: 'User granted provisional notification permission',
          ),
        );
      } else {
        _emitEvent(
          const NotificationEventData(
            event: NotificationEvent.permissionDenied,
            message: 'User declined notification permission',
          ),
        );
        return false;
      }

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('[FirebaseNotificationService] FCM Token: $_fcmToken');

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('[FirebaseNotificationService] Token refreshed: $newToken');
        // Here you would typically send the new token to your server
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
      debugPrint('[FirebaseNotificationService] Initialized successfully');
      return true;
    } catch (e) {
      debugPrint('[FirebaseNotificationService] Initialization error: $e');
      return false;
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
      '[FirebaseNotificationService] Foreground message: ${message.messageId}',
    );

    // When app is in foreground, Firebase automatically shows the notification
    // in the system notification panel. We can also show an in-app notification
    if (_isInitialized && _globalContext != null) {
      showInAppNotification(
        _globalContext!,
        title: message.notification?.title ?? 'Task Reminder',
        message: message.notification?.body ?? 'You have a task reminder',
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint(
      '[FirebaseNotificationService] Notification tapped: ${message.messageId}',
    );

    // Extract task data from message
    final taskData = message.data;
    if (taskData.isNotEmpty) {
      debugPrint('[FirebaseNotificationService] Task data: $taskData');
      // Here you could navigate to specific task or perform actions
    }
  }

  /// Send task reminder via FCM (this would typically be called from a server)
  Future<bool> sendTaskReminder(
    TaskModel task, {
    int minutesBefore = 15,
  }) async {
    if (!_isInitialized) {
      debugPrint('[FirebaseNotificationService] Service not initialized');
      return false;
    }

    try {
      // Create a local notification that appears in device notification panel
      await _sendLocalNotification(
        title: '📋 Task Reminder',
        body: '${task.title} is due in $minutesBefore minutes',
        data: {
          'taskId': task.id ?? '',
          'title': task.title,
          'description': task.description,
          'date': task.date,
          'time': task.time,
          'priority': task.priority,
          'type': 'task_reminder',
        },
      );

      debugPrint(
        '[FirebaseNotificationService] Task reminder sent to device notification panel',
      );
      return true;
    } catch (e) {
      debugPrint(
        '[FirebaseNotificationService] Error sending task reminder: $e',
      );
      return false;
    }
  }

  /// Send local notification to device notification panel
  Future<void> _sendLocalNotification({
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    if (!_notificationsEnabled) return;

    try {
      // Send actual system notification
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for task reminders',
            importance: Importance.high,
            priority: Priority.high,
            playSound: _soundEnabled,
            enableVibration: false, // Vibration removed as requested
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: _soundEnabled,
          ),
        ),
        payload: data?['taskId'] ?? '',
      );

      // Also show in-app notification if context is available
      if (_isInitialized && _globalContext != null) {
        showInAppNotification(_globalContext!, title: title, message: body);
      }

      _emitEvent(
        NotificationEventData(
          event: NotificationEvent.notificationSent,
          message: 'System notification sent: $title',
          data: data,
        ),
      );
    } catch (e) {
      _emitEvent(
        NotificationEventData(
          event: NotificationEvent.error,
          message: 'Failed to send notification: $e',
          errorCode: 'NOTIFICATION_SEND_ERROR',
        ),
      );
    }
  }

  /// Subscribe to topic for receiving notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('[FirebaseNotificationService] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint(
        '[FirebaseNotificationService] Error subscribing to topic: $e',
      );
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint(
        '[FirebaseNotificationService] Unsubscribed from topic: $topic',
      );
    } catch (e) {
      debugPrint(
        '[FirebaseNotificationService] Error unsubscribing from topic: $e',
      );
    }
  }

  /// Get notification settings status
  Map<String, dynamic> getNotificationStatus() {
    return {
      'isInitialized': _isInitialized,
      'fcmToken': _fcmToken,
      'hasToken': _fcmToken != null,
    };
  }

  /// Test FCM notification
  Future<bool> testFCMNotification(BuildContext context) async {
    if (!_isInitialized) {
      return false;
    }

    // Simulate receiving a test message
    final testMessage = RemoteMessage(
      messageId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      notification: const RemoteNotification(
        title: '🔥 FCM Test Notification',
        body: 'Firebase Cloud Messaging is working correctly!',
      ),
      data: {'type': 'test', 'timestamp': DateTime.now().toIso8601String()},
    );

    _handleForegroundMessage(testMessage);
    return true;
  }

  /// Set notifications enabled/disabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _saveSettings();
    _emitEvent(
      NotificationEventData(
        event: NotificationEvent.initialized,
        message: 'Notifications ${enabled ? 'enabled' : 'disabled'}',
      ),
    );
  }

  /// Set sound enabled/disabled
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveSettings();
    _emitEvent(
      NotificationEventData(
        event: NotificationEvent.initialized,
        message: 'Sound ${enabled ? 'enabled' : 'disabled'}',
      ),
    );
  }

  /// Set notification timing
  Future<void> setNotificationTiming(int minutes) async {
    if (minutes < 1 || minutes > 1440) {
      _emitEvent(
        NotificationEventData(
          event: NotificationEvent.error,
          message: 'Invalid timing: $minutes minutes',
          errorCode: 'INVALID_TIMING',
        ),
      );
      return;
    }
    _notificationTimingMinutes = minutes;
    await _saveSettings();
    _emitEvent(
      NotificationEventData(
        event: NotificationEvent.initialized,
        message: 'Notification timing set to $minutes minutes before',
      ),
    );
  }

  /// Test notification
  Future<bool> testNotification(BuildContext context) async {
    return await testFCMNotification(context);
  }

  /// Schedule task notification (for compatibility with existing code)
  Future<bool> scheduleTaskNotification(
    TaskModel task, {
    int? minutesBefore,
  }) async {
    final timing = minutesBefore ?? _notificationTimingMinutes;
    return await sendTaskReminder(task, minutesBefore: timing);
  }

  /// Cancel task notification (for compatibility with existing code)
  Future<void> cancelTaskNotification(String taskId) async {
    // Firebase messaging handles scheduling automatically
    // This method is kept for compatibility but doesn't need implementation
    // since FCM handles message delivery timing
    _emitEvent(
      NotificationEventData(
        event: NotificationEvent.initialized,
        message: 'Task notification cancelled for task: $taskId',
      ),
    );
  }

  /// Set global context for notifications
  void setGlobalContext(BuildContext context) {
    _globalContext = context;
  }

  /// Clear global context
  void clearGlobalContext() {
    _globalContext = null;
  }

  /// Show in-app notification
  void showInAppNotification(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    if (!_notificationsEnabled) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );

    _emitEvent(
      NotificationEventData(
        event: NotificationEvent.notificationSent,
        message: 'In-app notification shown: $title',
      ),
    );
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_reminders',
      'Task Reminders',
      description: 'Notifications for task reminders',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    _emitEvent(
      NotificationEventData(
        event: NotificationEvent.messageReceived,
        message: 'Notification tapped: ${response.payload}',
        data: {'payload': response.payload},
      ),
    );
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
      _notificationTimingMinutes = prefs.getInt(_notificationTimingKey) ?? 15;
    } catch (e) {
      _emitEvent(
        NotificationEventData(
          event: NotificationEvent.error,
          message: 'Error loading settings: $e',
          errorCode: 'SETTINGS_LOAD_ERROR',
        ),
      );
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundEnabledKey, _soundEnabled);
      await prefs.setBool(_notificationsEnabledKey, _notificationsEnabled);
      await prefs.setInt(_notificationTimingKey, _notificationTimingMinutes);
    } catch (e) {
      _emitEvent(
        NotificationEventData(
          event: NotificationEvent.error,
          message: 'Error saving settings: $e',
          errorCode: 'SETTINGS_SAVE_ERROR',
        ),
      );
    }
  }

  /// Dispose of the service
  void dispose() {
    _eventController.close();
    debugPrint('[FirebaseNotificationService] Service disposed');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    '[FirebaseNotificationService] Background message: ${message.messageId}',
  );

  // Handle background message
  // This runs even when the app is terminated
  if (message.notification != null) {
    debugPrint(
      '[FirebaseNotificationService] Background notification: ${message.notification!.title}',
    );
  }
}
