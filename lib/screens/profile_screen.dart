import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/user.dart';
import '../utils/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    // Refresh user data when the profile screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
    });
  }

  // Method to refresh user data
  Future<void> _refreshUserData() async {
    final appState = Provider.of<AppState>(context, listen: false);
    // Force a refresh of user data from the AppState
    await appState.refreshCurrentUser();
    // Update the UI
    if (mounted) {
      setState(() {});
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      // Navigate to other screens based on bottom nav selection
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/map');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/reservation');
          break;
        case 3:
          // Already on profile screen
          break;
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<AppState>(context, listen: false).logout();
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('LOG OUT'),
              ),
            ],
          ),
    );
  }

  String _getUserTypeIcon(UserType userType) {
    switch (userType) {
      case UserType.student:
        return '🎓';
      case UserType.faculty:
        return '👨‍🏫';
      case UserType.staff:
        return '👩‍💼';
      case UserType.security:
        return '👮';
      case UserType.visitor:
        return '👋';
      default:
        return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    // If user is not logged in, redirect to login
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Image
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                      child: Text(
                        _getUserTypeIcon(user.userType),
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // User Name
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // User Type
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.userTypeToString,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // User ID
                    _buildInfoRow(Icons.badge_outlined, 'PMU ID', user.id),
                    const Divider(height: 24),
                    // Email
                    _buildInfoRow(Icons.email_outlined, 'Email', user.email),
                    const Divider(height: 24),
                    // Phone (placeholder)
                    _buildInfoRow(
                      Icons.phone_outlined,
                      'Phone',
                      user.phoneNumber ?? 'Not provided',
                      user.phoneNumber == null ? AppTheme.subtitleColor : null,
                    ),
                    const Divider(height: 24),
                    // License Plate (placeholder)
                    _buildInfoRow(
                      Icons.directions_car_outlined,
                      'Vehicle Plate',
                      user.carPlateNumber ?? 'Not provided',
                      user.carPlateNumber == null
                          ? AppTheme.subtitleColor
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Account Settings
            const Text('Account Settings', style: AppTheme.subheadingStyle),
            const SizedBox(height: 12),
            _buildSettingsCard(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              onTap: () async {
                // Navigate to edit profile and wait for result
                final result = await Navigator.pushNamed(
                  context,
                  '/edit_profile',
                );

                // If result is true, user updated their profile
                if (result == true) {
                  // Refresh the user data in the profile screen
                  _refreshUserData();
                }
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
              subtitle: 'Manage your account security',
              onTap: () {
                Navigator.pushNamed(context, '/privacy_security');
              },
            ),
            const SizedBox(height: 24),

            // Support
            const Text('Support', style: AppTheme.subheadingStyle),
            const SizedBox(height: 12),
            _buildSettingsCard(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'FAQs and support resources',
              onTap: () {
                Navigator.pushNamed(context, '/help_center');
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App information and version',
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('LOG OUT'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppTheme.errorColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Reservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, [
    Color? valueColor,
  ]) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.subtitleColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.subtitleColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 16, color: valueColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
