import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesApiService {
  final String apiKey;
  PlacesApiService(this.apiKey);

  Future<List<Map<String, dynamic>>> nearbyAttractions({
    required double lat,
    required double lng,
    required int radiusMeters,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=$lat,$lng'
          '&radius=$radiusMeters'
          '&type=tourist_attraction'
          '&keyword=museum|park|gallery|zoo|aquarium|landmark|viewpoint|nature'
          '&key=$apiKey',
    );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Places API failed: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    final status = data['status'];
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      final err = data['error_message'];
      throw Exception('Places API status: $status ${err ?? ""}');
    }

    final results = (data['results'] as List<dynamic>? ?? []);

    return results.map<Map<String, dynamic>>((p) {
      final loc = p['geometry']['location'];
      return {
        'place_id': p['place_id'],
        'name': p['name'],
        'lat': (loc['lat'] as num).toDouble(),
        'lng': (loc['lng'] as num).toDouble(),
        'rating': (p['rating'] as num?)?.toDouble(),
        'user_ratings_total': (p['user_ratings_total'] as num?)?.toInt(),
        'vicinity': p['vicinity'],
        'types': List<String>.from(p['types'] ?? []),
      };
    }).toList();
  }
}
