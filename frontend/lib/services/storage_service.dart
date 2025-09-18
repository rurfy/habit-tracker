// File: frontend/lib/services/storage_service.dart
// Local persistence via SharedPreferences; stores habits JSON under a versioned key.

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String habitsKey = 'habits_v1'; // versioned storage key

  Future<void> save(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(habitsKey, jsonString); // write JSON
  }

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(habitsKey); // read JSON (null if missing)
  }

  Future<void> delete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(habitsKey); // remove persisted data
  }
}
