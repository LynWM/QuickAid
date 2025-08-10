import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  bool isDarkMode = false;

  ThemeMode get currentTheme => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  get themeMode => null;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
