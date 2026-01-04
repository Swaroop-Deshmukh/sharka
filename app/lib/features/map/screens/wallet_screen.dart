import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  static double globalBalance = 450.00;
  
  static List<Map<String, dynamic>> globalTransactions = [
    {"title": "Ride to Airport", "date": "Yesterday", "amount": "-₹450.00", "isCredit": false},
    {"title": "Added Money", "date": "2 Days ago", "amount": "+₹1000.00", "isCredit": true},
  ];

  static void addReward(double amount) {
    globalBalance += amount;
    globalTransactions.insert(0, {
      "title": "Consensus Reward", 
      "date": "Just Now", 
      "amount": "+₹${amount.toStringAsFixed(2)}", 
      "isCredit": true
    });
  }

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Wallet", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Balance", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 10),
                  Text("₹ ${WalletScreen.globalBalance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("+ Add Money"),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: WalletScreen.globalTransactions.length,
                itemBuilder: (context, index) {
                  final t = WalletScreen.globalTransactions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: t["isCredit"] ? Colors.green[50] : Colors.red[50],
                      child: Icon(
                        t["isCredit"] ? Icons.arrow_downward : Icons.arrow_upward,
                        color: t["isCredit"] ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(t["title"], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t["date"], style: const TextStyle(color: Colors.grey)),
                    trailing: Text(
                      t["amount"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        color: t["isCredit"] ? Colors.green : Colors.black
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}