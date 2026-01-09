import 'package:flutter/material.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';
import 'ride_history_screen.dart';
import 'saved_places_screen.dart';
import 'help_support_screen.dart';
import 'language_screen.dart';
import 'eco_dashboard_screen.dart';

class SideMenuDrawer extends StatelessWidget {
  final bool isDriverMode;
  final Function(bool) onModeChanged;

  const SideMenuDrawer({
    super.key, 
    required this.isDriverMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 1. OCEAN GRADIENT HEADER
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF006064), Color(0xFF0097A7)], // Teal Gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/user_avatar.png'),
                backgroundColor: Colors.white,
              ),
            ),
            accountName: const Text("Aryan Suratkar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: const Text("aryan@sharka.com", style: TextStyle(color: Colors.white70)),
          ),

          // 2. MENU ITEMS (Teal Icons)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(context, Icons.person, "Profile", const ProfileScreen()),
                _buildMenuItem(context, Icons.history, "Your Trips", const RideHistoryScreen()),
                _buildMenuItem(context, Icons.account_balance_wallet, "Wallet", const WalletScreen()),
                _buildMenuItem(context, Icons.bookmark, "Saved Places", const SavedPlacesScreen()),
                
                ListTile(
                  leading: const Icon(Icons.eco, color: Colors.green),
                  title: const Text("Eco Impact", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EcoDashboardScreen()));
                  },
                ),
                const Divider(),
                _buildMenuItem(context, Icons.help_outline, "Help & Support", const HelpSupportScreen()),
                _buildMenuItem(context, Icons.language, "Language", const LanguageScreen()),
                
                const Divider(),
                ListTile(
                  leading: Icon(isDriverMode ? Icons.directions_car : Icons.person_pin, color: const Color(0xFF006064)),
                  title: Text(
                    isDriverMode ? "Switch to Passenger" : "Drive with Sharka",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006064)),
                  ),
                  onTap: () {
                    onModeChanged(!isDriverMode);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // 3. LOGOUT (Coral Orange)
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFFF6F00)),
            title: const Text("Logout", style: TextStyle(color: Color(0xFFFF6F00), fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logged Out Successfully")));
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String text, Widget page) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF006064)),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}