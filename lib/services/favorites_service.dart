import 'package:flutter/foundation.dart';
import '../models/place.dart';

class FavoritesService extends ChangeNotifier {
  final Map<String, Place> _favoritesById = {};

  List<Place> get favorites => _favoritesById.values.toList();

  bool isFavorite(String placeId) => _favoritesById.containsKey(placeId);

  void toggleFavorite(Place place) {
    if (isFavorite(place.id)) {
      _favoritesById.remove(place.id);
    } else {
      _favoritesById[place.id] = place;
    }
    notifyListeners();
  }

  void remove(String placeId) {
    _favoritesById.remove(placeId);
    notifyListeners();
  }

  void clear() {
    _favoritesById.clear();
    notifyListeners();
  }
}
