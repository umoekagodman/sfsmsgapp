import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';

// Import App Files
import '../../widgets/language_dialog.dart';
import 'components/forget_password_reset_form.dart';

@RoutePage()
class ForgetPasswordResetScreen extends StatelessWidget {
  static const routeName = '/forget_password_reset';
  final String email;
  final String resetKey;
  const ForgetPasswordResetScreen({
    super.key,
    required this.email,
    required this.resetKey,
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
      body: _Body(email: email, resetKey: resetKey),
    );
  }
}

class _Body extends StatelessWidget {
  final String email;
  final String resetKey;
  const _Body({
    required this.email,
    required this.resetKey,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text(
              tr("Change Your Password"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 60),
            ForgetPasswordResetForm(email: email, resetKey: resetKey),
          ],
        ),
      ),
    );
  }
}
