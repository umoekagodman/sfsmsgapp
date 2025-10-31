import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';

// Import App Files
import '../../widgets/language_dialog.dart';
import 'components/two_factor_auth_form.dart';

@RoutePage()
class TwoFactorAuthScreen extends StatelessWidget {
  static const routeName = '/two_factor_auth';
  final String userId;
  final String method;
  const TwoFactorAuthScreen({
    super.key,
    required this.userId,
    required this.method,
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
      body: _Body(userId: userId, method: method),
    );
  }
}

class _Body extends StatelessWidget {
  final String userId;
  final String method;
  const _Body({
    required this.userId,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                tr("2FA Authentication"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                tr("Enter the 6-digit code that you received on your"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                tr(method),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              TwoFactorAuthForm(userId: userId, method: method),
            ],
          ),
        ),
      ),
    );
  }
}
