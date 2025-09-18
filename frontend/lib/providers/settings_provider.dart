// File: frontend/lib/providers/settings_provider.dart
// App settings: exposes a daily summary/reminder flag.

import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _dailySummaryEnabled = false;

  bool get dailySummaryEnabled => _dailySummaryEnabled;

  void setDailySummary(bool value) {
    if (_dailySummaryEnabled == value) return;
    _dailySummaryEnabled = value;
    notifyListeners();
  }
}
