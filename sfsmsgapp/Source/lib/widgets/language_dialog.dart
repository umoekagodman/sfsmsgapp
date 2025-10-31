import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Import App Files
import '../../../states/system_state.dart';
import '../../../utilities/functions.dart';

class LanguageSelectionDialog extends ConsumerWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final $system = ref.watch(systemProvider);

    return SimpleDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(tr("Select Language")),
      children: [
        for (var language in $system['languages'].values)
          ListTile(
            onTap: () async {
              final code = language['code'].split('_');
              await context.setLocale(Locale(code[0], code[1].toUpperCase()));
              await setSharedPref('x-lang', language['code']);
              Navigator.pop(context);
            },
            leading: CachedNetworkImage(
              imageUrl: language['flag'],
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: 30,
              height: 30,
            ),
            title: Text(language['title']),
            trailing: (context.locale.languageCode == language['code'].split('_')[0]) ? const Icon(Icons.check) : null,
          ),
      ],
    );
  }
}
