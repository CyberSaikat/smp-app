import 'dart:math';

import 'package:location/location.dart';

class LocationDetails {
  static Future<void> requestPermission() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  static Future<LocationData?> getLocation() async {
    Location location = Location();
    LocationData locationData = await location.getLocation();
    return locationData;
  }

// Function to calculate distance between two coordinates using Haversine formula
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

// Helper function to convert degrees to radians
  static double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

// Check if a location is within a 100-meter radius of a specific location
  static bool isWithin100Meters(double currentLat, double currentLon,
      double targetLat, double targetLon) {
    double distance =
        calculateDistance(currentLat, currentLon, targetLat, targetLon);
    return distance <= 100;
  }
}
