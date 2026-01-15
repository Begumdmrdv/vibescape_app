class Place {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final double? googleRating;
  final int? userRatingsTotal;
  final String? address;
  final List<String> types;
  final String? photoRef;


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
    required this.photoRef,

    this.googleRating,
    this.userRatingsTotal,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'types': types,
      'address': address,
      'googleRating': googleRating,
      'userRatingsTotal': userRatingsTotal,
      'moodScores': moodScores,
      'distanceKm': distanceKm,
      'photoRef': photoRef,
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      types: List<String>.from(json['types'] ?? []),
      address: json['address'],
      googleRating: (json['googleRating'] as num?)?.toDouble(),
      userRatingsTotal: json['userRatingsTotal'],
      moodScores: (json['moodScores'] as Map<String, dynamic>?)
          ?.map((key, value) =>
          MapEntry(key, (value as num).toDouble())) ??
          {},
      distanceKm: (json['distanceKm'] as num).toDouble(),
      photoRef: json['photoRef'],
    );
  }




}
