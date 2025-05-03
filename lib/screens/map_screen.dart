import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import '../models/app_state.dart';
import '../models/parking_spot.dart' as models;
import '../models/user.dart'; // Added import for UserType
import '../utils/theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  models.ParkingSpot? _selectedSpot;
  int _selectedIndex = 1;
  bool _showFilters = false;
  final List<String> _filters = ['All', 'Available', 'Reserved', 'Occupied'];
  String _selectedFilter = 'All';
  final Location _location = Location();
  bool _locationPermissionGranted = false;

  // PMU campus coordinates (centered on the main building)
  static const LatLng _pmuCoordinates = LatLng(26.393835, 50.185486);

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();

    // Ensure we load parking spots when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.parkingSpots.isEmpty) {
        appState.fetchParkingSpots();
      } else {
        _updateMarkers();
      }
    });
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check location permission
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _locationPermissionGranted =
          permissionGranted == PermissionStatus.granted;
    });
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
          // Already on map screen
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/reservation');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    }
  }

  void _updateMarkers() {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;

    if (user == null) return;

    setState(() {
      _markers.clear();

      // Filter spots based on selected filter
      var filteredSpots = appState.parkingSpots;
      if (_selectedFilter == 'Available') {
        filteredSpots =
            filteredSpots
                .where((spot) => spot.status == models.ParkingStatus.available)
                .toList();
      } else if (_selectedFilter == 'Reserved') {
        filteredSpots =
            filteredSpots
                .where((spot) => spot.status == models.ParkingStatus.reserved)
                .toList();
      } else if (_selectedFilter == 'Occupied') {
        filteredSpots =
            filteredSpots
                .where((spot) => spot.status == models.ParkingStatus.occupied)
                .toList();
      }

      // Show individual spots instead of grouping by zone
      for (final spot in filteredSpots) {
        // Only show spots that are allowed for the current user
        if (!spot.allowedTypes.contains(user.userType)) continue;

        // Determine marker color based on spot status
        double markerHue;
        if (spot.status == models.ParkingStatus.available) {
          markerHue = BitmapDescriptor.hueGreen; // Green for available
        } else if (spot.status == models.ParkingStatus.reserved) {
          markerHue = BitmapDescriptor.hueRed; // Red for reserved
        } else {
          markerHue = BitmapDescriptor.hueBlue; // Blue for occupied
        }

        // Create marker for the individual spot
        _markers.add(
          Marker(
            markerId: MarkerId(spot.id),
            position: spot.location,
            icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
            infoWindow: InfoWindow(
              title: 'Spot ${spot.id}',
              snippet: 'Zone: ${spot.zone}\nStatus: ${spot.statusText}',
            ),
            onTap: () {
              _showSpotDetails(spot);
            },
          ),
        );
      }
    });
  }

  // Show details for a single spot
  void _showSpotDetails(models.ParkingSpot spot) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final appState = Provider.of<AppState>(context);
        final isAvailable = spot.status == models.ParkingStatus.available;
        final isReservedByUser =
            spot.status == models.ParkingStatus.reserved &&
            spot.reservedBy == appState.currentUser?.id;

        Color statusColor;
        if (spot.status == models.ParkingStatus.available) {
          statusColor = Colors.green;
        } else if (spot.status == models.ParkingStatus.reserved) {
          statusColor = Colors.red;
        } else {
          statusColor = Colors.blue;
        }

        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    isAvailable
                        ? Icons.check_circle
                        : (isReservedByUser ? Icons.bookmark : Icons.block),
                    color: statusColor,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Spot ${spot.id}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Zone: ${spot.zone}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                'Status: ${spot.statusText}',
                style: TextStyle(
                  fontSize: 16,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (spot.status == models.ParkingStatus.reserved)
                Text(
                  'Reserved until: ${spot.reservedUntil?.toString().substring(0, 16) ?? "Unknown"}',
                  style: const TextStyle(fontSize: 14),
                ),
              const SizedBox(height: 24),

              // Action Buttons
              Center(
                child:
                    isAvailable
                        ? ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _reserveSpot(spot);
                          },
                          icon: const Icon(Icons.bookmark_add),
                          label: const Text('RESERVE THIS SPOT'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        )
                        : isReservedByUser
                        ? OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _cancelReservation(spot);
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text('CANCEL RESERVATION'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        )
                        : const SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _reserveSpot(models.ParkingSpot spot) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.reserveSpot(spot);

    if (success) {
      _updateMarkers();
      Navigator.pop(context); // Close the bottom sheet

      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully reserved spot ${spot.id}'),
            backgroundColor: AppTheme.secondaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reserve spot. Please try again.'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _cancelReservation(models.ParkingSpot spot) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.cancelReservation(spot);

    if (success) {
      _updateMarkers();
      Navigator.pop(context); // Close the bottom sheet

      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reservation for spot ${spot.id} canceled'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel reservation. Please try again.'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showGenerateDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Generate Parking Data'),
          content: const Text(
            'This will create realistic parking spot data in Firebase for testing. Existing parking data will be replaced. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Generating parking data...'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Call the method to generate parking data
                final appState = Provider.of<AppState>(context, listen: false);
                await appState.populateFirebaseWithParkingData();

                // Refresh markers after data generation
                _updateMarkers();

                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Parking data generated successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
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
      appBar: AppBar(
        title: const Text('Parking Map'),
        actions: [
          // Add admin button to populate Firebase with parking data
          if (user.userType == UserType.security ||
              user.userType == UserType.staff)
            IconButton(
              icon: const Icon(Icons.data_array),
              tooltip: 'Generate Parking Data',
              onPressed: () {
                _showGenerateDataDialog();
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _updateMarkers();
            },
            initialCameraPosition: const CameraPosition(
              target: _pmuCoordinates,
              zoom: 16.0,
            ),
            markers: _markers,
            myLocationEnabled: _locationPermissionGranted,
            myLocationButtonEnabled: _locationPermissionGranted,
            mapToolbarEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: false,
          ),

          // Filter chips
          if (_showFilters)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    children:
                        _filters.map((filter) {
                          return ChoiceChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                                _updateMarkers();
                              }
                            },
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),

          // Loading indicator
          if (appState.isLoading)
            const Center(child: CircularProgressIndicator()),

          // Permission error message
          if (!_locationPermissionGranted)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_off, color: Colors.red),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Location permission is required to show your position on the map',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _checkLocationPermission();
                        },
                        child: const Text('Grant'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Legend
          Positioned(
            bottom: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem(Colors.green, 'Available'),
                    const SizedBox(height: 8),
                    _buildLegendItem(Colors.red, 'Reserved'),
                    const SizedBox(height: 8),
                    _buildLegendItem(Colors.blue, 'Occupied'),
                  ],
                ),
              ),
            ),
          ),
        ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reset the map view to PMU coordinates
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_pmuCoordinates, 16.0),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.location_searching),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
