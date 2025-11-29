import 'package:flutter/material.dart';
import 'package:vibescape_app/screens/profile_screen.dart';
import 'package:vibescape_app/screens/map_screen.dart';
import 'package:vibescape_app/screens/mood_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

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
          'FAVORITES',
          style: TextStyle(fontSize: 14),
        ),
      ),
      body: const Center(
        child: Text(
          'FAVORITES screen here',
          style: TextStyle(color: Colors.white),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: const _VibeBottomNavBar(
          selectedIndex: 0,
        ),
      ),

    );
  }
}

class _VibeBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const _VibeBottomNavBar({
    super.key,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D4F8B);

    TextStyle labelStyle(int index) => const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontFamily: 'Times New Roman',
      fontWeight: FontWeight.w600,
    );

    return Container(
      decoration: const BoxDecoration(
        color: primaryBlue,
        border: const Border(
          top: BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                // TODO: Home'a git
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoodScreen(),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.home,
                    size: 28,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Text('Home', style: labelStyle(0)),
                ],
              ),
            ),
          ),

          Expanded(
            child: InkWell(
              onTap: () {
                // TODO: Plans'e git
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapScreen(),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.star,
                      size: 22,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Plans', style: labelStyle(1)),
                ],
              ),
            ),
          ),

          Expanded(
            child: InkWell(
              onTap: () {
                // TODO: Favorites'a git
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite,
                    size: 28,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Text('Favorites', style: labelStyle(2)),
                ],
              ),
            ),
          ),

          Expanded(
            child: InkWell(
              onTap: () {
                // TODO: Profile’a git
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 26,
                        color: Color(0xFF0D4F8B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Profile', style: labelStyle(3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}