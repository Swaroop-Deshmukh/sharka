import 'package:flutter/material.dart';
import 'ride_history_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart'; // Import Day 20 Screen

class SideMenuDrawer extends StatefulWidget {
  final bool isDriverMode;
  final Function(bool) onModeChanged;

  const SideMenuDrawer({
    super.key,
    required this.isDriverMode,
    required this.onModeChanged,
  });

  @override
  State<SideMenuDrawer> createState() => _SideMenuDrawerState();
}

class _SideMenuDrawerState extends State<SideMenuDrawer> {
  late bool _isDriver;

  @override
  void initState() {
    super.initState();
    _isDriver = widget.isDriverMode;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 1. HEADER (Profile Info)
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            currentAccountPicture: GestureDetector(
              onTap: () {
                // Navigate to Profile when clicking picture
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.black),
              ),
            ),
            accountName: const Text("User Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: const Text("+91 98765 43210"),
          ),

          // 2. ROLE SWITCHER (The "Super App" Toggle)
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isDriver ? "DRIVER MODE" : "PASSENGER MODE",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
                Switch(
                  value: _isDriver,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey,
                  onChanged: (value) {
                    setState(() {
                      _isDriver = value;
                    });
                    // Trigger the logic in Home Screen
                    widget.onModeChanged(value);

                    // Close drawer after short delay to show the animation
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          ),

          // 3. MENU ITEMS
          
          // A. YOUR RIDES (Navigates to History)
          _buildMenuItem(Icons.history, "Your Rides", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RideHistoryScreen()),
            );
          }),

          // B. WALLET (Navigates to Wallet)
          _buildMenuItem(Icons.account_balance_wallet, "Wallet", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WalletScreen()),
            );
          }),

          _buildMenuItem(Icons.notifications, "Notifications", () {
            Navigator.pop(context);
          }),

          // C. SETTINGS (Navigates to Profile/Settings)
          _buildMenuItem(Icons.settings, "Settings", () {
            Navigator.pop(context);
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }),

          const Divider(),

          _buildMenuItem(Icons.help, "Help & Support", () {
            Navigator.pop(context);
          }),

          const Spacer(),

          // 4. LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              // Logout logic will be added later
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}