import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'user.dart';

enum ParkingStatus { available, occupied, reserved }

class ParkingSpot {
  final String id;
  final String zone;
  final ParkingStatus status;
  final List<UserType> allowedTypes;
  final LatLng location;
  final String? reservedBy;
  final DateTime? reservedUntil;

  ParkingSpot({
    required this.id,
    required this.zone,
    required this.status,
    required this.allowedTypes,
    required this.location,
    this.reservedBy,
    this.reservedUntil,
  });

  ParkingSpot copyWith({
    String? id,
    String? zone,
    ParkingStatus? status,
    List<UserType>? allowedTypes,
    LatLng? location,
    String? reservedBy,
    DateTime? reservedUntil,
  }) {
    return ParkingSpot(
      id: id ?? this.id,
      zone: zone ?? this.zone,
      status: status ?? this.status,
      allowedTypes: allowedTypes ?? this.allowedTypes,
      location: location ?? this.location,
      reservedBy: reservedBy ?? this.reservedBy,
      reservedUntil: reservedUntil ?? this.reservedUntil,
    );
  }

  String get statusText {
    switch (status) {
      case ParkingStatus.available:
        return 'Available';
      case ParkingStatus.occupied:
        return 'Occupied';
      case ParkingStatus.reserved:
        if (reservedUntil != null) {
          final diff = reservedUntil!.difference(DateTime.now());
          final hours = diff.inHours;
          final minutes = diff.inMinutes % 60;

          if (hours > 0) {
            return 'Reserved ($hours hr ${minutes > 0 ? '$minutes min' : ''})';
          } else {
            return 'Reserved ($minutes min)';
          }
        }
        return 'Reserved';
    }
  }
}
