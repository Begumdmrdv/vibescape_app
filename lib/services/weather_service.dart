import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherInfo {
  final double tempC;
  final int weatherCode;

  WeatherInfo({
    required this.tempC,
    required this.weatherCode,
  });
}

class WeatherService {
  // basit cache (10 dk)
  static final Map<String, ({WeatherInfo info, DateTime ts})> _cache = {};

  static const Duration _ttl = Duration(minutes: 10);

  static String _key(double lat, double lng) {
    // aynı noktalar için stabil olsun diye yuvarlıyoruz
    final la = lat.toStringAsFixed(3);
    final lo = lng.toStringAsFixed(3);
    return '$la,$lo';
  }

  static Future<WeatherInfo?> getCurrent(double lat, double lng) async {
    final key = _key(lat, lng);

    final cached = _cache[key];
    if (cached != null) {
      final age = DateTime.now().difference(cached.ts);
      if (age < _ttl) return cached.info;
    }

    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
          '?latitude=$lat&longitude=$lng'
          '&current_weather=true',
    );

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final current = json['current_weather'] as Map<String, dynamic>?;

      if (current == null) return null;

      final temp = (current['temperature'] as num).toDouble();
      final code = (current['weathercode'] as num).toInt();

      final info = WeatherInfo(tempC: temp, weatherCode: code);

      _cache[key] = (info: info, ts: DateTime.now());
      return info;
    } catch (_) {
      return null;
    }
  }

  // Weather code -> emoji (basit)
  static String emojiFor(int code) {
    if (code == 0) return '☀️';
    if (code == 1 || code == 2) return '🌤️';
    if (code == 3) return '☁️';
    if (code == 45 || code == 48) return '🌫️';
    if ((code >= 51 && code <= 57) || (code >= 61 && code <= 67)) return '🌧️';
    if (code >= 71 && code <= 77) return '❄️';
    if (code >= 80 && code <= 82) return '🌦️';
    if (code >= 95) return '⛈️';
    return '🌡️';
  }
}
