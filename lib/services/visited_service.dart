import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place.dart';

class VisitSurvey {
  final String selectedMood;
  final Map<String, double> feltScores;
  final DateTime createdAt;

  VisitSurvey({
    required this.selectedMood,
    required this.feltScores,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'selectedMood': selectedMood,
    'feltScores': feltScores,
    'createdAt': createdAt.toIso8601String(),
  };

  factory VisitSurvey.fromJson(Map<String, dynamic> json) => VisitSurvey(
    selectedMood: json['selectedMood'] as String? ?? 'Happy',
    feltScores: (json['feltScores'] as Map? ?? {})
        .map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );
}

class VisitedService extends ChangeNotifier {
  static const _kVisitedPlaces = 'visited_places_v1';
  static const _kVisitedSurveys = 'visited_surveys_v1';

  late SharedPreferences _prefs;
  bool _ready = false;

  final Map<String, Place> _visitedById = {};
  final Map<String, VisitSurvey> _surveyByPlaceId = {};

  bool get isReady => _ready;

  List<Place> get visited => _visitedById.values.toList();

  bool isVisited(String placeId) => _visitedById.containsKey(placeId);

  VisitSurvey? surveyOf(String placeId) => _surveyByPlaceId[placeId];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFromPrefs();
    _ready = true;
    notifyListeners();
  }

  Future<void> toggleVisited(Place place) async {
    if (isVisited(place.id)) {
      _visitedById.remove(place.id);
      _surveyByPlaceId.remove(place.id);
    } else {
      _visitedById[place.id] = place;
    }
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> setSurvey(String placeId, VisitSurvey survey) async {
    _surveyByPlaceId[placeId] = survey;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> removeVisited(String placeId) async {
    _visitedById.remove(placeId);
    _surveyByPlaceId.remove(placeId);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> clear() async {
    _visitedById.clear();
    _surveyByPlaceId.clear();
    await _prefs.remove(_kVisitedPlaces);
    await _prefs.remove(_kVisitedSurveys);
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    // places
    final placesJson = _visitedById.values.map((p) => p.toJson()).toList();
    await _prefs.setString(_kVisitedPlaces, jsonEncode(placesJson));

    // surveys
    final surveysJson = _surveyByPlaceId.map(
          (placeId, survey) => MapEntry(placeId, survey.toJson()),
    );
    await _prefs.setString(_kVisitedSurveys, jsonEncode(surveysJson));
  }

  Future<void> _loadFromPrefs() async {
    _visitedById.clear();
    _surveyByPlaceId.clear();

    // places
    final placesStr = _prefs.getString(_kVisitedPlaces);
    if (placesStr != null && placesStr.isNotEmpty) {
      final decoded = jsonDecode(placesStr);
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final place = Place.fromJson(item);
            _visitedById[place.id] = place;
          } else if (item is Map) {
            final place = Place.fromJson(item.cast<String, dynamic>());
            _visitedById[place.id] = place;
          }
        }
      }
    }

    // surveys
    final surveysStr = _prefs.getString(_kVisitedSurveys);
    if (surveysStr != null && surveysStr.isNotEmpty) {
      final decoded = jsonDecode(surveysStr);
      if (decoded is Map) {
        decoded.forEach((key, value) {
          final placeId = key.toString();
          if (value is Map<String, dynamic>) {
            _surveyByPlaceId[placeId] = VisitSurvey.fromJson(value);
          } else if (value is Map) {
            _surveyByPlaceId[placeId] =
                VisitSurvey.fromJson(value.cast<String, dynamic>());
          }
        });
      }
    }
  }
}
