import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLang = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Language", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          _buildLangOption("English"),
          _buildLangOption("Hindi"),
          _buildLangOption("Marathi"),
        ],
      ),
    );
  }

  Widget _buildLangOption(String lang) {
    return RadioListTile(
      value: lang,
      groupValue: _selectedLang,
      title: Text(lang),
      activeColor: Colors.black,
      onChanged: (val) {
        setState(() {
          _selectedLang = val.toString();
        });
      },
    );
  }
}