import 'dart:async';
import 'dart:math' show cos, sqrt, asin; // Import math functions
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'search_destination_screen.dart';
import 'side_menu_drawer.dart'; // Import the new Drawer file

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  
  // Key to control the Scaffold (needed to open Drawer programmatically)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // --- STATE VARIABLES ---
  LatLng? _currentPosition;
  Set<Polyline> _polylines = {};
  
  // UI State Flags
  bool _showRidePanel = false;      // Day 8: Show Bottom Sheet
  bool _isLookingForDriver = false; // Day 10: Show Loading Spinner
  bool _isDriverFound = false;      // Day 11: Show Driver Details

  // Price Variables
  String _priceGo = "Loading...";
  String _priceMoto = "Loading...";
  String _priceAuto = "Loading...";

  // Default fallback position (Pune)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(18.5204, 73.8567),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _determinePosition();
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

    Position position = await Geolocator.getCurrentPosition();
    _moveCameraToPosition(position);
  }

  Future<void> _moveCameraToPosition(Position pos) async {
    final GoogleMapController controller = await _controller.future;
    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 16.0),
    ));
  }

  // --- 2. MATH & PRICING LOGIC ---
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  void _calculatePrices(double distanceKm) {
    setState(() {
      _priceGo = "₹${(40 + (12 * distanceKm)).toStringAsFixed(0)}";
      _priceMoto = "₹${(20 + (6 * distanceKm)).toStringAsFixed(0)}";
      _priceAuto = "₹${(25 + (9 * distanceKm)).toStringAsFixed(0)}";
    });
  }

  // --- 3. BOOKING LOGIC ---
  void _onBookRide() {
    setState(() {
      _isLookingForDriver = true; // 1. Start Loading
    });

    // 2. Simulate Delay (Network Call)
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      
      setState(() {
        _isLookingForDriver = false; // Stop Loading
        _isDriverFound = true;       // 3. Show Driver Panel
      });
    });
  }

  // --- 4. RESET APP ---
  void _resetApp() {
    setState(() {
      _polylines.clear();
      _showRidePanel = false;
      _isLookingForDriver = false;
      _isDriverFound = false; // Reset driver state
      _priceGo = "Loading...";
    });
    // Zoom back to user
    if (_currentPosition != null) {
      _moveCameraToPosition(Position(
          longitude: _currentPosition!.longitude,
          latitude: _currentPosition!.latitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0, 
          altitudeAccuracy: 0, 
          headingAccuracy: 0
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Panel Height (Keeping the 60% fix for Web/Laptop)
    double panelHeight = MediaQuery.of(context).size.height * 0.60;
    if (_isDriverFound) panelHeight = MediaQuery.of(context).size.height * 0.55;

    return Scaffold(
      key: _scaffoldKey, // 1. Assign the GlobalKey
      drawer: const SideMenuDrawer(), // 2. Add the Drawer Widget
      body: Stack(
        children: [
          // MAP LAYER
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onTap: (_) {},
            padding: EdgeInsets.only(bottom: _showRidePanel ? panelHeight : 0),
          ),

          // SEARCH BAR (Visible when panel is CLOSED)
          if (!_showRidePanel)
            Positioned(
              top: 50,
              left: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
                    // Search Text (Clickable)
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SearchDestinationScreen()),
                          );

                          if (result != null && _currentPosition != null) {
                            double destLat = result['lat'];
                            double destLng = result['lng'];

                            // Logic: Distance -> Price -> Route
                            double distance = _calculateDistance(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                              destLat,
                              destLng
                            );
                            _calculatePrices(distance);

                            setState(() {
                              _polylines.add(
                                Polyline(
                                  polylineId: const PolylineId('route'),
                                  color: Colors.black,
                                  width: 5,
                                  points: [
                                    _currentPosition!,
                                    LatLng(destLat, destLng),
                                  ],
                                ),
                              );
                              _showRidePanel = true;
                            });

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
                              100,
                            ));
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 10),
                            Text("Where to?",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    
                    // 3. Profile Icon (Now Opens Drawer!)
                    GestureDetector(
                      onTap: () {
                         _scaffoldKey.currentState?.openDrawer();
                      },
                      child: const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // BOTTOM PANEL (Handles 3 States)
          if (_showRidePanel)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: panelHeight,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5))
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle Bar
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- STATE 1: DRIVER FOUND ---
                      if (_isDriverFound) ...[
                        const Text("Driver is arriving in 2 mins", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                        const SizedBox(height: 20),
                        
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                          child: Row(
                            children: [
                              const CircleAvatar(radius: 25, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 30, color: Colors.white)),
                              const SizedBox(width: 15),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Raju Bhai", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text("White Swift Dzire", style: TextStyle(color: Colors.grey)),
                                  Text("MH 12 AB 1234", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                              const Spacer(),
                              const Column(
                                children: [
                                  Icon(Icons.star, color: Colors.amber),
                                  Text("4.8", style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.call, color: Colors.black),
                                label: const Text("Call Driver", style: TextStyle(color: Colors.black)),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _resetApp,
                                icon: const Icon(Icons.close, color: Colors.white),
                                label: const Text("Cancel Ride"),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15)),
                              ),
                            ),
                          ],
                        )

                      // --- STATE 2: LOADING ---
                      ] else if (_isLookingForDriver) ...[
                        const SizedBox(height: 50),
                        const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: Colors.black),
                              SizedBox(height: 20),
                              Text("Finding your ride...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("Connecting to nearby drivers", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),

                      // --- STATE 3: RIDE SELECTION ---
                      ] else ...[
                        const Text("Choose a ride",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),

                        _buildRideOption(
                          title: "Sharka Go",
                          price: _priceGo,
                          time: "3 min away",
                          icon: Icons.directions_car,
                          isSelected: true,
                        ),
                        _buildRideOption(
                          title: "Moto",
                          price: _priceMoto,
                          time: "5 min away",
                          icon: Icons.two_wheeler,
                          isSelected: false,
                        ),
                        _buildRideOption(
                          title: "Auto",
                          price: _priceAuto,
                          time: "2 min away",
                          icon: Icons.electric_rickshaw,
                          isSelected: false,
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _onBookRide,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Choose Sharka Go",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),

          // BACK BUTTON (Only visible in selection mode, not driver mode)
          if (_showRidePanel && !_isDriverFound)
            Positioned(
              top: 50,
              left: 15,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: _resetApp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRideOption({
    required String title,
    required String price,
    required String time,
    required IconData icon,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: Colors.black, width: 2)
            : Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Icon(icon, size: 40, color: Colors.grey[800]),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              Text(time,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
          const Spacer(),
          Text(price,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}