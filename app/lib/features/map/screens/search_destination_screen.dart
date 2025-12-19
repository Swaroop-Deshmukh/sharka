import 'package:flutter/material.dart';

class SearchDestinationScreen extends StatefulWidget {
  const SearchDestinationScreen({super.key});

  @override
  State<SearchDestinationScreen> createState() => _SearchDestinationScreenState();
}

class _SearchDestinationScreenState extends State<SearchDestinationScreen> {
  // Controllers to get text from the inputs
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Plan your ride",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // 1. INPUT FIELDS SECTION
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                // "From" Field
                Row(
                  children: [
                    const Icon(Icons.my_location, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _sourceController,
                        decoration: InputDecoration(
                          hintText: "Your location",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Divider line with a connector dot
                Row(
                  children: [
                     const SizedBox(width: 9),
                     Container(height: 25, width: 2, color: Colors.grey[300]),
                  ],
                ),
                const SizedBox(height: 2),

                // "To" Field
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _destinationController,
                        autofocus: true, // Keyboard opens automatically
                        decoration: InputDecoration(
                          hintText: "Where to?",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. PREDICTIONS LIST (Placeholder for Day 7)
         // 2. PREDICTIONS LIST (Updated for Day 7)
          Expanded(
            child: ListView.separated(
              itemCount: 3, 
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: Colors.grey, size: 16),
                  ),
                  title: Text(index == 0 ? "Home" : index == 1 ? "Office" : "Pune Airport"),
                  subtitle: const Text("Pune, Maharashtra, India"),
                  onTap: () {
                    // DEFINE COORDINATES FOR DEMO
                    // 1. Home (Example)
                    // 2. Office (Example)
                    // 3. Pune Airport (Real coords: 18.5793, 73.9089)
                    
                    Map<String, double> selectedLocation;

                    if (index == 2) {
                      // Pune Airport Coordinates
                      selectedLocation = {'lat': 18.5793, 'lng': 73.9089}; 
                    } else {
                      // Just a random point nearby for demo
                      selectedLocation = {'lat': 18.5204, 'lng': 73.8567}; 
                    }

                    // SEND DATA BACK TO PREVIOUS SCREEN
                    Navigator.pop(context, selectedLocation); 
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}