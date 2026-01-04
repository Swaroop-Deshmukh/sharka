import 'package:flutter/material.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';
import 'ride_history_screen.dart';
import 'saved_places_screen.dart';
import 'help_support_screen.dart';
import 'language_screen.dart';

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
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage('assets/user_avatar.png'),
              backgroundColor: Colors.white,
            ),
            accountName: const Text("Swaroop Deshmukh", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("swaroop@sharka.com"),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.black),
                  title: const Text("Profile"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.black),
                  title: const Text("Your Trips"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RideHistoryScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: Colors.black),
                  title: const Text("Wallet"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark, color: Colors.black),
                  title: const Text("Saved Places"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedPlacesScreen()));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help, color: Colors.black),
                  title: const Text("Help & Support"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.black),
                  title: const Text("Language"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageScreen()));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(isDriverMode ? Icons.directions_car : Icons.person_pin, color: Colors.green),
                  title: Text(
                    isDriverMode ? "Switch to Passenger" : "Drive with Sharka",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  onTap: () {
                    onModeChanged(!isDriverMode);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logged Out Successfully"))
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}