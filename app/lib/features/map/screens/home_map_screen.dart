import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'search_destination_screen.dart'; // Ensure this file exists in the same folder

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  // Variables to store location and route lines
  LatLng? _currentPosition;
  Set<Polyline> _polylines = {};

  // Default fallback position (Pune)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(18.5204, 73.8567),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Get user location on startup
  }

  // --- 1. LOCATION LOGIC ---
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Permission granted: Get position
    Position position = await Geolocator.getCurrentPosition();
    _moveCameraToPosition(position);
  }

  Future<void> _moveCameraToPosition(Position pos) async {
    final GoogleMapController controller = await _controller.future;

    // Save current position for later use (drawing lines)
    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 16.0,
      ),
    ));
  }

  // --- 2. UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MAP LAYER
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            polylines: _polylines, // Draws the route line
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true, // Blue Dot
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // FLOATING SEARCH BAR
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: GestureDetector(
              onTap: () async {
                // 1. Go to Search Screen and wait for result
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchDestinationScreen()),
                );

                // 2. If a destination was selected, draw the route
                if (result != null && _currentPosition != null) {
                  double destLat = result['lat'];
                  double destLng = result['lng'];

                  setState(() {
                    _polylines.add(
                      Polyline(
                        polylineId: const PolylineId('route'),
                        color: Colors.black, // Uber-style black line
                        width: 5,
                        points: [
                          _currentPosition!,        // Start: My Location
                          LatLng(destLat, destLng), // End: Selected Place
                        ],
                      ),
                    );
                  });

                  // 3. Zoom camera to fit the whole route
                  final GoogleMapController controller =
                      await _controller.future;
                  controller.animateCamera(CameraUpdate.newLatLngBounds(
                    LatLngBounds(
                      southwest: LatLng(
                        _currentPosition!.latitude < destLat
                            ? _currentPosition!.latitude
                            : destLat,
                        _currentPosition!.longitude < destLng
                            ? _currentPosition!.longitude
                            : destLng,
                      ),
                      northeast: LatLng(
                        _currentPosition!.latitude > destLat
                            ? _currentPosition!.latitude
                            : destLat,
                        _currentPosition!.longitude > destLng
                            ? _currentPosition!.longitude
                            : destLng,
                      ),
                    ),
                    100, // Padding around the edges
                  ));
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text("Where to?",
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 16)),
                    ),
                    const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.grey,
                      child:
                          Icon(Icons.person, size: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}