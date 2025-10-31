import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';

// Import App Files
import '../../widgets/language_dialog.dart';
import 'components/forget_password_confirm_form.dart';

@RoutePage()
class ForgetPasswordConfirmScreen extends StatelessWidget {
  static const routeName = '/forget_password_confirm';
  final String email;
  const ForgetPasswordConfirmScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: _Body(email: email),
    );
  }
}

class _Body extends StatelessWidget {
  final String email;
  const _Body({required this.email});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text(
              tr("Verification Code"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              tr("We sent you an email with a six-digit verification code. Enter it below to continue to reset your password"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 60),
            ForgetPasswordConfirmForm(email: email),
          ],
        ),
      ),
    );
  }
}
