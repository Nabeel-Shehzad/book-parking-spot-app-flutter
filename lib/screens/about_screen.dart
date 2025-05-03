import 'package:flutter/material.dart';
// Import commented out until package is installed
// import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import '../utils/theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = 'Loading...';
  String _buildNumber = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      // Using hardcoded values for now until package_info_plus is installed
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _version = '1.0.0';
        _buildNumber = '100';
        _isLoading = false;
      });

      // Uncomment this code after running 'flutter pub get':
      // final packageInfo = await PackageInfo.fromPlatform();
      // setState(() {
      //   _version = packageInfo.version;
      //   _buildNumber = packageInfo.buildNumber;
      //   _isLoading = false;
      // });
    } catch (e) {
      setState(() {
        _version = 'Error';
        _buildNumber = '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'P',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App name and version
                    const Text(
                      'PMU Park',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version $_version ($_buildNumber)',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // App description
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'PMU Park is a parking management system for Prince Mohammad Bin Fahd University. '
                        'The app helps students, faculty, and staff find, reserve, and manage parking spots across campus.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Features section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Features', style: AppTheme.subheadingStyle),
                    ),
                    const SizedBox(height: 16),
                    _buildFeaturesList(),
                    const SizedBox(height: 32),

                    // Developer info
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Development',
                        style: AppTheme.subheadingStyle,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDeveloperInfo(context),
                    const SizedBox(height: 32),

                    // Legal links
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Legal', style: AppTheme.subheadingStyle),
                    ),
                    const SizedBox(height: 16),
                    _buildLegalLinks(),
                    const SizedBox(height: 32),

                    // Copyright notice
                    const Text(
                      '© 2025 Prince Mohammad Bin Fahd University',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.subtitleColor,
                      ),
                    ),
                    const Text(
                      'All rights reserved',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.map_outlined, 'title': 'Interactive Campus Map'},
      {
        'icon': Icons.calendar_today_outlined,
        'title': 'Parking Reservation System',
      },
      {
        'icon': Icons.directions_car_outlined,
        'title': 'Real-time Parking Availability',
      },
      {'icon': Icons.notifications_outlined, 'title': 'Reservation Reminders'},
      {'icon': Icons.history_outlined, 'title': 'Parking History'},
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children:
              features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(
                        feature['icon'] as IconData,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          feature['title'] as String,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildDeveloperInfo(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Developed by',
              style: TextStyle(fontSize: 14, color: AppTheme.subtitleColor),
            ),
            const SizedBox(height: 8),
            const Text(
              'PMU IT Department',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  color: AppTheme.subtitleColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'it.support@pmu.edu.sa',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  color: AppTheme.subtitleColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text('+966 13 849 9346', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(
                  icon: Icons.language,
                  label: 'Website',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening PMU website'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _buildSocialButton(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening Facebook page'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _buildSocialButton(
                  icon: Icons.integration_instructions_outlined,
                  label: 'GitHub',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening GitHub repository'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalLinks() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening Terms of Service'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening Privacy Policy'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Open Source Licenses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening Open Source Licenses'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
