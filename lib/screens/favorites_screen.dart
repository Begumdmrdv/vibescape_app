import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/favorites_service.dart';
import '../services/places_api_service.dart';
import '../models/place.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // Foto URL üretme
  String? _photoUrl(PlacesApiService api, Place p, {int maxWidth = 400}) {
    if (p.photoRef == null || p.photoRef!.isEmpty) return null;
    return api.placePhotoUrl(photoRef: p.photoRef!, maxWidth: maxWidth);
  }

  // En iyi mood’u bul (Favorites ekranında hangi mood gösterilecek belirsiz olduğu için)
  MapEntry<String, double>? _bestMood(Place p) {
    if (p.moodScores.isEmpty) return null;
    final sorted = p.moodScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first;
  }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesService>().favorites;

    // MapScreen’de kullandığın key ile aynı (istersen tek yerde sabitleyelim)
    final api = PlacesApiService('AIzaSyCRWOtfsyFdobFs6h79dXyBhYb4fhoC8hc');

    const primaryBlue = Color(0xFF0D4F8B);

    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Favorites",
          style: TextStyle(
            fontFamily: 'Times New Roman',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: favs.isEmpty
          ? const Center(
        child: Text(
          "No favorites yet.",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Times New Roman',
            fontSize: 14,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favs.length,
        itemBuilder: (context, i) {
          final p = favs[i];
          final imgUrl = _photoUrl(api, p, maxWidth: 500);

          final best = _bestMood(p);
          final bestMoodLabel = best?.key ?? '-';
          final bestMoodScore = best?.value ?? 0;

          final google = p.googleRating?.toStringAsFixed(1) ?? '-';
          final distKm = p.distanceKm.toStringAsFixed(1);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white54, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FOTO
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 78,
                    height: 78,
                    child: imgUrl == null
                        ? Container(
                      color: Colors.black12,
                      child: const Icon(Icons.photo,
                          color: Colors.black45),
                    )
                        : Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      loadingBuilder:
                          (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          color: Colors.black12,
                          child: const Icon(Icons.broken_image,
                              color: Colors.black45),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // DETAYLAR
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.address ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Mood + Google + Distance
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment:
                        WrapCrossAlignment.center,
                        children: [
                          Text(
                            '★ $bestMoodLabel: ${bestMoodScore.toStringAsFixed(1)}/10',
                            style: const TextStyle(
                              fontFamily: 'Times New Roman',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Google: $google/5',
                            style: const TextStyle(
                              fontFamily: 'Times New Roman',
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$distKm km',
                            style: const TextStyle(
                              fontFamily: 'Times New Roman',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // SİL
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      context.read<FavoritesService>().remove(p.id);
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
