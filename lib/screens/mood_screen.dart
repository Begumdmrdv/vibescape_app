import 'package:flutter/material.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

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
        title: const Text(
          'HOW ARE YOU FEELING TODAY?',
          style: TextStyle(fontSize: 14),
        ),
      ),
      body: const Center(
        child: Text(
          'Mood screen here',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
