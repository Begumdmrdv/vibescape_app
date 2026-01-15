import 'package:flutter/material.dart';
import 'package:vibescape_app/screens/favorites_screen.dart';
import 'package:vibescape_app/screens/profile_screen.dart'; // myMoodsCount buradan geliyor
import 'package:vibescape_app/screens/map_screen.dart';
import '../services/stats_service.dart';
import 'visits_screen.dart';


class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D4F8B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D4F8B),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'HOME',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            const Text(
              'HOW ARE YOU\nFEELING TODAY?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 28),

            Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    myMoodsCount++; // <-- CHANGED
                    await StatsService.setMyMoods(myMoodsCount);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const MapScreen(mood: 'Happy'),
                      ),
                    );
                  },
                  child: _MoodItem(label: 'Happy', imagePath: 'assets/images/happy.jpg'),
                ),

                InkWell(
                  onTap: () async {
                    myMoodsCount++; // <-- CHANGED
                    await StatsService.setMyMoods(myMoodsCount);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const MapScreen(mood: 'Energetic'),
                      ),
                    );
                  },
                  child: _MoodItem(label: 'Energetic', imagePath: 'assets/images/energetic.jpg'),
                ),

                InkWell(
                  onTap: () async {
                    myMoodsCount++; // <-- CHANGED
                    await StatsService.setMyMoods(myMoodsCount);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const MapScreen(mood: 'Relaxed'),
                      ),
                    );
                  },
                  child:
                  _MoodItem(label: 'Relaxed', imagePath: 'assets/images/relaxed.jpg'),
                ),

                InkWell(
                  onTap: () async {
                    myMoodsCount++; // <-- CHANGED
                    await StatsService.setMyMoods(myMoodsCount);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const MapScreen(mood: 'Romantic'),
                      ),
                    );
                  },
                  child: _MoodItem(label: 'Romantic', imagePath: 'assets/images/romantic.jpg'),
                ),

                InkWell(
                  onTap: () async {
                    myMoodsCount++; // <-- CHANGED
                    await StatsService.setMyMoods(myMoodsCount);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const MapScreen(mood: 'Adventurous'),
                      ),
                    );
                  },
                  child: _MoodItem(label: 'Adventurous', imagePath: 'assets/images/adventurous.jpg'),
                ),

                InkWell(
                  onTap: () async {
                    myMoodsCount++; // <-- CHANGED
                    await StatsService.setMyMoods(myMoodsCount);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const MapScreen(mood: 'Curious'),
                      ),
                    );
                  },
                  child:
                  _MoodItem(label: 'Curious', imagePath: 'assets/images/curious.jpg'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4EEDF),
                  foregroundColor: const Color(0xFF0D4F8B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () async {
                  const moods = [
                    'Happy',
                    'Energetic',
                    'Relaxed',
                    'Romantic',
                    'Romantic',
                    'Adventurous',
                    'Curious',
                  ];

                  final millis =
                      DateTime.now().millisecondsSinceEpoch;
                  final index = millis % moods.length;
                  final randomMood = moods[index];

                  myMoodsCount++; // <-- CHANGED (random mood seçince de +1)
                  await StatsService.setMyMoods(myMoodsCount);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MapScreen(mood: randomMood),
                    ),
                  );
                },
                child: const Text(
                  'Pick Random',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: _VibeBottomNavBar(
          selectedIndex: 0,
        ),
      ),
    );
  }
}

class _MoodItem extends StatelessWidget {
  final String label;
  final String imagePath;

  const _MoodItem({
    super.key,
    required this.label,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFF4EEDF);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(16),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Times New Roman',
          ),
        ),
      ],
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
        border: Border(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VisitsScreen(),
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
                  Text('Visits', style: labelStyle(1)),
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
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
