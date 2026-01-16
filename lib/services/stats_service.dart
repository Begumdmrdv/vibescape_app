import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static const _keyDiscoveries = 'discoveriesCount';
  static const _keyVisited = 'visitedCount';
  static const _keyMoodsTotal = 'myMoodsCount';
  static const _keyMoodCounts = 'moodCounts';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static int get discoveriesCount => _prefs.getInt(_keyDiscoveries) ?? 0;
  static int get visitedCount => _prefs.getInt(_keyVisited) ?? 0;
  static int get myMoodsCount => _prefs.getInt(_keyMoodsTotal) ?? 0;

  static Map<String, int> get moodCounts {
    final raw = _prefs.getString(_keyMoodCounts);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  static Future<void> setDiscoveries(int value) async {
    await _prefs.setInt(_keyDiscoveries, value);
  }

  static Future<void> setVisited(int value) async {
    await _prefs.setInt(_keyVisited, value);
  }

  static Future<void> setMyMoods(int value) async {
    await _prefs.setInt(_keyMoodsTotal, value);
  }

  static Future<void> incrementDiscoveries() async {
    await _prefs.setInt(_keyDiscoveries, discoveriesCount + 1);
  }

  static Future<void> setVisitedCount(int value) async {
    await _prefs.setInt(_keyVisited, value);
  }

  static Future<void> _setMoodCounts(Map<String, int> map) async {
    await _prefs.setString(_keyMoodCounts, jsonEncode(map));
  }

  static Future<void> incrementMood(String mood) async {
    await _prefs.setInt(_keyMoodsTotal, myMoodsCount + 1);

    final current = moodCounts;
    current[mood] = (current[mood] ?? 0) + 1;
    await _setMoodCounts(current);
  }
}
