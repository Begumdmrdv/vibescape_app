class Place {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final double? googleRating;
  final int? userRatingsTotal;
  final String? address;
  final List<String> types;


  final Map<String, double> moodScores;
  final double distanceKm;

  Place({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.types,
    required this.moodScores,
    required this.distanceKm,
    this.googleRating,
    this.userRatingsTotal,
    this.address,
  });
}
