import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibescape_app/screens/profile_screen.dart';
import 'package:vibescape_app/screens/favorites_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/place.dart';
import '../services/places_api_service.dart';
import '../utils/mood_scoring.dart';
import '../services/favorites_service.dart';

class MapScreen extends StatefulWidget {
  final String? mood;

  const MapScreen({
    super.key,
    this.mood,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _placesApi =
  PlacesApiService('AIzaSyCRWOtfsyFdobFs6h79dXyBhYb4fhoC8hc');

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(41.015137, 28.979530), // Istanbul
    zoom: 12,
  );

  double _radiusKm = 15;
  GoogleMapController? _mapController;

  LatLng? _userLocation;
  Set<Circle> _circles = {};
  Set<Marker> _markers = {};

  bool _loadingPlaces = false;
  String? _placesError;

  List<Place> _places = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  String get _mood => widget.mood ?? 'Happy';

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _placesError = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _placesError = 'Location permission denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _placesError =
        'Location permission denied forever. Enable it in settings.';
      });
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final userLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _userLocation = userLatLng;
      _updateCircle();
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(userLatLng, 13),
    );

    await _loadPlaces();
  }

  void _updateCircle() {
    if (_userLocation == null) return;

    _circles = {
      Circle(
        circleId: const CircleId('radius_circle'),
        center: _userLocation!,
        radius: _radiusKm * 1000,
        fillColor: Colors.blue.withOpacity(0.2),
        strokeColor: Colors.blueAccent,
        strokeWidth: 2,
      ),
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _loadPlaces() async {
    if (_userLocation == null) return;

    setState(() {
      _loadingPlaces = true;
      _placesError = null;
    });

    try {
      final raw = await _placesApi.nearbyAttractions(
        lat: _userLocation!.latitude,
        lng: _userLocation!.longitude,
        radiusMeters: (_radiusKm * 1000).toInt(),
      );

      bool isFoodPlace(List<String> types) =>
          types.contains('restaurant') ||
              types.contains('cafe') ||
              types.contains('food') ||
              types.contains('meal_takeaway') ||
              types.contains('meal_delivery');

      final places = <Place>[];

      for (final p in raw) {
        final types = List<String>.from(p['types'] ?? []);

        if (isFoodPlace(types)) continue;

        final lat = p['lat'] as double;
        final lng = p['lng'] as double;

        final moodScores = computeMoodScores(
          types: types,
          googleRating: p['rating'] as double?,
          userRatingsTotal: p['user_ratings_total'] as int?,
          userLat: _userLocation!.latitude,
          userLng: _userLocation!.longitude,
          placeLat: lat,
          placeLng: lng,
          maxDistanceKm: _radiusKm,
        );

        final dist = haversineKm(
          _userLocation!.latitude,
          _userLocation!.longitude,
          lat,
          lng,
        );

        places.add(
          Place(
            id: p['place_id'] as String,
            name: p['name'] as String,
            lat: lat,
            lng: lng,
            types: types,
            address: p['vicinity'] as String?,
            googleRating: p['rating'] as double?,
            userRatingsTotal: p['user_ratings_total'] as int?,
            moodScores: moodScores,
            distanceKm: dist,
            photoRef: p['photo_ref'] as String?,
          ),
        );
      }

      places.sort((a, b) {
        final sa = a.moodScores[_mood] ?? 0;
        final sb = b.moodScores[_mood] ?? 0;
        return sb.compareTo(sa);
      });

      final markers = <Marker>{};

      for (int i = 0; i < places.length; i++) {
        final place = places[i];

        markers.add(
          Marker(
            markerId: MarkerId(place.id),
            position: LatLng(place.lat, place.lng),
            infoWindow: InfoWindow(
              title: place.name,
              snippet:
              'Mood: $_mood ${(place.moodScores[_mood] ?? 0).toStringAsFixed(1)}/10',
            ),
            onTap: () {
              setState(() {
                _selectedIndex = i;
              });
            },
          ),
        );
      }

      setState(() {
        _places = places;
        _markers = markers;
        _selectedIndex = 0;
        _loadingPlaces = false;
      });

      if (_places.isNotEmpty) {
        _focusOnPlace(_places[_selectedIndex]);
      }
    } catch (e) {
      setState(() {
        _placesError = e.toString();
        _loadingPlaces = false;
      });
    }
  }

  String? _photoUrl(Place p, {int maxWidth = 400}) {
    if (p.photoRef == null || p.photoRef!.isEmpty) return null;
    return _placesApi.placePhotoUrl(photoRef: p.photoRef!, maxWidth: maxWidth);
  }


  void _focusOnPlace(Place p) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(p.lat, p.lng), 14),
    );
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
                      onPressed: () async {
                        setState(() {
                          _radiusKm = tempRadius;
                          _updateCircle();
                        });
                        Navigator.pop(context);
                        await _loadPlaces();
                      },
                      child: const Text(
                        'Apply',
                        style: TextStyle(fontFamily: 'Times New Roman'),
                      ),
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

  void _suggestAlternative() {
    if (_places.isEmpty) return;

    setState(() {
      _selectedIndex = (_selectedIndex + 1) % _places.length;
    });

    _focusOnPlace(_places[_selectedIndex]);
  }

  void _saveSelected() {
    if (_places.isEmpty) return;

    discoveriesCount++;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved: ${_places[_selectedIndex].name}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D4F8B);

    final favorites = context.watch<FavoritesService>();

    final selectedPlace = _places.isEmpty ? null : _places[_selectedIndex];

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
          (_mood).toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Times New Roman',
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 220,
                child: GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  circles: _circles,
                  markers: _markers,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _openRadiusSheet,
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
            const SizedBox(height: 12),

            if (_loadingPlaces)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (_placesError != null)
              Expanded(
                child: Center(
                  child: Text(
                    _placesError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Times New Roman',
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else if (_places.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No places found in ${_radiusKm.toStringAsFixed(0)} km.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Times New Roman',
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      if (selectedPlace != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Builder(builder: (_) {
                            final place = selectedPlace!;
                            final imgUrl = _photoUrl(place, maxWidth: 500);
                            final moodScore =
                            (place.moodScores[_mood] ?? 0).toStringAsFixed(1);
                            final google =
                                place.googleRating?.toStringAsFixed(1) ?? '-';
                            final distKm = place.distanceKm.toStringAsFixed(1);
                            final isFav = favorites.isFavorite(place.id);

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: imgUrl == null
                                        ? Container(
                                      color: Colors.black12,
                                      child: const Icon(Icons.photo, color: Colors.black45),
                                    )
                                        : Image.network(
                                      imgUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.name,
                                        style: const TextStyle(
                                          fontFamily: 'Times New Roman',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        place.address ?? '',
                                        style: const TextStyle(
                                          fontFamily: 'Times New Roman',
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Mood score: $moodScore/10  •  Google: $google/5  •  $distKm km',
                                        style: const TextStyle(
                                          fontFamily: 'Times New Roman',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    favorites.toggleFavorite(place);
                                  },
                                  icon: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: _places.length,
                          itemBuilder: (context, i) {
                            final p = _places[i];
                            final isSelected = i == _selectedIndex;
                            final score =
                            (p.moodScores[_mood] ?? 0).toStringAsFixed(1);

                            final isFav = favorites.isFavorite(p.id);
                            final imgUrl = _photoUrl(p);

                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedIndex = i);
                                _focusOnPlace(p);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFF4EEDF)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(color: primaryBlue, width: 2)
                                      : null,
                                ),
                                child: Row(
                                  children: [

                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        width: 64,
                                        height: 64,
                                        child: imgUrl == null
                                            ? Container(
                                          color: Colors.black12,
                                          child: const Icon(Icons.photo, color: Colors.black45),
                                        )
                                            : Image.network(
                                          imgUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, progress) {
                                            if (progress == null) return child;
                                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                          },
                                          errorBuilder: (context, error, stack) {
                                            return Container(
                                              color: Colors.black12,
                                              child: const Icon(Icons.broken_image, color: Colors.black45),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Text(
                                        p.name,
                                        style: const TextStyle(
                                          fontFamily: 'Times New Roman',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$score/10',
                                      style: const TextStyle(
                                        fontFamily: 'Times New Roman',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Favori butonu
                                    IconButton(
                                      onPressed: () {
                                        favorites.toggleFavorite(p);
                                      },
                                      icon: Icon(
                                        isFav
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _VibeBottomNavBar(
          selectedIndex: 0,
          onSuggestAlternative: _suggestAlternative,
          onSave: _saveSelected,
        ),
      ),
    );
  }
}

class _VibeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onSuggestAlternative;
  final VoidCallback onSave;

  const _VibeBottomNavBar({
    super.key,
    this.selectedIndex = 0,
    required this.onSuggestAlternative,
    required this.onSave,
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
          top: BorderSide(color: Colors.white, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                onPressed: onSuggestAlternative,
                child: const Text(
                  'Random Selection',
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
                onPressed: onSave,
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
