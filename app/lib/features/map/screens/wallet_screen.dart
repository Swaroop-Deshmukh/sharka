import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Wallet", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Makes back button black
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BALANCE CARD (Black Card Style)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 10),
                  const Text("₹850.00", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      _buildActionButton(Icons.add, "Add Money"),
                      const SizedBox(width: 15),
                      _buildActionButton(Icons.qr_code_scanner, "Scan"),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 2. TRANSACTIONS LIST
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildTransactionItem("Payment for Ride", "Yesterday, 6:30 PM", "- ₹210.00", Colors.red),
                  _buildTransactionItem("Added via UPI", "18 Dec, 10:00 AM", "+ ₹500.00", Colors.green),
                  _buildTransactionItem("Payment for Ride", "15 Dec, 9:15 AM", "- ₹140.00", Colors.red),
                  _buildTransactionItem("Refund processed", "10 Dec, 2:30 PM", "+ ₹50.00", Colors.green),
                  _buildTransactionItem("Payment for Ride", "08 Dec, 5:45 PM", "- ₹85.00", Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for White Buttons inside Black Card
  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Helper for Transaction Rows
  Widget _buildTransactionItem(String title, String date, String amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Colors.grey[100],
          radius: 22,
          child: Icon(
            amount.startsWith("+") ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
            size: 20,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}