import 'package:flutter/material.dart';

class SearchDestinationScreen extends StatefulWidget {
  const SearchDestinationScreen({super.key});

  @override
  State<SearchDestinationScreen> createState() => _SearchDestinationScreenState();
}

class _SearchDestinationScreenState extends State<SearchDestinationScreen> {
  final TextEditingController _searchController = TextEditingController();

  // 1. EXTENDED LIST OF CITIES (Simulating a database)
  final List<Map<String, dynamic>> _allLocations = [
    {"name": "Home", "address": "Pune, Maharashtra, India", "lat": 18.5204, "lng": 73.8567},
    {"name": "Office", "address": "Hinjewadi, Pune, India", "lat": 18.5913, "lng": 73.7389},
    {"name": "Pune Airport", "address": "Lohegaon, Pune, India", "lat": 18.5793, "lng": 73.9089},
    {"name": "Mumbai", "address": "Gateway of India, Mumbai", "lat": 19.0760, "lng": 72.8777},
    {"name": "Amravati", "address": "Amravati City, Maharashtra", "lat": 20.9374, "lng": 77.7796},
    {"name": "Nagpur", "address": "Zero Mile Stone, Nagpur", "lat": 21.1458, "lng": 79.0882},
    {"name": "Nashik", "address": "Panchavati, Nashik", "lat": 19.9975, "lng": 73.7898},
    {"name": "VIT Pune", "address": "Bibwewadi, Pune", "lat": 18.4636, "lng": 73.8681},
  ];

  // 2. FILTERED LIST (Updates as you type)
  List<Map<String, dynamic>> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _filteredLocations = _allLocations; // Start with all showing
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allLocations;
    } else {
      results = _allLocations
          .where((loc) => loc["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredLocations = results;
    });
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
        title: const Text("Plan your ride", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // SEARCH INPUT
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value), // Trigger filter
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Where to? (e.g. Amravati)",
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          const Divider(height: 1),

          // LIST RESULTS
          Expanded(
            child: _filteredLocations.isNotEmpty 
            ? ListView.builder(
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) {
                final location = _filteredLocations[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.location_on, color: Colors.white, size: 20),
                  ),
                  title: Text(location["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(location["address"]),
                  onTap: () {
                    // Return the selected coordinates to HomeMapScreen
                    Navigator.pop(context, {
                      'lat': location['lat'],
                      'lng': location['lng'],
                      'name': location['name']
                    });
                  },
                );
              },
            )
            : const Padding(
                padding: EdgeInsets.all(20),
                child: Text("No location found. Try 'Pune' or 'Mumbai'", style: TextStyle(color: Colors.grey)),
              ),
          ),
        ],
      ),
    );
  }
}