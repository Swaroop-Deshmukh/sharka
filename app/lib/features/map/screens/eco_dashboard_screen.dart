import 'package:flutter/material.dart';

class EcoDashboardScreen extends StatefulWidget {
  const EcoDashboardScreen({super.key});

  @override
  State<EcoDashboardScreen> createState() => _EcoDashboardScreenState();
}

class _EcoDashboardScreenState extends State<EcoDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _treeAnimation;

  // Week 10 Logic: CO2 Calculation
  // Standard Car: 120g CO2/km. Shared Ride: 60g CO2/km.
  final double _totalKmShared = 145.5; 
  double get _co2SavedKg => (_totalKmShared * 0.06); 

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _treeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Light Green
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.green),
        title: const Text("Eco Impact", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Growing Tree Animation
            ScaleTransition(
              scale: _treeAnimation,
              child: const Icon(Icons.park, size: 150, color: Colors.green),
            ),
            const SizedBox(height: 30),
            
            // Impact Stats
            const Text("You have saved", style: TextStyle(fontSize: 18, color: Colors.black54)),
            Text("${_co2SavedKg.toStringAsFixed(1)} kg", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green)),
            const Text("of CO2 Emissions", style: TextStyle(fontSize: 18, color: Colors.black54)),
            
            const SizedBox(height: 40),
            
            // Leaderboard Preview
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const Text("Green Leaderboard", style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  _buildRankItem(1, "Aarav P.", "12.4 kg"),
                  _buildRankItem(2, "Meera K.", "10.1 kg"),
                  _buildRankItem(3, "You", "${_co2SavedKg.toStringAsFixed(1)} kg", isMe: true),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRankItem(int rank, String name, String score, {bool isMe = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: isMe ? Colors.green[50] : Colors.transparent,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: rank == 1 ? Colors.amber : Colors.grey[200],
            radius: 12,
            child: Text("$rank", style: const TextStyle(fontSize: 12, color: Colors.black)),
          ),
          const SizedBox(width: 10),
          Text(name, style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal)),
          const Spacer(),
          Text(score, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }
}