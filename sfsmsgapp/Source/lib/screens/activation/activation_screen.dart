import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import '../../states/system_state.dart';
import '../../widgets/language_dialog.dart';
import 'components/activation_form.dart';

@RoutePage()
class ActivationScreen extends StatelessWidget {
  static const routeName = '/activation';

  const ActivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("Activation Required")),
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

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final $system = ref.watch(systemProvider);
    final $user = ref.watch(userProvider);
    final activation_method = ($system['activation_type'] == 'email') ? "email" : "phone";
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              tr("Hey 👋 Let's verify your $activation_method"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                text: tr("Enter the activation code send to"),
                children: [
                  const TextSpan(text: " "),
                  TextSpan(
                    text: ($system['activation_type'] == 'email') ? $user['user_email'] : $user['user_phone'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: " "),
                  TextSpan(text: tr("to activate your account"))
                ],
              ),
            ),
            const SizedBox(height: 60),
            ActivationForm(),
          ],
        ),
      ),
    );
  }
}
