import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'user.dart';
import 'parking_spot.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  List<ParkingSpot> _parkingSpots = [];
  List<ParkingSpot> _reservedSpots = [];
  List<Map<String, dynamic>> _reservationHistory = [];
  List<Map<String, dynamic>> _recentActivity = [];
  bool _isLoading = false;
  final Random _random = Random();

  // Firebase instances
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getters
  User? get currentUser => _currentUser;
  List<ParkingSpot> get parkingSpots => _parkingSpots;
  List<ParkingSpot> get reservedSpots => _reservedSpots;
  List<Map<String, dynamic>> get reservationHistory => _reservationHistory;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;
  bool get isLoading => _isLoading;

  // Authentication
  Future<bool> login(String id, String password) async {
    _isLoading = true;
    notifyListeners();

    // First check if these are valid demo credentials
    if (_isValidCredentials(id, password)) {
      print('Valid credentials detected for demo account: $id');
      // Set the current user based on ID
      switch (id) {
        case 'student123':
          _currentUser = User(
            id: id,
            name: 'Ahmed Student',
            email: 'ahmed.student@example.com',
            userType: UserType.student,
            phoneNumber: '+966 50 123 4567',
          );
          _createFirebaseUser(id, password, _currentUser!);
          break;
        case 'faculty123':
          _currentUser = User(
            id: id,
            name: 'Dr. Sarah Faculty',
            email: 'sarah.faculty@example.com',
            userType: UserType.faculty,
            phoneNumber: '+966 55 987 6543',
            carPlateNumber: 'PMU 1234',
          );
          _createFirebaseUser(id, password, _currentUser!);
          break;
        case 'staff123':
          _currentUser = User(
            id: id,
            name: 'Mohammed Staff',
            email: 'mohammed.staff@example.com',
            userType: UserType.staff,
            phoneNumber: '+966 56 555 1234',
            carPlateNumber: 'PMU 5678',
          );
          _createFirebaseUser(id, password, _currentUser!);
          break;
        case 'security123':
          _currentUser = User(
            id: id,
            name: 'Abdullah Security',
            email: 'abdullah.security@example.com',
            userType: UserType.security,
            phoneNumber: '+966 58 777 8888',
          );
          _createFirebaseUser(id, password, _currentUser!);
          break;
        case 'visitor123':
          _currentUser = User(
            id: id,
            name: 'Visitor User',
            email: 'visitor@example.com',
            userType: UserType.visitor,
          );
          _createFirebaseUser(id, password, _currentUser!);
          break;
        default:
          _currentUser = null;
      }

      if (_currentUser != null) {
        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', id);

        // Load parking spots
        await fetchParkingSpots();

        _isLoading = false;
        notifyListeners();
        return true;
      }
    }

    // If not valid demo credentials, try Firebase authentication
    try {
      // For the demo app, we'll use email+password auth with Firebase
      // Convert ID to email format for Firebase Auth
      final email = '$id@pmu-parking.app';

      // Try to sign in with Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Get user data from Firestore
        final userDoc =
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;

          // Create User object from Firestore data
          _currentUser = User(
            id: id,
            name: userData['name'] ?? 'User',
            email: userData['email'] ?? email,
            userType: _getUserTypeFromString(userData['userType'] ?? 'student'),
            phoneNumber: userData['phoneNumber'],
            carPlateNumber: userData['carPlateNumber'],
          );

          // Save login state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', id);

          // Load parking spots from Firestore
          await fetchParkingSpots();

          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      // If we get here, Firebase authentication failed
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Firebase authentication error: $e');
      // Authentication failed through both methods
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      // Ignore errors on signout
    }

    // Clear user data
    _currentUser = null;
    _parkingSpots = [];
    _reservedSpots = [];

    // Clear saved login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');

    _isLoading = false;
    notifyListeners();
  }

  // Helper method to convert string to UserType
  UserType _getUserTypeFromString(String userType) {
    switch (userType.toLowerCase()) {
      case 'student':
        return UserType.student;
      case 'faculty':
        return UserType.faculty;
      case 'staff':
        return UserType.staff;
      case 'security':
        return UserType.security;
      case 'visitor':
        return UserType.visitor;
      default:
        return UserType.student;
    }
  }

  // Helper method to create a Firebase user for demo
  Future<void> _createFirebaseUser(
    String id,
    String password,
    User user,
  ) async {
    try {
      // Create email from ID
      final email = '$id@pmu-parking.app';

      // Check if user already exists
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(email);
        if (methods.isNotEmpty) {
          // User already exists, no need to create
          return;
        }
      } catch (e) {
        // Ignore errors, assume user doesn't exist
      }

      // Create the user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': id,
        'name': user.name,
        'email': email,
        'userType': user.userTypeToString.toLowerCase(),
        'phoneNumber': user.phoneNumber,
        'carPlateNumber': user.carPlateNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Ignore errors for demo
      print('Error creating Firebase user: $e');
    }
  }

  bool _isValidCredentials(String id, String password) {
    // For demo purposes, all accounts use 'password' as password
    final validIds = [
      'student123',
      'faculty123',
      'staff123',
      'security123',
      'visitor123',
    ];
    return validIds.contains(id) && password == 'password';
  }

  // Parking Spots
  Future<void> fetchParkingSpots() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to get parking spots from Firestore
      final spotsCollection = await _firestore.collection('parkingSpots').get();

      if (spotsCollection.docs.isNotEmpty) {
        _parkingSpots = [];

        for (final doc in spotsCollection.docs) {
          final data = doc.data();
          final allowedTypesRaw = data['allowedTypes'] as List<dynamic>;
          final allowedTypes =
              allowedTypesRaw
                  .map((type) => _getUserTypeFromString(type.toString()))
                  .toList();

          // Convert GeoPoint to LatLng
          final geoPoint = data['location'] as GeoPoint;

          final spot = ParkingSpot(
            id: doc.id,
            zone: data['zone'] ?? 'Unknown',
            status: _getParkingStatusFromString(data['status'] ?? 'available'),
            allowedTypes: allowedTypes,
            location: LatLng(geoPoint.latitude, geoPoint.longitude),
            reservedBy: data['reservedBy'],
            reservedUntil:
                data['reservedUntil'] != null
                    ? (data['reservedUntil'] as Timestamp).toDate()
                    : null,
          );

          _parkingSpots.add(spot);

          // Add to reserved spots if reserved by current user
          if (spot.status == ParkingStatus.reserved &&
              spot.reservedBy == currentUser?.id) {
            _reservedSpots.add(spot);
          }
        }
      } else {
        // If no parking spots found in Firestore, generate mock data
        _generateMockParkingSpots();

        // Save generated spots to Firestore for future use
        for (final spot in _parkingSpots) {
          await _firestore.collection('parkingSpots').doc(spot.id).set({
            'zone': spot.zone,
            'status': _getParkingStatusString(spot.status),
            'allowedTypes':
                spot.allowedTypes
                    .map((type) => type.toString().split('.').last)
                    .toList(),
            'location': GeoPoint(
              spot.location.latitude,
              spot.location.longitude,
            ),
            'reservedBy': spot.reservedBy,
            'reservedUntil': spot.reservedUntil,
          });
        }
      }
    } catch (e) {
      // If Firestore fails, fall back to mock data
      print('Error fetching parking spots: $e');
      _generateMockParkingSpots();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> reserveSpot(ParkingSpot spot) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Update spot in Firestore
      final reservedUntil = DateTime.now().add(const Duration(hours: 3));

      await _firestore.collection('parkingSpots').doc(spot.id).update({
        'status': 'reserved',
        'reservedBy': _currentUser?.id,
        'reservedUntil': reservedUntil,
      });

      // Update local state
      final index = _parkingSpots.indexWhere((s) => s.id == spot.id);
      if (index != -1) {
        final updatedSpot = spot.copyWith(
          status: ParkingStatus.reserved,
          reservedBy: _currentUser?.id,
          reservedUntil: reservedUntil,
        );

        _parkingSpots[index] = updatedSpot;
        _reservedSpots.add(updatedSpot);

        // Add reservation to user activity
        final activityRef = _firestore.collection('userActivity').doc();
        await activityRef.set({
          'userId': _currentUser!.id,
          'title': 'Parking Reserved',
          'description': 'You reserved spot ${spot.id} in ${spot.zone}',
          'timestamp': FieldValue.serverTimestamp(),
          'activityType': 'reservation',
        });

        // Refresh recent activity
        await fetchRecentActivity();

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error reserving spot: $e');

      // Fall back to local update if Firestore fails
      final index = _parkingSpots.indexWhere((s) => s.id == spot.id);
      if (index != -1) {
        final updatedSpot = spot.copyWith(
          status: ParkingStatus.reserved,
          reservedBy: _currentUser?.id,
          reservedUntil: DateTime.now().add(const Duration(hours: 3)),
        );

        _parkingSpots[index] = updatedSpot;
        _reservedSpots.add(updatedSpot);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> cancelReservation(ParkingSpot spot) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Update spot in Firestore
      await _firestore.collection('parkingSpots').doc(spot.id).update({
        'status': 'available',
        'reservedBy': null,
        'reservedUntil': null,
      });

      // Update local state
      final index = _parkingSpots.indexWhere((s) => s.id == spot.id);
      if (index != -1) {
        final updatedSpot = spot.copyWith(
          status: ParkingStatus.available,
          reservedBy: null,
          reservedUntil: null,
        );

        _parkingSpots[index] = updatedSpot;
        _reservedSpots.removeWhere((s) => s.id == spot.id);

        // Add cancellation to history
        await addToReservationHistory(spot, 'Canceled');

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error canceling reservation: $e');

      // Fall back to local update if Firestore fails
      final index = _parkingSpots.indexWhere((s) => s.id == spot.id);
      if (index != -1) {
        final updatedSpot = spot.copyWith(
          status: ParkingStatus.available,
          reservedBy: null,
          reservedUntil: null,
        );

        _parkingSpots[index] = updatedSpot;
        _reservedSpots.removeWhere((s) => s.id == spot.id);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? carPlateNumber,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Get current Firebase user
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        print(
          'Error updating profile: No Firebase user found. Using local update only.',
        );
        // Fall back to local-only update if no Firebase user
        _currentUser = User(
          id: _currentUser!.id,
          name: name ?? _currentUser!.name,
          email: _currentUser!.email,
          userType: _currentUser!.userType,
          phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
          carPlateNumber: carPlateNumber ?? _currentUser!.carPlateNumber,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Prepare data to update
      final Map<String, dynamic> updateData = {
        'id':
            _currentUser!
                .id, // Include ID in case we need to create the document
        'email':
            _currentUser!
                .email, // Include email in case we need to create the document
        'userType':
            _currentUser!.userTypeToString
                .toLowerCase(), // Include user type in case we need to create the document
        'updatedAt':
            FieldValue.serverTimestamp(), // Add timestamp for when the update occurred
      };

      if (name != null && name.isNotEmpty) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (carPlateNumber != null) updateData['carPlateNumber'] = carPlateNumber;

      print('Updating Firestore document for user ID: ${_currentUser!.id}');

      // Try to create a document with user ID as the document ID
      final docRef = _firestore.collection('users').doc(_currentUser!.id);

      // Check if document exists
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Document exists, so update it
        print('Updating existing document at users/${_currentUser!.id}');
        await docRef.update(updateData);
        print('Update successful');
      } else {
        // Document doesn't exist, so create it
        print('Creating new document at users/${_currentUser!.id}');
        await docRef.set(updateData, SetOptions(merge: true));
        print('Document creation successful');
      }

      // Update local user object
      _currentUser = User(
        id: _currentUser!.id,
        name: name ?? _currentUser!.name,
        email: _currentUser!.email,
        userType: _currentUser!.userType,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        carPlateNumber: carPlateNumber ?? _currentUser!.carPlateNumber,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating user profile in Firestore: $e');

      // For demo, update local user even if Firestore fails
      _currentUser = User(
        id: _currentUser!.id,
        name: name ?? _currentUser!.name,
        email: _currentUser!.email,
        userType: _currentUser!.userType,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        carPlateNumber: carPlateNumber ?? _currentUser!.carPlateNumber,
      );

      _isLoading = false;
      notifyListeners();
      return true; // Return true even if Firestore fails to update the UI
    }
  }

  // Refresh current user data from Firestore
  Future<void> refreshCurrentUser() async {
    if (_currentUser == null) return;

    try {
      print('Refreshing user data for: ${_currentUser!.id}');

      // Get user data from Firestore
      final docRef = _firestore.collection('users').doc(_currentUser!.id);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;

        // Update the local user object with the latest data from Firestore
        _currentUser = User(
          id: _currentUser!.id,
          name: userData['name'] ?? _currentUser!.name,
          email: userData['email'] ?? _currentUser!.email,
          userType: _currentUser!.userType, // User type doesn't change
          phoneNumber: userData['phoneNumber'] ?? _currentUser!.phoneNumber,
          carPlateNumber:
              userData['carPlateNumber'] ?? _currentUser!.carPlateNumber,
        );

        print('User data refreshed successfully');
        notifyListeners();
      } else {
        print('User document not found in Firestore');
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  // Helper method to convert string to ParkingStatus
  ParkingStatus _getParkingStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return ParkingStatus.available;
      case 'occupied':
        return ParkingStatus.occupied;
      case 'reserved':
        return ParkingStatus.reserved;
      default:
        return ParkingStatus.available;
    }
  }

  // Helper method to convert ParkingStatus to string
  String _getParkingStatusString(ParkingStatus status) {
    switch (status) {
      case ParkingStatus.available:
        return 'available';
      case ParkingStatus.occupied:
        return 'occupied';
      case ParkingStatus.reserved:
        return 'reserved';
    }
  }

  void _generateMockParkingSpots() {
    // ... existing mock data generation code ...
  }

  // Method to populate Firebase with realistic parking data
  Future<void> populateFirebaseWithParkingData() async {
    print('Populating Firebase with parking spot data...');
    _isLoading = true;
    notifyListeners();

    try {
      // Clear existing parking spots collection first
      final existingSpots = await _firestore.collection('parkingSpots').get();
      for (final doc in existingSpots.docs) {
        await doc.reference.delete();
      }

      // Define areas/zones in the PMU campus
      final zones = [
        'Academic Building - Block A',
        'Academic Building - Block B',
        'Academic Building - Block C',
        'Faculty Parking',
        'Administration Building',
        'Library Parking',
        'Sports Complex',
        'Student Center',
        'Visitor Parking',
      ];

      // Use the exact PMU coordinates as provided
      final baseLatitude = 26.144497; // PMU exact latitude
      final baseLongitude = 50.090961; // PMU exact longitude

      int spotCounter = 0;
      final spots = <ParkingSpot>[];

      // Create spots for each zone
      for (int zoneIndex = 0; zoneIndex < zones.length; zoneIndex++) {
        final zone = zones[zoneIndex];
        final spotCount = 10 + _random.nextInt(15); // 10-25 spots per zone

        // Determine allowed user types based on zone
        List<UserType> allowedTypes = [];
        if (zone.contains('Faculty')) {
          allowedTypes = [UserType.faculty, UserType.staff];
        } else if (zone.contains('Administration')) {
          allowedTypes = [UserType.staff, UserType.faculty];
        } else if (zone.contains('Visitor')) {
          allowedTypes = [
            UserType.visitor,
            UserType.student,
            UserType.faculty,
            UserType.staff,
          ];
        } else {
          allowedTypes = [UserType.student, UserType.faculty, UserType.staff];
        }

        // Set different base coordinates for each zone to spread them out
        // Use smaller offset values to keep spots close together within the campus
        final zoneLatitude = baseLatitude + (zoneIndex * 0.0003);
        final zoneLongitude = baseLongitude + (zoneIndex * 0.0003);

        // Create spots for this zone
        for (int i = 0; i < spotCount; i++) {
          spotCounter++;
          final spotId =
              '${zone.substring(0, 1)}${spotCounter.toString().padLeft(3, '0')}';

          // Set all spots to available status
          final status = ParkingStatus.available;

          // Add some randomness to spot locations, but keep them close
          final spotLatitude = zoneLatitude + (_random.nextDouble() * 0.0002);
          final spotLongitude = zoneLongitude + (_random.nextDouble() * 0.0002);

          // Create the spot
          final spot = ParkingSpot(
            id: spotId,
            zone: zone,
            status: status,
            allowedTypes: allowedTypes,
            location: LatLng(spotLatitude, spotLongitude),
            reservedBy: null,
            reservedUntil: null,
          );

          spots.add(spot);

          // Save to Firestore
          await _firestore.collection('parkingSpots').doc(spotId).set({
            'zone': spot.zone,
            'status': _getParkingStatusString(spot.status),
            'allowedTypes':
                spot.allowedTypes
                    .map(
                      (type) => type.toString().split('.').last.toLowerCase(),
                    )
                    .toList(),
            'location': GeoPoint(
              spot.location.latitude,
              spot.location.longitude,
            ),
            'reservedBy': spot.reservedBy,
            'reservedUntil': spot.reservedUntil,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Update local state
      _parkingSpots = spots;
      _reservedSpots = [];

      print(
        'Successfully populated Firebase with ${spots.length} available parking spots at PMU coordinates (26.144497, 50.090961)',
      );
    } catch (e) {
      print('Error populating Firebase with parking data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch reservation history for current user
  Future<void> fetchReservationHistory() async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Query the reservation history collection for the current user
      final historySnapshot =
          await _firestore
              .collection('reservationHistory')
              .where('userId', isEqualTo: _currentUser!.id)
              .orderBy('timestamp', descending: true)
              .limit(20) // Limit to 20 most recent entries
              .get();

      _reservationHistory = [];

      if (historySnapshot.docs.isNotEmpty) {
        for (final doc in historySnapshot.docs) {
          final data = doc.data();

          // Convert Firestore timestamp to DateTime
          final timestamp = (data['timestamp'] as Timestamp).toDate();

          _reservationHistory.add({
            'id': data['spotId'],
            'zone': data['zone'],
            'date': timestamp,
            'duration': data['duration'] ?? '3 hours',
            'status': data['status'],
          });
        }
      } else {
        // If no history exists yet, generate some mock data for demo
        _generateMockReservationHistory();
      }

      // Also load recent activity
      await fetchRecentActivity();
    } catch (e) {
      print('Error fetching reservation history: $e');
      // Generate mock data if there's an error
      _generateMockReservationHistory();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch recent user activity
  Future<void> fetchRecentActivity() async {
    if (_currentUser == null) return;

    try {
      // Query the user activity collection
      final activitySnapshot =
          await _firestore
              .collection('userActivity')
              .where('userId', isEqualTo: _currentUser!.id)
              .orderBy('timestamp', descending: true)
              .limit(5) // Show only the 5 most recent activities
              .get();

      _recentActivity = [];

      if (activitySnapshot.docs.isNotEmpty) {
        for (final doc in activitySnapshot.docs) {
          final data = doc.data();

          // Convert Firestore timestamp to DateTime
          final timestamp = (data['timestamp'] as Timestamp).toDate();
          final now = DateTime.now();
          final difference = now.difference(timestamp);

          // Format the time difference for display
          String timeAgo;
          if (difference.inMinutes < 60) {
            timeAgo = '${difference.inMinutes} minutes ago';
          } else if (difference.inHours < 24) {
            timeAgo = '${difference.inHours} hours ago';
          } else if (difference.inDays < 30) {
            timeAgo = '${difference.inDays} days ago';
          } else {
            timeAgo = '${difference.inDays ~/ 30} months ago';
          }

          _recentActivity.add({
            'title': data['title'],
            'description': data['description'],
            'time': timeAgo,
            'timestamp': timestamp,
            'icon':
                data['activityType'] == 'reservation'
                    ? 'bookmark_added'
                    : (data['activityType'] == 'cancellation'
                        ? 'cancel'
                        : (data['activityType'] == 'expiry'
                            ? 'timer_off'
                            : 'local_parking')),
            'color':
                data['activityType'] == 'reservation'
                    ? 'accent'
                    : (data['activityType'] == 'cancellation'
                        ? 'error'
                        : (data['activityType'] == 'expiry'
                            ? 'error'
                            : 'primary')),
          });
        }
      } else {
        // If no activity exists yet, generate some mock data for demo
        _generateMockRecentActivity();
      }
    } catch (e) {
      print('Error fetching recent activity: $e');
      // Generate mock data if there's an error
      _generateMockRecentActivity();
    }

    notifyListeners();
  }

  // Add a completed reservation to history
  Future<void> addToReservationHistory(ParkingSpot spot, String status) async {
    if (_currentUser == null) return;

    try {
      // Create history record
      final historyRef = _firestore.collection('reservationHistory').doc();
      await historyRef.set({
        'userId': _currentUser!.id,
        'spotId': spot.id,
        'zone': spot.zone,
        'timestamp': FieldValue.serverTimestamp(),
        'duration': '3 hours',
        'status': status, // 'Completed', 'Canceled', or 'Expired'
      });

      // Create activity record
      String activityType = 'parking';
      String title = 'Parking Used';
      String description = 'You parked at spot ${spot.id} in ${spot.zone}';

      if (status == 'Canceled') {
        activityType = 'cancellation';
        title = 'Reservation Canceled';
        description = 'You canceled reservation for spot ${spot.id}';
      } else if (status == 'Expired') {
        activityType = 'expiry';
        title = 'Reservation Expired';
        description = 'Your reservation for spot ${spot.id} expired';
      }

      final activityRef = _firestore.collection('userActivity').doc();
      await activityRef.set({
        'userId': _currentUser!.id,
        'title': title,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'activityType': activityType,
      });

      // Refresh history and activity
      await fetchReservationHistory();
    } catch (e) {
      print('Error adding to reservation history: $e');
    }
  }

  // Generate mock reservation history for demo
  void _generateMockReservationHistory() {
    final spots = ['A07', 'B15', 'C04', 'D12', 'V02'];
    final zones = [
      'Academic Building - Block A',
      'Academic Building - Block B',
      'Faculty Parking',
      'Administration Building',
      'Visitor Parking',
    ];
    final statuses = ['Completed', 'Canceled', 'Expired'];

    _reservationHistory = [];

    // Generate 5 random history entries
    for (int i = 0; i < 5; i++) {
      final spotIndex = _random.nextInt(spots.length);
      final daysAgo = _random.nextInt(14) + 1; // 1-14 days ago
      final statusIndex = _random.nextInt(statuses.length);

      _reservationHistory.add({
        'id': spots[spotIndex],
        'zone': zones[_random.nextInt(zones.length)],
        'date': DateTime.now().subtract(Duration(days: daysAgo)),
        'duration': '${_random.nextInt(3) + 1} hours',
        'status': statuses[statusIndex],
      });
    }

    // Sort by date (most recent first)
    _reservationHistory.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );
  }

  // Generate mock recent activity for demo
  void _generateMockRecentActivity() {
    final spots = ['A07', 'B15', 'C04', 'D12', 'V02'];
    final zones = [
      'Academic Building',
      'Faculty Parking',
      'Administration Building',
      'Library',
      'Sports Complex',
    ];

    _recentActivity = [
      {
        'title': 'Parking Reserved',
        'description': 'You reserved spot ${spots[0]} in ${zones[0]}',
        'time': '2 hours ago',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': 'bookmark_added',
        'color': 'accent',
      },
      {
        'title': 'Parking Used',
        'description': 'You parked at spot ${spots[1]} in ${zones[1]}',
        'time': '1 day ago',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'icon': 'local_parking',
        'color': 'primary',
      },
      {
        'title': 'Reservation Expired',
        'description': 'Your reservation for spot ${spots[2]} expired',
        'time': '2 days ago',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'icon': 'timer_off',
        'color': 'error',
      },
    ];
  }
}
