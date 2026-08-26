import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/theme_service.dart';

void main() {
  group('ThemeService Tests', () {
    late ThemeService service;

    setUp(() {
      service = ThemeService();
      service.themeModeNotifier.value = ThemeMode.light;
    });

    test('initial theme is light and isDarkMode returns false', () {
      expect(service.themeModeNotifier.value, ThemeMode.light);
      expect(service.isDarkMode, isFalse);
    });

    test('toggleTheme alternates between dark and light modes', () {
      service.toggleTheme();
      expect(service.themeModeNotifier.value, ThemeMode.dark);
      expect(service.isDarkMode, isTrue);

      service.toggleTheme();
      expect(service.themeModeNotifier.value, ThemeMode.light);
      expect(service.isDarkMode, isFalse);
    });

    test('setThemeMode directly updates mode', () {
      service.setThemeMode(ThemeMode.dark);
      expect(service.themeModeNotifier.value, ThemeMode.dark);
      expect(service.isDarkMode, isTrue);

      service.setThemeMode(ThemeMode.light);
      expect(service.themeModeNotifier.value, ThemeMode.light);
      expect(service.isDarkMode, isFalse);
    });
  });
}
