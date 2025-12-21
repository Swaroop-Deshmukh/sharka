import 'package:flutter/material.dart';
import 'ride_history_screen.dart'; // Import Day 13 Screen
import 'wallet_screen.dart';       // Import Day 14 Screen

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 1. HEADER (Profile Info)
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.black),
            ),
            accountName: const Text("User Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: const Text("+91 98765 43210"),
          ),

          // 2. MENU ITEMS
          
          // A. YOUR RIDES (Navigates to History)
          _buildMenuItem(Icons.history, "Your Rides", () {
            Navigator.pop(context); // Close Drawer first
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RideHistoryScreen()),
            );
          }),

          // B. WALLET (Navigates to Wallet)
          _buildMenuItem(Icons.account_balance_wallet, "Wallet", () {
            Navigator.pop(context); // Close Drawer first
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WalletScreen()),
            );
          }),

          // C. Placeholder Items
          _buildMenuItem(Icons.notifications, "Notifications", () {
            Navigator.pop(context);
            // Feature coming in Week 3
          }),
          
          _buildMenuItem(Icons.settings, "Settings", () {
            Navigator.pop(context);
          }),

          const Divider(),

          _buildMenuItem(Icons.help, "Help & Support", () {
            Navigator.pop(context);
          }),

          const Spacer(),

          // 3. LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              // Logout logic will be added in Week 3 (Auth)
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper Widget to create standard menu rows
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}