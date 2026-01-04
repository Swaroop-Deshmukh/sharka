import 'package:flutter/material.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  static List<Map<String, dynamic>> tripHistory = [
    {
      "date": "Yesterday, 5:30 PM",
      "source": "Home",
      "dest": "Phoenix Mall",
      "price": "₹145",
      "car": "White Swift Dzire",
      "status": "Completed"
    },
    {
      "date": "2 Days Ago, 9:00 AM",
      "source": "Office",
      "dest": "Pune Station",
      "price": "₹210",
      "car": "Honda City",
      "status": "Canceled"
    },
  ];

  static void addTrip(String source, String dest, String price) {
    tripHistory.insert(0, {
      "date": "Just Now",
      "source": source,
      "dest": dest,
      "price": price,
      "car": "Sharka Go",
      "status": "Completed"
    });
  }

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Your Trips", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: RideHistoryScreen.tripHistory.isEmpty
          ? Center(child: Text("No trips yet", style: TextStyle(color: Colors.grey[400])))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: RideHistoryScreen.tripHistory.length,
              itemBuilder: (context, index) {
                final trip = RideHistoryScreen.tripHistory[index];
                bool isCompleted = trip["status"] == "Completed";

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(trip["date"], style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(trip["price"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 12, color: Colors.green),
                          const SizedBox(width: 10),
                          Text(trip["source"], style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      // --- FIX: Border moved inside BoxDecoration ---
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        height: 15, 
                        decoration: const BoxDecoration(
                          border: Border(left: BorderSide(color: Colors.grey, width: 1))
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.square, size: 12, color: Colors.red),
                          const SizedBox(width: 10),
                          Text(trip["dest"], style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.directions_car, color: Colors.grey, size: 20),
                              const SizedBox(width: 5),
                              Text(trip["car"], style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.green[50] : Colors.red[50],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              trip["status"],
                              style: TextStyle(
                                color: isCompleted ? Colors.green : Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}