import 'package:flutter/material.dart';

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Earnings", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TODAY'S TOTAL
              const Center(child: Text("Today's Earnings", style: TextStyle(color: Colors.grey, fontSize: 16))),
              const SizedBox(height: 10),
              const Center(child: Text("₹ 1,240.50", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold))),
              
              const SizedBox(height: 30),

              // 2. WEEKLY CHART (Visual Simulation)
              Container(
                height: 200,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar("Mon", 40),
                    _buildBar("Tue", 60),
                    _buildBar("Wed", 30),
                    _buildBar("Thu", 80),
                    _buildBar("Fri", 50, isActive: true), // Today
                    _buildBar("Sat", 0),
                    _buildBar("Sun", 0),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 3. STATS GRID
              Row(
                children: [
                  _buildStatCard(Icons.directions_car, "12", "Trips"),
                  const SizedBox(width: 15),
                  _buildStatCard(Icons.access_time, "4.5h", "Online"),
                  const SizedBox(width: 15),
                  _buildStatCard(Icons.star, "4.9", "Rating"),
                ],
              ),

              const SizedBox(height: 30),
              const Text("Recent Trips", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // 4. TRIP LIST
              _buildTripItem("Phoenix Mall to Station", "2:30 PM", "₹240.00"),
              _buildTripItem("Hinjewadi to Baner", "1:15 PM", "₹180.00"),
              _buildTripItem("Kothrud to FC Road", "11:00 AM", "₹120.00"),
              _buildTripItem("Airport Drop", "9:30 AM", "₹450.00"),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Chart Bars
  Widget _buildBar(String day, double heightPct, {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 15,
          height: 120 * (heightPct / 100), // Max height 120
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 10),
        Text(day, style: TextStyle(color: isActive ? Colors.black : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  // Helper for Stat Cards
  Widget _buildStatCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // Helper for Trip List Items
  Widget _buildTripItem(String route, String time, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.green, size: 16),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(route, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}