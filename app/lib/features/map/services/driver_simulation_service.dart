import 'dart:async';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverSimulationService {
  // Simulates a stream of driver locations from a Socket
  final _driverStreamController = StreamController<List<Marker>>.broadcast();

  Stream<List<Marker>> get driverStream => _driverStreamController.stream;

  // Store current driver positions to update them smoothly
  List<LatLng> _currentDriverPositions = [];

  // 1. GENERATE FAKE DRIVERS (Around a center point)
  void startSimulation(LatLng center) {
    final random = Random();
    _currentDriverPositions = List.generate(5, (index) {
      // Create random offset within ~1-2km
      double lat = center.latitude + (random.nextDouble() - 0.5) * 0.02;
      double lng = center.longitude + (random.nextDouble() - 0.5) * 0.02;
      return LatLng(lat, lng);
    });

    // Start a timer to "move" them every 3 seconds
    Timer.periodic(const Duration(seconds: 3), (timer) {
      _moveDrivers();
    });
  }

  // 2. MOVE DRIVERS (Simulate driving)
  void _moveDrivers() {
    final random = Random();
    List<Marker> markers = [];

    // Update each driver's position slightly
    for (int i = 0; i < _currentDriverPositions.length; i++) {
      LatLng oldPos = _currentDriverPositions[i];
      
      // Move slightly in a random direction
      double newLat = oldPos.latitude + (random.nextDouble() - 0.5) * 0.001;
      double newLng = oldPos.longitude + (random.nextDouble() - 0.5) * 0.001;
      
      _currentDriverPositions[i] = LatLng(newLat, newLng);

      // Create a Marker for this driver
      markers.add(
        Marker(
          markerId: MarkerId('driver_$i'),
          position: _currentDriverPositions[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet), // Violet cars
          rotation: _calculateHeading(oldPos, _currentDriverPositions[i]), // Rotate car to face direction
          infoWindow: InfoWindow(title: "Sharka Driver #$i"),
        ),
      );
    }

    // Push new positions to the app
    _driverStreamController.add(markers);
  }

  // Helper: Calculate rotation based on movement
  double _calculateHeading(LatLng start, LatLng end) {
    double lat1 = start.latitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double dLng = (end.longitude - start.longitude) * pi / 180;

    double y = sin(dLng) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    double heading = atan2(y, x);

    return (heading * 180 / pi + 360) % 360;
  }
  
  void dispose() {
    _driverStreamController.close();
  }
}