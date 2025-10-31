import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import 'system_state.dart';
import '../utilities/functions.dart';

class AppThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final $system = ref.watch(systemProvider);
    var defaultThemeMode = (isTrue($system['theme_mode_night'])) ? ThemeMode.dark : ThemeMode.light;
    if (isTrue($system['system_theme_mode_select'])) {
      String? localThemeMode = await getSharedPref('x-theme-mode');
      if (localThemeMode != null) {
        switch (localThemeMode) {
          case 'dark':
            defaultThemeMode = ThemeMode.dark;
            break;
          case 'light':
            defaultThemeMode = ThemeMode.light;
            break;
          case 'system':
            defaultThemeMode = ThemeMode.system;
            break;
        }
      }
    }
    return defaultThemeMode;
  }

  void setThemeMode(ThemeMode newThemeMode) async {
    if (newThemeMode == ThemeMode.light) await setSharedPref('x-theme-mode', 'light');
    if (newThemeMode == ThemeMode.dark) await setSharedPref('x-theme-mode', 'dark');
    if (newThemeMode == ThemeMode.system) await setSharedPref('x-theme-mode', 'system');
    state = AsyncValue.data(newThemeMode);
  }
}

// App Theme Mode Provider
final appThemeModeProvider = AsyncNotifierProvider<AppThemeModeNotifier, ThemeMode>(() {
  return AppThemeModeNotifier();
});
