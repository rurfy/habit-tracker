import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String habitsKey = 'habits_v1';

  Future<void> save(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(habitsKey, jsonString);
  }

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(habitsKey);
  }
}
