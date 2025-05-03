import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/parking_spot.dart';
import '../utils/theme.dart';
import '../widgets/parking_status_card.dart';
import '../widgets/recent_activity_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch parking spots when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).fetchParkingSpots();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to other screens based on bottom nav selection
    switch (index) {
      case 0:
        // Already on home screen
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/reservation');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
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

    // Count parking spots by status
    final availableSpots =
        appState.parkingSpots
            .where(
              (spot) =>
                  spot.status == ParkingStatus.available &&
                  spot.allowedTypes.contains(user.userType),
            )
            .length;

    final occupiedSpots =
        appState.parkingSpots
            .where((spot) => spot.status == ParkingStatus.occupied)
            .length;

    final reservedSpots =
        appState.parkingSpots
            .where((spot) => spot.status == ParkingStatus.reserved)
            .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PMU Park'),
        // Removed notification icon from actions
      ),
      body:
          appState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () async {
                  await appState.fetchParkingSpots();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome message
                      Text(
                        'Welcome back, ${user.name.split(' ').first}!',
                        style: AppTheme.headingStyle.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find and reserve your perfect parking spot',
                        style: AppTheme.captionStyle,
                      ),
                      const SizedBox(height: 24),

                      // Quick Actions
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildQuickAction(
                            context,
                            icon: Icons.search,
                            label: 'Find Spot',
                            onTap: () {
                              Navigator.pushNamed(context, '/map');
                            },
                          ),
                          _buildQuickAction(
                            context,
                            icon: Icons.calendar_today,
                            label: 'Reserve',
                            onTap: () {
                              Navigator.pushNamed(context, '/reservation');
                            },
                          ),
                          // Removed QR code scanner and Report buttons
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Parking Status
                      const Text(
                        'Parking Status',
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ParkingStatusCard(
                              status: 'Available',
                              count: availableSpots,
                              color: AppTheme.secondaryColor,
                              icon: Icons.check_circle_outline,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ParkingStatusCard(
                              status: 'Occupied',
                              count: occupiedSpots,
                              color: AppTheme.errorColor,
                              icon: Icons.do_not_disturb,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ParkingStatusCard(
                              status: 'Reserved',
                              count: reservedSpots,
                              color: AppTheme.accentColor,
                              icon: Icons.bookmark_outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // User's Reservations
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Reservations',
                            style: AppTheme.subheadingStyle,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/reservation');
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      appState.reservedSpots.isEmpty
                          ? Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.car_rental,
                                    size: 48,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No active reservations',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Reserve a parking spot to see it here',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppTheme.subtitleColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/map');
                                    },
                                    child: const Text('FIND A SPOT'),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: appState.reservedSpots.length,
                            itemBuilder: (context, index) {
                              final spot = appState.reservedSpots[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.directions_car,
                                      color: AppTheme.accentColor,
                                    ),
                                  ),
                                  title: Text(
                                    'Spot ${spot.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    spot.zone,
                                    style: const TextStyle(
                                      color: AppTheme.subtitleColor,
                                    ),
                                  ),
                                  trailing: OutlinedButton(
                                    onPressed: () {
                                      // Navigate to spot on map
                                      Navigator.pushNamed(context, '/map');
                                    },
                                    child: const Text('NAVIGATE'),
                                  ),
                                ),
                              );
                            },
                          ),
                      const SizedBox(height: 24),

                      // Recent Activity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Activity',
                            style: AppTheme.subheadingStyle,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/reservation');
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Fetch activity data if empty and not currently loading
                      Builder(
                        builder: (context) {
                          if (appState.recentActivity.isEmpty &&
                              !appState.isLoading) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              appState.fetchRecentActivity();
                            });
                          }

                          if (appState.recentActivity.isEmpty) {
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 48,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No recent activity',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Your parking activities will show up here',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppTheme.subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Column(
                            children:
                                appState.recentActivity.map((activity) {
                                  // Convert string icon name to actual icon
                                  IconData activityIcon;
                                  switch (activity['icon']) {
                                    case 'bookmark_added':
                                      activityIcon = Icons.bookmark_added;
                                      break;
                                    case 'local_parking':
                                      activityIcon = Icons.local_parking;
                                      break;
                                    case 'timer_off':
                                      activityIcon = Icons.timer_off;
                                      break;
                                    case 'cancel':
                                      activityIcon = Icons.cancel_outlined;
                                      break;
                                    default:
                                      activityIcon = Icons.history;
                                  }

                                  // Convert string color name to actual color
                                  Color activityColor;
                                  switch (activity['color']) {
                                    case 'primary':
                                      activityColor =
                                          Theme.of(context).primaryColor;
                                      break;
                                    case 'accent':
                                      activityColor = AppTheme.accentColor;
                                      break;
                                    case 'error':
                                      activityColor = AppTheme.errorColor;
                                      break;
                                    default:
                                      activityColor = AppTheme.secondaryColor;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: RecentActivityCard(
                                      title: activity['title'],
                                      description: activity['description'],
                                      time: activity['time'],
                                      icon: activityIcon,
                                      color: activityColor,
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
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

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 22,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
