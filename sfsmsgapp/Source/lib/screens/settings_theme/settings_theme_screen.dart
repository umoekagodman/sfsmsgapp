import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

// Import App Files
import '../../states/apptheme_state.dart';

@RoutePage()
class SettingsThemeScreen extends StatelessWidget {
  static const routeName = 'theme';

  const SettingsThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("Appearance")),
      ),
      body: _Body(),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(appThemeModeProvider).value;
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Light Mode
              ListTile(
                onTap: () {
                  ref.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.light);
                },
                title: Text(
                  tr("Light Mode"),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                trailing: (appThemeMode == ThemeMode.light) ? const Icon(Icons.check) : null,
                leading: SvgPicture.asset(
                  'assets/images/icons/light_mode.svg',
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, BlendMode.srcIn),
                ),
              ),
              // Dark Mode
              ListTile(
                onTap: () {
                  ref.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                },
                title: Text(
                  tr("Dark Mode"),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                trailing: (appThemeMode == ThemeMode.dark) ? const Icon(Icons.check) : null,
                leading: SvgPicture.asset(
                  'assets/images/icons/dark_mode.svg',
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, BlendMode.srcIn),
                ),
              ),
              // System Mode
              ListTile(
                onTap: () async {
                  ref.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.system);
                },
                title: Text(
                  tr("System Default"),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    tr("Adjust your theme based on your device's system settings"),
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                trailing: (appThemeMode == ThemeMode.system) ? const Icon(Icons.check) : null,
                leading: SvgPicture.asset(
                  'assets/images/icons/system_mode.svg',
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
