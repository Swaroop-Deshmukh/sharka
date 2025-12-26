import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State for toggles
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile & Settings", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. PROFILE HEADER
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text("User Name", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text("+91 98765 43210", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. ACCOUNT DETAILS
            _buildSectionHeader("Account"),
            _buildListTile(Icons.person_outline, "Edit Profile", null),
            _buildListTile(Icons.lock_outline, "Change Password", null),
            _buildListTile(Icons.privacy_tip_outlined, "Privacy Policy", null),

            const SizedBox(height: 20),

            // 3. PREFERENCES
            _buildSectionHeader("Preferences"),
            _buildSwitchTile(Icons.notifications_outlined, "Notifications", _notificationsEnabled, (val) {
              setState(() => _notificationsEnabled = val);
            }),
            _buildSwitchTile(Icons.dark_mode_outlined, "Dark Mode", _darkModeEnabled, (val) {
              setState(() => _darkModeEnabled = val);
            }),
            _buildListTile(Icons.language, "Language", "English"),

            const SizedBox(height: 20),

            // 4. SAFETY (Startup Feature)
            _buildSectionHeader("Safety"),
            _buildListTile(Icons.contact_phone_outlined, "Emergency Contacts", "2 Added"),
            _buildListTile(Icons.share_location, "Share Live Location", null),

            const SizedBox(height: 30),

            // 5. LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  // Logout Logic will go here
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String? trailing) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: trailing != null 
          ? Text(trailing, style: const TextStyle(color: Colors.grey)) 
          : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Switch(
        value: value, 
        activeColor: Colors.black,
        onChanged: onChanged,
      ),
    );
  }
}