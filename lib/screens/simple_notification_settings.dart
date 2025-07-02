import 'package:flutter/material.dart';
import 'package:task_remider_app/const/color.dart';
import 'package:task_remider_app/services/firebase_notification_service.dart';

class SimpleNotificationSettingsScreen extends StatefulWidget {
  const SimpleNotificationSettingsScreen({super.key});

  @override
  State<SimpleNotificationSettingsScreen> createState() =>
      _SimpleNotificationSettingsScreenState();
}

class _SimpleNotificationSettingsScreenState
    extends State<SimpleNotificationSettingsScreen> {
  final FirebaseNotificationService _notificationService =
      FirebaseNotificationService();

  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  int _notificationTimingMinutes = 15;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadSettings();
  }

  Future<void> _initializeAndLoadSettings() async {
    // Initialize notification service if not already done
    if (!_notificationService.isInitialized) {
      await _notificationService.initialize();
    }

    // Load current settings
    setState(() {
      _soundEnabled = _notificationService.soundEnabled;
      _notificationsEnabled = _notificationService.notificationsEnabled;
      _notificationTimingMinutes =
          _notificationService.notificationTimingMinutes;
      _isLoading = false;
    });
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Configure your notification preferences',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Enable/Disable All Notifications
                  _buildToggleCard(
                    title: 'Enable Notifications',
                    subtitle: 'Turn on/off all notifications',
                    icon: Icons.notifications,
                    value: _notificationsEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      await _notificationService.setNotificationsEnabled(value);
                      _showSuccessMessage(
                        'Notifications ${value ? 'enabled' : 'disabled'}',
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Sound Notifications Toggle
                  _buildToggleCard(
                    title: 'Sound Notifications',
                    subtitle: 'Play sound when notifications appear',
                    icon: Icons.volume_up,
                    value: _soundEnabled,
                    enabled: _notificationsEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _soundEnabled = value;
                      });
                      await _notificationService.setSoundEnabled(value);
                      _showSuccessMessage(
                        'Sound ${value ? 'enabled' : 'disabled'}',
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Notification Timing Selection
                  _buildTimingCard(),

                  const SizedBox(height: 40),

                  // Test Notification Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _notificationsEnabled
                          ? _testNotification
                          : null,
                      icon: const Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Test Notification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _notificationsEnabled
                            ? primaryColor
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Test Firebase Notification Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _notificationsEnabled
                          ? _testFirebaseNotification
                          : null,
                      icon: const Icon(Icons.cloud, color: Colors.white),
                      label: const Text(
                        'Test Firebase Notification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _notificationsEnabled
                            ? Colors.orange
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Notification Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Notification Info',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Notifications will be sent $_notificationTimingMinutes minutes before each task deadline\n'
                          '• When you create a task, notification will be automatically scheduled\n'
                          '• The notification message will show actual time remaining to deadline\n'
                          '• Make sure to allow notification permissions\n'
                          '• Sound depends on your device settings',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom padding to ensure content is not cut off
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: enabled
                  ? primaryColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: enabled ? primaryColor : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: enabled ? Colors.black87 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: enabled ? Colors.grey : Colors.grey.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTimingCard() {
    // Predefined timing options
    final timingOptions = [
      {'minutes': 5, 'label': '5 minutes before'},
      {'minutes': 10, 'label': '10 minutes before'},
      {'minutes': 15, 'label': '15 minutes before'},
      {'minutes': 30, 'label': '30 minutes before'},
      {'minutes': 60, 'label': '1 hour before'},
      {'minutes': 120, 'label': '2 hours before'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _notificationsEnabled
            ? Colors.white
            : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: _notificationsEnabled
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _notificationsEnabled
                      ? primaryColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.schedule,
                  color: _notificationsEnabled ? primaryColor : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Timing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _notificationsEnabled
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'When to send notifications before task time',
                      style: TextStyle(
                        fontSize: 14,
                        color: _notificationsEnabled
                            ? Colors.grey
                            : Colors.grey.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: timingOptions.map((option) {
              final minutes = option['minutes'] as int;
              final label = option['label'] as String;
              final isSelected = _notificationTimingMinutes == minutes;

              return GestureDetector(
                onTap: _notificationsEnabled
                    ? () async {
                        setState(() {
                          _notificationTimingMinutes = minutes;
                        });
                        await _notificationService.setNotificationTiming(
                          minutes,
                        );
                        _showSuccessMessage(
                          'Notification timing set to $label',
                        );
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : (_notificationsEnabled
                              ? Colors.grey.shade200
                              : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (_notificationsEnabled
                                ? Colors.black87
                                : Colors.grey),
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _testNotification() async {
    final success = await _notificationService.testNotification(context);
    if (success) {
      _showSuccessMessage(
        'Test notification sent! Check your notification panel.',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to send test notification. Please check permissions.',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _testFirebaseNotification() async {
    final success = await _notificationService.testFCMNotification(context);
    if (mounted) {
      if (success) {
        _showSuccessMessage(
          'Firebase notification sent! FCM is working correctly.',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to send Firebase notification. Please check FCM setup.',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
