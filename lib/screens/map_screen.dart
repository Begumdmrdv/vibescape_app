import 'package:flutter/material.dart';
import 'package:vibescape_app/screens/profile_screen.dart'; // discoveriesCount / visitedCount buradan geliyor
import 'package:vibescape_app/screens/mood_screen.dart';
import 'package:vibescape_app/screens/favorites_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // 👈 YENİ

class MapScreen extends StatefulWidget {
  final String? mood; // opsiyonel mood

  const MapScreen({
    super.key,
    this.mood,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double _radiusKm = 15;

  // Google Maps controller (ileride lazım olabilir)
  GoogleMapController? _mapController;

  // Başlangıç kameramız (örnek: İstanbul)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(41.015137, 28.979530), // Istanbul
    zoom: 12,
  );

  // TODO:İleride yıldız rating ekleyince burası çağırılmalı, bunu ayarlaycağız
  void _ratePlace(int stars) {
    visitedCount++;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _openRadiusSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D4F8B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        double tempRadius = _radiusKm;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select max distance',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Times New Roman',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${tempRadius.toStringAsFixed(0)} km',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Times New Roman',
                      fontSize: 14,
                    ),
                  ),
                  Slider(
                    value: tempRadius,
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: '${tempRadius.toStringAsFixed(0)} km',
                    onChanged: (value) {
                      setModalState(() {
                        tempRadius = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _radiusKm = tempRadius; // şimdilik sadece saklıyoruz
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current radius: ${_radiusKm.toStringAsFixed(0)} km',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Times New Roman',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D4F8B);

    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          (widget.mood ?? 'MAP').toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Times New Roman',
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Container(
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
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔻 SADECE ŞU BLOĞU DEĞİŞTİRDİK
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 220,
                child: GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: _onMapCreated,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
            ),
            // 🔺 Önceden burada "MAP WILL BE HERE" yazan Container vardı

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _openRadiusSheet, // slider
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: primaryBlue,
                    size: 22,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Center(
                child: Text(
                  'Buraya Norfolk / Cornwall kartları,\n'
                      'hava durumu + öneriler gelecek.\n\n'
                      'Seçilen radius: ${_radiusKm.toStringAsFixed(0)} km',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Times New Roman',
                    fontSize: 14,
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

class _VibeBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const _VibeBottomNavBar({
    super.key,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D4F8B);
    const cream = Color(0xFFF4EEDF);

    const buttonTextStyle = TextStyle(
      fontFamily: 'Times New Roman',
      fontSize: 16,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cream,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  // TODO: Suggest Alternative action
                },
                child: const Text(
                  'Suggest Alternative',
                  style: buttonTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            flex: 2,
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cream,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  // Kullanıcı bu ekrandaki bir mekanı seçip kaydecek
                  discoveriesCount++; // ProfileScreen'deki global sayaç
                  // TODO: Save action (mekanı kaydetme vs)
                },
                child: const Text(
                  'Save',
                  style: buttonTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
