import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('lightTheme has light brightness and modern light canvas colors', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppTheme.lightBackground);
      expect(theme.cardColor, AppTheme.lightCard);
      expect(theme.colorScheme.onSurface, AppTheme.lightTextPrimary);
    });

    test('darkTheme has dark brightness and dark slate surface colors', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppTheme.darkBackground);
      expect(theme.cardColor, AppTheme.darkCard);
      expect(theme.colorScheme.primary, AppTheme.darkPrimary);
      expect(theme.colorScheme.onSurface, AppTheme.darkTextPrimary);
    });
  });
}
