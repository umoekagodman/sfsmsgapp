import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import '../../routes/router.gr.dart';
import '../../states/system_state.dart';
import '../../utilities/functions.dart';
import '../../widgets/language_dialog.dart';
import 'components/forget_password_form.dart';

@RoutePage()
class ForgetPasswordScreen extends StatelessWidget {
  static const routeName = '/forget_password';

  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("Forget Password")),
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              tr("Forgot your password?"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tr("Enter the email address associated with your account and we will send you a link to reset your password"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 60),
            ForgetPasswordForm(),
            (isTrue($system['contact_enabled']))
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(tr("Need help?")),
                          TextButton(
                            onPressed: () {
                              context.router.push(const ContactUsRoute());
                            },
                            child: Text(tr("Contact Us")),
                          ),
                        ],
                      )
                    ],
                  )
                : const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}
