import 'package:flutter/material.dart';

class LuxuryRideSelector extends StatefulWidget {
  final Function(String, int) onCarSelected; // Returns Name and Price

  const LuxuryRideSelector({super.key, required this.onCarSelected});

  @override
  State<LuxuryRideSelector> createState() => _LuxuryRideSelectorState();
}

class _LuxuryRideSelectorState extends State<LuxuryRideSelector> {
  int _selectedIndex = 0;

  // Week 9: "Showroom" Data
  final List<Map<String, dynamic>> _luxuryCars = [
    {"name": "Audi A6", "image": "assets/audi.png", "price": 850, "desc": "Executive Class"},
    {"name": "BMW 5 Series", "image": "assets/bmw.png", "price": 950, "desc": "Ultimate Comfort"},
    {"name": "Mercedes E-Class", "image": "assets/merc.png", "price": 1100, "desc": "Pure Luxury"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("SHARKA PRESTIGE", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220, // Taller for "Showroom" feel
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.8),
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
              widget.onCarSelected(_luxuryCars[index]['name'], _luxuryCars[index]['price']);
            },
            itemCount: _luxuryCars.length,
            itemBuilder: (context, index) {
              bool isActive = index == _selectedIndex;
              final car = _luxuryCars[index];

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (isActive) const BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 10))
                  ],
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder for Car Image (Use Icon for now)
                    Icon(Icons.directions_car_filled, size: 80, color: isActive ? Colors.white : Colors.grey),
                    const SizedBox(height: 10),
                    Text(car['name'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.black)),
                    Text(car['desc'], style: TextStyle(color: isActive ? Colors.grey[400] : Colors.grey)),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
                      child: Text("₹${car['price']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}