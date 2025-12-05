import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static const _keyDiscoveries = 'discoveriesCount';
  static const _keyVisited = 'visitedCount';
  static const _keyMoods = 'myMoodsCount';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static int get discoveriesCount => _prefs.getInt(_keyDiscoveries) ?? 0;
  static int get visitedCount => _prefs.getInt(_keyVisited) ?? 0;
  static int get myMoodsCount => _prefs.getInt(_keyMoods) ?? 0;

  static Future<void> setDiscoveries(int value) async {
    await _prefs.setInt(_keyDiscoveries, value);
  }

  static Future<void> setVisited(int value) async {
    await _prefs.setInt(_keyVisited, value);
  }

  static Future<void> setMyMoods(int value) async {
    await _prefs.setInt(_keyMoods, value);
  }

  static Future<void> incrementMoods() async {
    final newValue = myMoodsCount + 1;
    await _prefs.setInt(_keyMoods, newValue);
  }

}
