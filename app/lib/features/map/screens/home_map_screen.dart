import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'search_destination_screen.dart';
import 'side_menu_drawer.dart';
import 'driver_earnings_screen.dart'; // Import Day 19 Earnings Screen
import '../services/driver_simulation_service.dart';
import '../widgets/driver_request_panel.dart';
import '../widgets/driver_trip_panel.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // --- STATE VARIABLES ---
  LatLng? _currentPosition;
  Set<Polyline> _polylines = {};
  
  // DRIVER SIMULATION (Ghost Cars for Passenger)
  final DriverSimulationService _driverService = DriverSimulationService();
  Set<Marker> _driverMarkers = {};

  // UI FLAGS: PASSENGER
  bool _showRidePanel = false;
  bool _isLookingForDriver = false;
  bool _isDriverFound = false;
  
  // UI FLAGS: DRIVER
  bool _isDriverMode = false;     // Master Toggle
  bool _isDriverOnline = false;   // Online/Offline status
  bool _showDriverRequest = false; // Incoming Request Popup
  
  // DRIVER TRIP LOGIC
  bool _isTripActive = false;
  String _tripStatus = "pickup"; // pickup -> arrived -> started

  // Price Variables
  String _priceGo = "Loading...";
  String _priceMoto = "Loading...";
  String _priceAuto = "Loading...";

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(18.5204, 73.8567),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _driverService.dispose();
    super.dispose();
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

    // Start Simulation only if Passenger Mode (default) and markers are empty
    if (!_isDriverMode && _driverMarkers.isEmpty) {
      _driverService.startSimulation(_currentPosition!);
      _driverService.driverStream.listen((markers) {
        if (mounted && !_isDriverMode) {
           setState(() {
            _driverMarkers = markers.toSet();
          });
        }
      });
    }

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 16.0),
    ));
  }

  // --- 2. MATH & PRICING LOGIC ---
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _calculatePrices(double distanceKm) {
    setState(() {
      _priceGo = "₹${(40 + (12 * distanceKm)).toStringAsFixed(0)}";
      _priceMoto = "₹${(20 + (6 * distanceKm)).toStringAsFixed(0)}";
      _priceAuto = "₹${(25 + (9 * distanceKm)).toStringAsFixed(0)}";
    });
  }

  // --- 3. PASSENGER BOOKING LOGIC ---
  void _onBookRide() {
    setState(() {
      _isLookingForDriver = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _isLookingForDriver = false;
        _isDriverFound = true;
      });
    });
  }

  // --- 4. DRIVER ONLINE LOGIC ---
  void _toggleDriverOnline() {
    setState(() {
      _isDriverOnline = !_isDriverOnline;
    });

    if (_isDriverOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are ONLINE. Searching for rides..."), backgroundColor: Colors.green)
      );

      // Simulate an incoming request after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isDriverMode && _isDriverOnline && !_isTripActive) {
          setState(() {
            _showDriverRequest = true; // SHOW THE PANEL!
          });
        }
      });
    } else {
      setState(() {
        _showDriverRequest = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are OFFLINE."), backgroundColor: Colors.red)
      );
    }
  }

  // --- 5. DRIVER TRIP ACTION LOGIC ---
  void _handleTripAction() {
    setState(() {
      if (_tripStatus == "pickup") {
        _tripStatus = "arrived"; // Driver reached passenger
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Waiting for passenger...")));
      } else if (_tripStatus == "arrived") {
        _tripStatus = "started"; // Passenger got in
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Trip Started! Navigating to dropoff...")));
      } else if (_tripStatus == "started") {
        // Trip Over -> Reset trip state, stay online
        _isTripActive = false;
        _tripStatus = "pickup";
        
        // Show Earnings Popup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Trip Completed! ₹240.00 Added to Wallet."), backgroundColor: Colors.green)
        );
      }
    });
  }

  // --- 6. RESET APP ---
  void _resetApp() {
    setState(() {
      // Reset Passenger
      _polylines.clear();
      _showRidePanel = false;
      _isLookingForDriver = false;
      _isDriverFound = false;
      _priceGo = "Loading...";
      
      // Reset Driver Trip states
      _showDriverRequest = false;
      _isTripActive = false;
      _tripStatus = "pickup";
    });
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
    double panelHeight = MediaQuery.of(context).size.height * 0.60;
    if (_isDriverFound) panelHeight = MediaQuery.of(context).size.height * 0.55;

    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenuDrawer(
        isDriverMode: _isDriverMode,
        onModeChanged: (bool newMode) {
          setState(() {
            _isDriverMode = newMode;
            // Reset ALL states when switching modes
            _showRidePanel = false;
            _isDriverFound = false;
            _isLookingForDriver = false;
            _polylines.clear();
            _isDriverOnline = false;
            _showDriverRequest = false;
            _isTripActive = false;
            _tripStatus = "pickup";

            if (_isDriverMode) {
               _driverMarkers.clear(); // Hide ghost cars for driver
            } else {
               // Restart simulation for passenger
               if (_currentPosition != null) {
                 _driverService.startSimulation(_currentPosition!);
               }
            }
          });
        },
      ),
      body: Stack(
        children: [
          // MAP LAYER
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            polylines: _polylines,
            // Show markers only if Passenger
            markers: _isDriverMode ? {} : _driverMarkers, 
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onTap: (_) {},
            padding: EdgeInsets.only(bottom: _showRidePanel ? panelHeight : 0),
          ),

          // ==============================
          //      PASSENGER UI SECTION
          // ==============================

          // SEARCH BAR (Visible when panel is CLOSED)
          if (!_isDriverMode && !_showRidePanel)
            Positioned(
              top: 50,
              left: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5))
                  ],
                ),
                child: Row(
                  children: [
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

          // PASSENGER BOTTOM PANEL
          if (_showRidePanel && !_isDriverMode)
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

          // BACK BUTTON (Only visible in passenger selection mode)
          if (_showRidePanel && !_isDriverFound && !_isDriverMode)
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

          // ==============================
          //        DRIVER UI SECTION
          // ==============================
          if (_isDriverMode) ...[
            // Earnings Pill (Clickable -> Opens Earnings Screen)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Earnings Dashboard
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverEarningsScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    child: const Text("₹ 0.00 Today", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ),
            
            // Menu Button (Top Left)
            Positioned(
              top: 50,
              left: 20,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
            ),

            // GO ONLINE BUTTON (Hidden if Request or Trip is active)
            if (!_showDriverRequest && !_isTripActive)
               Positioned(
                 bottom: 40,
                 left: 20,
                 right: 20,
                 child: ElevatedButton(
                   onPressed: _toggleDriverOnline,
                   style: ElevatedButton.styleFrom(
                     backgroundColor: _isDriverOnline ? Colors.red : Colors.green,
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(vertical: 18),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                     elevation: 10,
                   ),
                   child: Text(
                     _isDriverOnline ? "GO OFFLINE" : "GO ONLINE", 
                     style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                   ),
                 ),
               ),

            // REQUEST PANEL (Popup when online)
            if (_showDriverRequest)
              Positioned(
                bottom: 0, 
                left: 0, 
                right: 0,
                child: DriverRequestPanel(
                  onAccept: () {
                    setState(() {
                      _showDriverRequest = false;
                      _isTripActive = true; // Start trip logic
                      _tripStatus = "pickup";
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ride Accepted! Navigating to Pickup...")));
                  },
                  onDecline: () {
                    setState(() {
                      _showDriverRequest = false;
                    });
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ride Declined. Searching...")));
                  },
                ),
              ),
              
            // TRIP PANEL (Active Ride)
            if (_isTripActive)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: DriverTripPanel(
                  status: _tripStatus,
                  onActionPressed: _handleTripAction,
                ),
              ),
          ],
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