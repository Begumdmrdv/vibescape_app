import 'dart:math';

double clamp(double v, double minV, double maxV) => v < minV ? minV : (v > maxV ? maxV : v);

double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = (lat2 - lat1) * pi / 180;
  final dLon = (lon2 - lon1) * pi / 180;
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
          sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return r * c;
}

double baseScoreForMood(List<String> types, String mood) {
  bool has(String t) => types.contains(t);

  switch (mood) {
    case 'Adventurous':
      if (has('natural_feature') || has('park')) return 8.5;
      if (has('tourist_attraction')) return 8.0;
      if (has('amusement_park') || has('zoo') || has('aquarium')) return 7.5;
      return 6.0;

    case 'Energetic':
      if (has('amusement_park')) return 9.0;
      if (has('zoo') || has('aquarium')) return 8.0;
      if (has('tourist_attraction')) return 7.0;
      return 6.0;

    case 'Relaxed':
      if (has('park') || has('natural_feature')) return 9.0;
      if (has('tourist_attraction')) return 7.0;
      if (has('museum') || has('art_gallery')) return 7.5;
      return 6.0;

    case 'Curious':
      if (has('museum') || has('art_gallery')) return 9.0;
      if (has('tourist_attraction')) return 7.5;
      if (has('library')) return 8.0;
      return 6.5;

    case 'Romantic':
      if (has('tourist_attraction')) return 7.5;
      if (has('park')) return 7.5;
      if (has('art_gallery')) return 7.0;
      return 6.0;

    case 'Happy':
      if (has('amusement_park') || has('zoo') || has('aquarium')) return 9.0;
      if (has('tourist_attraction')) return 7.5;
      return 6.5;

    default:
      return 6.5;
  }
}

double popularityBonus(double? googleRating, int? total) {
  final r = googleRating ?? 0.0; // 0-5
  final t = total ?? 0;

  final ratingPart = (r / 5.0) * 6.0;

  final countPart = t <= 0 ? 0.0 : clamp(log(t + 1) / ln10, 0, 4);

  return clamp((ratingPart + countPart), 0, 10);
}

Map<String, double> computeMoodScores({
  required List<String> types,
  required double? googleRating,
  required int? userRatingsTotal,
  required double userLat,
  required double userLng,
  required double placeLat,
  required double placeLng,
  required double maxDistanceKm,
}) {
  final distKm = haversineKm(userLat, userLng, placeLat, placeLng);
  final distPenalty = clamp((distKm / maxDistanceKm) * 2.0, 0, 2.0);

  final pop = popularityBonus(googleRating, userRatingsTotal);
  final popBonus = (pop / 10.0) * 1.5; // max +1.5

  const moods = ['Happy','Energetic','Relaxed','Romantic','Adventurous','Curious'];

  final map = <String, double>{};
  for (final m in moods) {
    final base = baseScoreForMood(types, m);
    final score = clamp(base + popBonus - distPenalty, 0, 10);
    map[m] = score;
  }
  return map;
}
