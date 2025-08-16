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
