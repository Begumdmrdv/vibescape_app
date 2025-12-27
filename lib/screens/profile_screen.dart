import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibescape_app/screens/login_screen.dart';
import '../services/stats_service.dart';

// GLOBAL SAYAÇLAR
int discoveriesCount = 0; // seçilen mekan sayısı
int visitedCount = 0;     // yıldız verilen mekan sayısı
int myMoodsCount = 0;     // seçilen mood sayısı

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();

    discoveriesCount = StatsService.discoveriesCount;
    visitedCount = StatsService.visitedCount;
    myMoodsCount = StatsService.myMoodsCount;
  }

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  String _userName = 'User Name'; // editlenebilir isim

  // Notifications state
  bool _appNotifications = true;
  bool _emailNotifications = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _profileImage = File(pickedFile.path);
    });
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D4F8B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Edit name',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: const InputDecoration(
              hintText: 'Enter your name',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _userName = text;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Notifications popup
  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D4F8B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'App notifications',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'General alerts and updates',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                value: _appNotifications,
                activeColor: Colors.white,
                activeTrackColor: Colors.white24,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white24,
                onChanged: (val) {
                  setState(() {
                    _appNotifications = val;
                  });
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Email notifications',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'News, tips and promotions',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                value: _emailNotifications,
                activeColor: Colors.white,
                activeTrackColor: Colors.white24,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white24,
                onChanged: (val) {
                  setState(() {
                    _emailNotifications = val;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        );
      },
    );
  }

  // SIGN OUT DİYALOĞU
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D4F8B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Sign out',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Do you really want to sign out?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // dialogu kapat
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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

                // *** EDITLENEBİLİR USER NAME ***
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _showEditNameDialog,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54, width: 1),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
                      label: 'Saved',
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
                  //ToDO: buraya geçmiş (geçmiş hareketler), izinler (veri, konum, güvenlik) ve şifre değiştirme kısmı mı koysak
                ),

                const Divider(color: Colors.white, thickness: 1),

                _ProfileMenuTile(
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  onTap: _showNotificationsDialog,
                ),

                const Divider(color: Colors.white, thickness: 1),

                _ProfileMenuTile(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  onTap: _showSignOutDialog,
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
