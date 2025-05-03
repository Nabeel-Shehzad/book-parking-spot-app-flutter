import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/theme.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _parkingReminders = true;
  bool _reservationConfirmations = true;
  bool _expirationAlerts = true;
  bool _securityAlerts = false;
  bool _promotionalNotifications = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Preferences',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose which notifications you want to receive',
              style: TextStyle(color: AppTheme.subtitleColor),
            ),
            const SizedBox(height: 24),

            // Notification settings switches
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildSwitchTile(
                    'Parking Reminders',
                    'Receive reminders about your parking reservations',
                    _parkingReminders,
                    (value) {
                      setState(() {
                        _parkingReminders = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Parking reminders enabled'
                                : 'Parking reminders disabled',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Reservation Confirmations',
                    'Get notified when your parking spot is reserved',
                    _reservationConfirmations,
                    (value) {
                      setState(() {
                        _reservationConfirmations = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Reservation confirmations enabled'
                                : 'Reservation confirmations disabled',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Expiration Alerts',
                    'Get notified when your parking reservation is about to expire',
                    _expirationAlerts,
                    (value) {
                      setState(() {
                        _expirationAlerts = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Expiration alerts enabled'
                                : 'Expiration alerts disabled',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Security Alerts',
                    'Get notifications about security issues in parking areas',
                    _securityAlerts,
                    (value) {
                      setState(() {
                        _securityAlerts = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Security alerts enabled'
                                : 'Security alerts disabled',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Promotional Notifications',
                    'Receive updates about new features and promotions',
                    _promotionalNotifications,
                    (value) {
                      setState(() {
                        _promotionalNotifications = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Promotional notifications enabled'
                                : 'Promotional notifications disabled',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Notification Delivery',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 16),

            // Notification delivery methods
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You will receive notifications via:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    _buildDeliveryMethodTile(
                      Icons.email_outlined,
                      'Email',
                      appState.currentUser?.email ?? 'Not provided',
                    ),
                    const SizedBox(height: 12),
                    _buildDeliveryMethodTile(
                      Icons.smartphone_outlined,
                      'Push Notifications',
                      'This device',
                    ),
                    const SizedBox(height: 12),
                    _buildDeliveryMethodTile(
                      Icons.notifications_outlined,
                      'In-App Notifications',
                      'Enabled',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Help text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Notification settings are saved automatically when changed. '
                      'You can change these settings at any time.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildDeliveryMethodTile(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.subtitleColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
