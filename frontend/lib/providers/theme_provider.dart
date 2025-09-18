// File: frontend/lib/providers/theme_provider.dart
// Theme state: holds ThemeMode and toggles between light/dark.

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode mode = ThemeMode.system; // default to system preference

  void toggle() {
    // Flip between dark and light (ignores system after first toggle)
    mode = (mode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
