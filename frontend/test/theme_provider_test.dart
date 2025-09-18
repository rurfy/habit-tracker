// File: frontend/test/theme_provider_test.dart
// ThemeProvider: toggles between dark and light.

import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_habits/providers/theme_provider.dart';

void main() {
  test('Theme toggle switches between dark and light', () {
    final p = ThemeProvider();
    final initial = p.mode;
    p.toggle();
    expect(p.mode == initial, isFalse);
  });
}
