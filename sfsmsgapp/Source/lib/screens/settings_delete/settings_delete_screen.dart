import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Import App Files
import '../../widgets/language_dialog.dart';
import 'components/delete_form.dart';

@RoutePage()
class SettingsDeleteScreen extends StatelessWidget {
  static const routeName = 'delete';

  const SettingsDeleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("Delete Account")),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const LanguageSelectionDialog(),
              );
            },
            icon: const Icon(Icons.translate),
          ),
        ],
      ),
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 100),
            SvgPicture.asset(
              "assets/images/delete_account.svg",
              width: 300,
            ),
            SizedBox(height: 40),
            Text(
              tr("Once you delete your account you will no longer can access it again"),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            DeleteForm(),
          ],
        ),
      ),
    );
  }
}
