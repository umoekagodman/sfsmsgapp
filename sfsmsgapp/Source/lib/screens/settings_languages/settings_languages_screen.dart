import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import '../../states/system_state.dart';
import '../../utilities/functions.dart';

@RoutePage()
class SettingsLanguagesScreen extends ConsumerWidget {
  static const routeName = 'languages';

  const SettingsLanguagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final $system = ref.watch(systemProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("Language")),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (var language in $system['languages'].values)
                ListTile(
                  onTap: () async {
                    final code = language['code'].split('_');
                    await context.setLocale(Locale(code[0], code[1].toString().toUpperCase()));
                    await setSharedPref('x-lang', language['code']);
                  },
                  title: Text(
                    language['title'],
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  trailing: (context.locale.languageCode == language['code'].split('_')[0] &&
                          context.locale.countryCode == language['code'].split('_')[1].toUpperCase())
                      ? const Icon(Icons.check)
                      : null,
                  leading: Image.network(
                    language['flag'],
                    width: 30,
                    height: 30,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
