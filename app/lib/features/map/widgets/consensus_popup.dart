import 'package:flutter/material.dart';

class ConsensusPopup extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final int extraMinutes; // Dynamic time from logic

  const ConsensusPopup({
    super.key, 
    required this.onAccept, 
    required this.onDecline,
    required this.extraMinutes,
  });

  @override
  State<ConsensusPopup> createState() => _ConsensusPopupState();
}

class _ConsensusPopupState extends State<ConsensusPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 15 Second Timer
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..forward().whenComplete(() {
      // Auto-decline if time runs out
      widget.onDecline();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. HEADER
            const Text("MATCH FOUND!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
            const SizedBox(height: 10),
            
            // 2. PROFILE
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 10),
            const Text("Rahul Sharma", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 18),
                Text(" 4.8", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // 3. THE TRADE-OFF
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text("TIME", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      // Dynamic Time Display
                      Text("+${widget.extraMinutes} min", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                    ],
                  ),
                  Container(height: 30, width: 1, color: Colors.grey),
                  const Column(
                    children: [
                      Text("SAVINGS", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text("₹ 15.00", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // 4. COUNTDOWN TIMER
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: 1.0 - _controller.value, // Shrink from full to empty
                  backgroundColor: Colors.grey[200],
                  color: _controller.value > 0.7 ? Colors.red : Colors.green, // Turn red near end
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(5),
                );
              },
            ),
            const SizedBox(height: 20),

            // 5. BUTTONS (YES / NO)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("NO"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("YES"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}