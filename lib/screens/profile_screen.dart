import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// GLOBAL SAYAÇLAR
int discoveriesCount = 0; // seçilen mekan sayısı
int visitedCount = 0;     // 5 yıldız verilen mekan sayısı
int myMoodsCount = 0;     // seçilen mood sayısı

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    // İstersen burayı ImageSource.camera yapabilirsin
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _profileImage = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF0D4F8B);

    return Scaffold(
      backgroundColor: blue,
      appBar: AppBar(
        backgroundColor: blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // *** EDITLENEBİLİR PROFİL FOTO ***
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: _profileImage != null
                            ? ClipOval(
                          child: Image.file(
                            _profileImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Center(
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: blue,
                          ),
                        ),
                      ),
                      // küçük kamera ikonu
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: blue,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'User Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 32),

                // sayaçların profilde gösterildiği yer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ProfileStat(
                      value: discoveriesCount.toString(),
                      label: 'Discoveries',
                    ),
                    _ProfileStat(
                      value: visitedCount.toString(),
                      label: 'Visited',
                    ),
                    _ProfileStat(
                      value: myMoodsCount.toString(),
                      label: 'My Moods',
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                const Divider(color: Colors.white, thickness: 1),

                _ProfileMenuTile(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {},
                ),

                const Divider(color: Colors.white, thickness: 1),

                _ProfileMenuTile(
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  onTap: () {},
                ),

                const Divider(color: Colors.white, thickness: 1),

                _ProfileMenuTile(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  onTap: () {},
                ),

                const Divider(color: Colors.white, thickness: 1),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
