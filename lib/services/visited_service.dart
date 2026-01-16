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

  factory VisitSurvey.fromJson(Map<String, dynamic> json) {
    final raw = (json['feltScores'] as Map).cast<String, dynamic>();
    return VisitSurvey(
      selectedMood: json['selectedMood'] as String,
      feltScores: raw.map((k, v) => MapEntry(k, (v as num).toDouble())),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class VisitedService extends ChangeNotifier {
  static const _prefsKey = 'visitedPlaces_v1';

  final Map<String, Place> _visitedById = {};
  final Map<String, VisitSurvey> _surveyByPlaceId = {};

  List<Place> get visited => _visitedById.values.toList();

  bool isVisited(String placeId) => _visitedById.containsKey(placeId);

  VisitSurvey? surveyOf(String placeId) => _surveyByPlaceId[placeId];

  // --- PERSISTENCE ---
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      final visitedMap = (decoded['visited'] as Map? ?? {}).cast<String, dynamic>();
      final surveyMap = (decoded['surveys'] as Map? ?? {}).cast<String, dynamic>();

      _visitedById.clear();
      _surveyByPlaceId.clear();

      visitedMap.forEach((placeId, placeJson) {
        _visitedById[placeId] = Place.fromJson((placeJson as Map).cast<String, dynamic>());
      });

      surveyMap.forEach((placeId, surveyJson) {
        _surveyByPlaceId[placeId] =
            VisitSurvey.fromJson((surveyJson as Map).cast<String, dynamic>());
      });

      notifyListeners();
    } catch (_) {
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    final payload = {
      'visited': _visitedById.map((k, v) => MapEntry(k, v.toJson())),
      'surveys': _surveyByPlaceId.map((k, v) => MapEntry(k, v.toJson())),
    };

    await prefs.setString(_prefsKey, jsonEncode(payload));
  }

  // --- ACTIONS ---
  Future<void> toggleVisited(Place place) async {
    if (isVisited(place.id)) {
      _visitedById.remove(place.id);
      _surveyByPlaceId.remove(place.id);
    } else {
      _visitedById[place.id] = place;
    }
    await _save();
    notifyListeners();
  }

  Future<void> setSurvey(String placeId, VisitSurvey survey) async {
    _surveyByPlaceId[placeId] = survey;
    await _save();
    notifyListeners();
  }

  Future<void> removeVisited(String placeId) async {
    _visitedById.remove(placeId);
    _surveyByPlaceId.remove(placeId);
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _visitedById.clear();
    _surveyByPlaceId.clear();
    await _save();
    notifyListeners();
  }
}
