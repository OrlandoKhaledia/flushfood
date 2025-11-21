import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

class SettingsProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  void setTheme(AppThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // Placeholder for notification prefs, default units etc.
  bool notificationsEnabled = true;

  void setNotificationsEnabled(bool v) {
    notificationsEnabled = v;
    notifyListeners();
  }
}
