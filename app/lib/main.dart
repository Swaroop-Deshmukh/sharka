import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/screens/login_screen.dart'; // This import works now!

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sharka',
      debugShowCheckedModeBanner: false,
      
      // --- THE NEW "SHARKA" THEME ---
      theme: ThemeData(
        useMaterial3: true,
        
        // 1. Color Palette (Ocean Tech)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006064), // Cyan/Teal Base
          primary: const Color(0xFF006064),   // Deep Teal
          secondary: const Color(0xFFFF6F00), // Coral Orange (Contrast)
          surface: const Color(0xFFF5F9FA),   // Very light blue-grey background
        ),

        // 2. Typography (Modern)
        textTheme: GoogleFonts.poppinsTextTheme(),

        // 3. Input Fields (Soft Grey filled)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          prefixIconColor: const Color(0xFF006064),
        ),

        // 4. Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006064),
            foregroundColor: Colors.white,
            elevation: 5,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}