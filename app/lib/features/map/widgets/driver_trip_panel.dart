import 'package:flutter/material.dart';

class DriverTripPanel extends StatelessWidget {
  final String status; // "pickup", "arrived", "started"
  final VoidCallback onActionPressed;

  const DriverTripPanel({
    super.key, 
    required this.status, 
    required this.onActionPressed
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. DRIVER STATUS BAR
          Container(
            width: 50, height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
          
          // 2. PASSENGER INFO
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Rahul (Passenger)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    status == "pickup" ? "Waiting at Phoenix Mall" : "Going to Pune Station",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              // Call Button
              Container(
                decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                child: IconButton(icon: const Icon(Icons.call, color: Colors.green), onPressed: () {}),
              ),
            ],
          ),

          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 15),

          // 3. DYNAMIC ACTION BUTTON
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonColor(),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
              ),
              child: Text(
                _getButtonText(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to change text based on status
  String _getButtonText() {
    switch (status) {
      case "pickup": return "ARRIVED AT PICKUP";
      case "arrived": return "START TRIP";
      case "started": return "COMPLETE TRIP";
      default: return "LOADING...";
    }
  }

  // Helper to change color
  Color _getButtonColor() {
    switch (status) {
      case "started": return Colors.red; // Red for stopping/completing
      default: return Colors.black; // Black for normal actions
    }
  }
}