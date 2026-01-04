import 'dart:async';
import 'dart:math'; // Required for Random() & Calculations
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'search_destination_screen.dart';
import 'side_menu_drawer.dart';
import 'driver_earnings_screen.dart';
import 'wallet_screen.dart'; // Day 24: Wallet Integration
import '../services/driver_simulation_service.dart';
import '../widgets/driver_request_panel.dart';
import '../widgets/driver_trip_panel.dart';
import '../widgets/consensus_popup.dart'; // Day 22: Consensus Popup
import '../logic/deviation_logic.dart'; // Day 23: Logic

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
  
  // DRIVER SIMULATION
  final DriverSimulationService _driverService = DriverSimulationService();
  Set<Marker> _driverMarkers = {};

  // LOGIC ENGINES (Week 4)
  final DeviationLogic _deviationLogic = DeviationLogic();
  int _detourMinutes = 5; 

  // UI FLAGS: PASSENGER
  bool _showRidePanel = false;
  bool _isLookingForDriver = false;
  bool _isDriverFound = false;
  
  // UI FLAGS: DRIVER
  bool _isDriverMode = false;
  bool _isDriverOnline = false;
  bool _showDriverRequest = false;
  
  // DRIVER TRIP LOGIC
  bool _isTripActive = false;
  String _tripStatus = "pickup";

  // PRICE VARIABLES
  String _priceGo = "Loading...";
  String _priceMoto = "Loading...";
  String _priceAuto = "Loading...";
  
  // SHARKA SHARE VARIABLES (Day 21)
  String _priceShare = "Loading...";
  int _requestedSeats = 1;

  // INTERCITY LOGIC (Day 25)
  bool _isIntercity = false; // False = City, True = Outstation
  String _priceIntercitySedan = "Loading...";
  String _priceIntercitySUV = "Loading...";

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
      // 1. CITY PRICES (Standard)
      double rawPriceGo = 40 + (12 * distanceKm);
      _priceGo = "₹${rawPriceGo.toStringAsFixed(0)}";
      _priceMoto = "₹${(20 + (6 * distanceKm)).toStringAsFixed(0)}";
      _priceAuto = "₹${(25 + (9 * distanceKm)).toStringAsFixed(0)}";
      _priceShare = "₹${(rawPriceGo * 0.70).toStringAsFixed(0)}";

      // 2. INTERCITY PRICES (Day 25)
      // Base ₹500 + ₹15/km (Sedan)
      _priceIntercitySedan = "₹${(500 + (15 * distanceKm)).toStringAsFixed(0)}";
      // Base ₹800 + ₹22/km (SUV)
      _priceIntercitySUV = "₹${(800 + (22 * distanceKm)).toStringAsFixed(0)}";
    });
  }

  // --- 3. PASSENGER BOOKING & DEVIATION LOGIC ---
  void _onBookRide() {
    setState(() {
      _isLookingForDriver = true;
    });

    // Simulate Finding Driver
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _isLookingForDriver = false;
        _isDriverFound = true;
      });

      // TRIGGER CONSENSUS POPUP (Day 22)
      // Only trigger if we are in City Mode
      if (!_isIntercity) {
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted && !_isDriverMode && _currentPosition != null) {
            
            // 1. Simulate a New Passenger nearby (Day 23)
            double randomLat = _currentPosition!.latitude + (Random().nextDouble() * 0.015); 
            double randomLng = _currentPosition!.longitude + (Random().nextDouble() * 0.015);

            // 2. Calculate Real Deviation Time
            int calculatedTime = _deviationLogic.calculateDetourTime(
              _currentPosition!.latitude, 
              _currentPosition!.longitude, 
              randomLat, 
              randomLng
            );

            setState(() {
              _detourMinutes = calculatedTime;
            });

            // 3. Only show popup if Fair (< 10 mins)
            if (_deviationLogic.isFairDetour(calculatedTime)) {
                _showConsensusDialog();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sharka blocked a match (Too far) to save your time!"), duration: Duration(seconds: 3))
              );
            }
          }
        });
      }
    });
  }

  // Helper: Show the Voting Popup (Day 22 + Day 24 Reward)
  void _showConsensusDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ConsensusPopup(
          extraMinutes: _detourMinutes,
          onAccept: () {
            Navigator.pop(context);

            // --- DAY 24: CREDIT WALLET ---
            WalletScreen.addReward(15.00); 

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Vote Accepted! ₹15.00 Added to Wallet."), backgroundColor: Colors.green),
            );
          },
          onDecline: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Vote Declined. Continuing solo."), backgroundColor: Colors.red),
            );
          },
        );
      },
    );
  }

  // --- 4. DRIVER LOGIC ---
  void _toggleDriverOnline() {
    setState(() {
      _isDriverOnline = !_isDriverOnline;
    });

    if (_isDriverOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are ONLINE. Searching for rides..."), backgroundColor: Colors.green)
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isDriverMode && _isDriverOnline && !_isTripActive) {
          setState(() {
            _showDriverRequest = true;
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

  void _handleTripAction() {
    setState(() {
      if (_tripStatus == "pickup") {
        _tripStatus = "arrived";
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Waiting for passenger...")));
      } else if (_tripStatus == "arrived") {
        _tripStatus = "started";
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Trip Started! Navigating to dropoff...")));
      } else if (_tripStatus == "started") {
        _isTripActive = false;
        _tripStatus = "pickup";
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Trip Completed! ₹240.00 Added to Wallet."), backgroundColor: Colors.green)
        );
      }
    });
  }

  // --- 5. RESET APP ---
  void _resetApp() {
    setState(() {
      _polylines.clear();
      _showRidePanel = false;
      _isLookingForDriver = false;
      _isDriverFound = false;
      _priceGo = "Loading...";
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
            _showRidePanel = false;
            _isDriverFound = false;
            _isLookingForDriver = false;
            _polylines.clear();
            _isDriverOnline = false;
            _showDriverRequest = false;
            _isTripActive = false;
            _tripStatus = "pickup";

            if (_isDriverMode) {
               _driverMarkers.clear();
            } else {
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

          // PASSENGER UI: SEARCH BAR
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
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SearchDestinationScreen()),
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

                            final GoogleMapController controller = await _controller.future;
                            controller.animateCamera(CameraUpdate.newLatLngBounds(
                              LatLngBounds(
                                southwest: LatLng(
                                  _currentPosition!.latitude < destLat ? _currentPosition!.latitude : destLat,
                                  _currentPosition!.longitude < destLng ? _currentPosition!.longitude : destLng,
                                ),
                                northeast: LatLng(
                                  _currentPosition!.latitude > destLat ? _currentPosition!.latitude : destLat,
                                  _currentPosition!.longitude > destLng ? _currentPosition!.longitude : destLng,
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
                            Text("Where to?", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
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

          // PASSENGER UI: BOTTOM PANEL
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
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
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
                        const Text("Choose a ride", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),

                        // --- MODE TOGGLE (Day 25) ---
                        _buildModeToggle(),
                        const SizedBox(height: 15),

                        if (!_isIntercity) ...[
                          // --- CITY MODE LIST ---
                          
                          // SHARKA SHARE (Green Card - Day 21)
                          Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              border: Border.all(color: Colors.green, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                  leading: const Icon(Icons.people, color: Colors.green, size: 30),
                                  title: const Text("Sharka Share", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18)),
                                  subtitle: const Text("Wait up to 5 mins • Save 30%", style: TextStyle(fontSize: 12, color: Colors.black54)),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(_priceShare, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green)),
                                      const Text("Best Value", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                                    ],
                                  ),
                                  onTap: () {
                                    // Logic for selecting "Share"
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _buildSeatSelector(),
                                ),
                              ],
                            ),
                          ),

                          // Standard Rides
                          _buildRideOption(title: "Sharka Go", price: _priceGo, time: "3 min away", icon: Icons.directions_car, isSelected: true),
                          _buildRideOption(title: "Moto", price: _priceMoto, time: "5 min away", icon: Icons.two_wheeler, isSelected: false),
                          _buildRideOption(title: "Auto", price: _priceAuto, time: "2 min away", icon: Icons.electric_rickshaw, isSelected: false),

                        ] else ...[
                          // --- OUTSTATION MODE (Day 25) ---
                          const Text("Travel comfortably to other cities", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 10),

                          _buildRideOption(title: "Intercity Sedan", price: _priceIntercitySedan, time: "15 min", icon: Icons.directions_car_filled, isSelected: true),
                          _buildRideOption(title: "Intercity SUV", price: _priceIntercitySUV, time: "20 min", icon: Icons.airport_shuttle, isSelected: false),
                        ],

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _onBookRide,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Choose Sharka Go", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),

          // BACK BUTTON (Passenger)
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

          // DRIVER UI SECTION
          if (_isDriverMode) ...[
            // Earnings Pill
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
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
            
            // Menu Button
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

            // GO ONLINE BUTTON
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

            // REQUEST PANEL
            if (_showDriverRequest)
              Positioned(
                bottom: 0, 
                left: 0, 
                right: 0,
                child: DriverRequestPanel(
                  onAccept: () {
                    setState(() {
                      _showDriverRequest = false;
                      _isTripActive = true;
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
              
            // TRIP PANEL
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

  // Helper: Standard Ride Card
  Widget _buildRideOption({required String title, required String price, required String time, required IconData icon, required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: Colors.black, width: 2) : Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          SizedBox(width: 60, child: Icon(icon, size: 40, color: Colors.grey[800])),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Text(time, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
          const Spacer(),
          Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Helper: Seat Selector Widget (Day 21)
  Widget _buildSeatSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Seats: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(width: 10),
        ToggleButtons(
          isSelected: [_requestedSeats == 1, _requestedSeats == 2],
          onPressed: (index) {
            setState(() {
              _requestedSeats = index + 1;
            });
          },
          borderRadius: BorderRadius.circular(10),
          borderColor: Colors.green,
          selectedBorderColor: Colors.green,
          selectedColor: Colors.white,
          fillColor: Colors.green,
          color: Colors.green,
          constraints: const BoxConstraints(minHeight: 30, minWidth: 40),
          children: const [Text("1"), Text("2")],
        ),
      ],
    );
  }

  // Helper: Mode Toggle (Day 25)
  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildToggleOption("City Rides", !_isIntercity),
          _buildToggleOption("Outstation", _isIntercity),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String text, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isIntercity = (text == "Outstation");
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}