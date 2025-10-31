import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import '../../states/system_state.dart';
import '../../widgets/language_dialog.dart';
import 'components/activation_reset_form.dart';

@RoutePage()
class ActivationResetScreen extends ConsumerWidget {
  static const routeName = '/activation_reset';

  const ActivationResetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final $system = ref.watch(systemProvider);
    return Scaffold(
      appBar: AppBar(
        title: ($system['activation_type'] == 'email') ? Text(tr("Change Email")) : Text(tr("Change Phone")),
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                text: tr("Current"),
                children: [
                  const TextSpan(text: " "),
                  TextSpan(
                    text: ($system['activation_type'] == 'email') ? tr("Email") : tr("Phone"),
                  ),
                  const TextSpan(text: " "),
                  TextSpan(
                    text: ($system['activation_type'] == 'email') ? $user['user_email'] : $user['user_phone'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            ActivationResetForm(),
          ],
        ),
      ),
    );
  }
}
