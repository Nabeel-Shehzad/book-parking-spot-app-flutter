import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/theme.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometricAuthEnabled = false;
  bool _locationTrackingEnabled = true;
  bool _dataCollectionEnabled = true;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security section
            const Text('Security', style: AppTheme.subheadingStyle),
            const SizedBox(height: 16),

            // Security settings
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.password_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text(
                      'Change Password',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Update your account password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showChangePasswordDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.fingerprint,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text(
                      'Biometric Authentication',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Use fingerprint or face ID to log in',
                    ),
                    value: _biometricAuthEnabled,
                    onChanged: (value) {
                      setState(() {
                        _biometricAuthEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Biometric authentication enabled'
                                : 'Biometric authentication disabled',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.devices_other_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text(
                      'Connected Devices',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Manage devices connected to your account',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showConnectedDevicesDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Privacy section
            const Text('Privacy', style: AppTheme.subheadingStyle),
            const SizedBox(height: 16),

            // Privacy settings
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text(
                      'Location Services',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Allow app to track your location when finding parking',
                    ),
                    value: _locationTrackingEnabled,
                    onChanged: (value) {
                      setState(() {
                        _locationTrackingEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Location services enabled'
                                : 'Location services disabled',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.analytics_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text(
                      'Usage Data Collection',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Allow collection of anonymous usage data',
                    ),
                    value: _dataCollectionEnabled,
                    onChanged: (value) {
                      setState(() {
                        _dataCollectionEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Usage data collection enabled'
                                : 'Usage data collection disabled',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text(
                      'Delete Account',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    subtitle: const Text(
                      'Permanently delete your account and all data',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppTheme.errorColor,
                    ),
                    onTap: () {
                      _showDeleteAccountDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Legal section
            const Text('Legal', style: AppTheme.subheadingStyle),
            const SizedBox(height: 16),

            // Legal documents
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.description_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text(
                      'Privacy Policy',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showLegalDocumentDialog(context, 'Privacy Policy');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.gavel_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text(
                      'Terms of Service',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showLegalDocumentDialog(context, 'Terms of Service');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.cookie_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text(
                      'Cookie Policy',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showLegalDocumentDialog(context, 'Cookie Policy');
                    },
                  ),
                ],
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
                      'Your privacy is important to us. Settings are saved automatically when changed. '
                      'Contact support for any questions about your data.',
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

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Password'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                      helperText:
                          'At least 8 characters with letters and numbers',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully'),
                      backgroundColor: AppTheme.secondaryColor,
                    ),
                  );
                },
                child: const Text('CHANGE PASSWORD'),
              ),
            ],
          ),
    );
  }

  void _showConnectedDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Connected Devices'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDeviceItem(
                    'Current Device',
                    'Android • Last used: Now',
                    true,
                  ),
                  const Divider(),
                  _buildDeviceItem(
                    'iPhone 13',
                    'iOS • Last used: 3 days ago',
                    false,
                  ),
                  const Divider(),
                  _buildDeviceItem(
                    'Chrome Browser',
                    'Windows • Last used: 1 week ago',
                    false,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('CLOSE'),
              ),
            ],
          ),
    );
  }

  Widget _buildDeviceItem(String name, String details, bool isCurrentDevice) {
    return ListTile(
      title: Row(
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (isCurrentDevice)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Current',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(details),
      trailing:
          isCurrentDevice
              ? null
              : TextButton(
                onPressed: () {
                  // Logic to remove device
                },
                child: const Text('REMOVE'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
              ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Warning: This action cannot be undone. All your data, including profile information and parking history, will be permanently deleted.',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your password to confirm',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deletion request submitted'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('DELETE ACCOUNT'),
              ),
            ],
          ),
    );
  }

  void _showLegalDocumentDialog(BuildContext context, String documentTitle) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(documentTitle),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Last updated: May 1, 2025',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This is a placeholder for the $documentTitle. '
                    'In a real application, this would contain the full legal text. '
                    'The complete document can be viewed on our website.',
                    style: const TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '1. Introduction\n'
                    '2. Information We Collect\n'
                    '3. How We Use Your Information\n'
                    '4. Sharing Your Information\n'
                    '5. Your Rights\n'
                    '6. Security\n'
                    '7. Changes to This Policy\n'
                    '8. Contact Us',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('CLOSE'),
              ),
            ],
          ),
    );
  }
}
