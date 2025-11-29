import 'package:flutter/material.dart';
import 'package:vibescape_app/screens/favorites_screen.dart';
import 'package:vibescape_app/screens/profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D4F8B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D4F8B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'PROFILE screen here',
          style: TextStyle(color: Colors.white),
        ),
      ),

    );
  }
}
