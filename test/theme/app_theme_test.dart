import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('lightTheme has light brightness and signature yellow background', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, Colors.yellow[200]);
      expect(theme.cardColor, Colors.yellow);
      expect(theme.colorScheme.onSurface, Colors.black87);
    });

    test('darkTheme has dark brightness and dark surface colors', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
      expect(theme.cardColor, const Color(0xFF1E1E1E));
      expect(theme.colorScheme.primary, Colors.amber);
      expect(theme.colorScheme.onSurface, Colors.white);
    });
  });
}
