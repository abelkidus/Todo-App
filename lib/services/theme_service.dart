import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;

  ThemeService._internal();

  static const String _boxKey = 'mybox';
  static const String _themeModeKey = 'THEME_MODE';

  final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  void init([Box? box]) {
    final activeBox =
        box ?? (Hive.isBoxOpen(_boxKey) ? Hive.box(_boxKey) : null);
    if (activeBox != null) {
      final savedMode = activeBox.get(_themeModeKey, defaultValue: 'light');
      if (savedMode == 'dark') {
        themeModeNotifier.value = ThemeMode.dark;
      } else {
        themeModeNotifier.value = ThemeMode.light;
      }
    }
  }

  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  void toggleTheme([Box? box]) {
    final newMode = themeModeNotifier.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    themeModeNotifier.value = newMode;

    final activeBox =
        box ?? (Hive.isBoxOpen(_boxKey) ? Hive.box(_boxKey) : null);
    if (activeBox != null) {
      activeBox.put(
          _themeModeKey, newMode == ThemeMode.dark ? 'dark' : 'light');
    }
  }

  void setThemeMode(ThemeMode mode, [Box? box]) {
    themeModeNotifier.value = mode;
    final activeBox =
        box ?? (Hive.isBoxOpen(_boxKey) ? Hive.box(_boxKey) : null);
    if (activeBox != null) {
      activeBox.put(
          _themeModeKey, mode == ThemeMode.dark ? 'dark' : 'light');
    }
  }
}
