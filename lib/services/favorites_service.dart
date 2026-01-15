import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place.dart';

class FavoritesService extends ChangeNotifier {
  static const _prefsKey = 'favorites_places';

  final Map<String, Place> _favoritesById = {};
  bool _loaded = false;

  List<Place> get favorites => _favoritesById.values.toList();
  bool isFavorite(String placeId) => _favoritesById.containsKey(placeId);

  FavoritesService() {
    _load(); // app açılınca otomatik yükle
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      for (final item in list) {
        final place = Place.fromJson(item); // ✅ Place.dart içinde olmalı
        _favoritesById[place.id] = place;
      }
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    if (!_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final list = _favoritesById.values.map((p) => p.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(list));
  }

  Future<void> toggleFavorite(Place place) async {
    if (isFavorite(place.id)) {
      _favoritesById.remove(place.id);
    } else {
      _favoritesById[place.id] = place;
    }
    await _save();
    notifyListeners();
  }

  Future<void> remove(String placeId) async {
    _favoritesById.remove(placeId);
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _favoritesById.clear();
    await _save();
    notifyListeners();
  }
}
