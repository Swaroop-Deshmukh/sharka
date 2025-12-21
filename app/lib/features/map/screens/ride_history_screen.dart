import 'package:flutter/material.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white, // Makes the back arrow white
        title: const Text("Your Rides", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. RECENT RIDE
          _buildHistoryItem(
            date: "Today, 10:30 AM",
            from: "Shivajinagar, Pune",
            to: "Phoenix Mall, Viman Nagar",
            price: "₹210",
            status: "Completed",
            isCompleted: true,
          ),
          
          // 2. YESTERDAY'S RIDE
          _buildHistoryItem(
            date: "Yesterday, 6:15 PM",
            from: "Office (Hinjewadi)",
            to: "Home (Kothrud)",
            price: "₹350",
            status: "Completed",
            isCompleted: true,
          ),

          // 3. CANCELLED RIDE
          _buildHistoryItem(
            date: "15 Dec, 9:00 AM",
            from: "Home",
            to: "Pune Railway Station",
            price: "₹0",
            status: "Cancelled",
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  // Helper Widget for a Single Row
  Widget _buildHistoryItem({
    required String date,
    required String from,
    required String to,
    required String price,
    required String status,
    required bool isCompleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 20),
          
          // Locations
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.green, size: 12),
              const SizedBox(width: 10),
              Expanded(child: Text(from, style: const TextStyle(fontWeight: FontWeight.w500))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 12),
              const SizedBox(width: 10),
              Expanded(child: Text(to, style: const TextStyle(fontWeight: FontWeight.w500))),
            ],
          ),
          const SizedBox(height: 15),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isCompleted ? Colors.green[700] : Colors.red[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}