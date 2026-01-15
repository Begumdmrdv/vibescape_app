import 'package:flutter/foundation.dart';
import '../models/place.dart';

class VisitSurvey {
  final String selectedMood; // kullanıcı bu mekanı hangi mood ile seçti
  final Map<String, double> feltScores; // mood -> 0..10
  final DateTime createdAt;

  VisitSurvey({
    required this.selectedMood,
    required this.feltScores,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class VisitedService extends ChangeNotifier {
  final Map<String, Place> _visitedById = {};
  final Map<String, VisitSurvey> _surveyByPlaceId = {};

  List<Place> get visited => _visitedById.values.toList();

  bool isVisited(String placeId) => _visitedById.containsKey(placeId);

  VisitSurvey? surveyOf(String placeId) => _surveyByPlaceId[placeId];

  void toggleVisited(Place place) {
    if (isVisited(place.id)) {
      _visitedById.remove(place.id);
      _surveyByPlaceId.remove(place.id);
    } else {
      _visitedById[place.id] = place;
    }
    notifyListeners();
  }

  void setSurvey(String placeId, VisitSurvey survey) {
    _surveyByPlaceId[placeId] = survey;
    notifyListeners();
  }

  void removeVisited(String placeId) {
    _visitedById.remove(placeId);
    _surveyByPlaceId.remove(placeId);
    notifyListeners();
  }

  void clear() {
    _visitedById.clear();
    _surveyByPlaceId.clear();
    notifyListeners();
  }
}
