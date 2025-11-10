import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import 'system_state.dart';
import '../utilities/functions.dart';

class AppThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final $system = ref.watch(systemProvider);
    
    // Check if user has explicitly set a theme preference
    String? localThemeMode = await getSharedPref('x-theme-mode');
    
    if (localThemeMode != null) {
      // User has explicitly chosen a theme, respect their choice
      switch (localThemeMode) {
        case 'dark':
          return ThemeMode.dark;
        case 'light':
          return ThemeMode.light;
        case 'system':
          return ThemeMode.system;
      }
    }
    
    // No user preference found, check system settings
    if (isTrue($system['system_theme_mode_select'])) {
      // If system theme mode selection is enabled, default to system theme
      return ThemeMode.system;
    } else {
      // Fallback to the system's default from API
      return (isTrue($system['theme_mode_night'])) ? ThemeMode.dark : ThemeMode.light;
    }
  }

  void setThemeMode(ThemeMode newThemeMode) async {
    // Save user's explicit choice
    if (newThemeMode == ThemeMode.light) {
      await setSharedPref('x-theme-mode', 'light');
    } else if (newThemeMode == ThemeMode.dark) {
      await setSharedPref('x-theme-mode', 'dark');
    } else if (newThemeMode == ThemeMode.system) {
      await setSharedPref('x-theme-mode', 'system');
    }
    
    state = AsyncValue.data(newThemeMode);
  }
}

// App Theme Mode Provider
final appThemeModeProvider = AsyncNotifierProvider<AppThemeModeNotifier, ThemeMode>(() {
  return AppThemeModeNotifier();
});
