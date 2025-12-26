import 'package:flutter/material.dart';

class DriverRequestPanel extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const DriverRequestPanel({
    super.key, 
    required this.onAccept, 
    required this.onDecline
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Shrink to fit content
        children: [
          // 1. HEADER
          const Text("New Ride Request", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),

          // 2. TRIP DETAILS
          _buildRow(Icons.person, "Passenger", "Rahul (4.9 ★)"),
          const SizedBox(height: 15),
          _buildRow(Icons.my_location, "Pickup", "Phoenix Mall (2.5 km away)"),
          const SizedBox(height: 15),
          _buildRow(Icons.location_on, "Dropoff", "Pune Station (8.0 km)"),
          
          const SizedBox(height: 20),
          
          // 3. EARNINGS (Highlighted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Est. Earnings", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                Text("₹ 240.00", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 4. ACTION BUTTONS
          Row(
            children: [
              // DECLINE BUTTON
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                  ),
                  child: const Text("DECLINE"),
                ),
              ),
              const SizedBox(width: 15),
              // ACCEPT BUTTON
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 5,
                  ),
                  child: const Text("ACCEPT RIDE", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        )
      ],
    );
  }
}