import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';

// Import App Files
import '../../routes/router.gr.dart';
import '../../widgets/language_dialog.dart';

@RoutePage()
class SplashScreen extends StatelessWidget {
  static const routeName = '/splash';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ────────────────────── TOP BAR (LOGO + LANGUAGE) ──────────────────────
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          // DM LOGO (left)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Image.asset(
              "assets/images/welcome_logo.png",
              width: 83,
              height: 48,
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(),
          // Language switcher (right)
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

      // ────────────────────── BODY (unchanged) ──────────────────────
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Image.asset("assets/images/welcome_image.png"),
            ),
            Expanded(
              flex: 2,
                child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr("Welcome to dm,"),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(tr("the free messenger for bold connections, no strings attached.")),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        context.router.replaceAll([const SignInRoute()]);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(tr("Start Chatting")),
                          const Spacer(),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
