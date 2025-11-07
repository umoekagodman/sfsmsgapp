import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../routes/router.gr.dart';
import '../../widgets/language_dialog.dart';

@RoutePage()
class SplashScreen extends StatelessWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoPath = isDark
        ? "assets/images/welcome_logo_light.png"
        : "assets/images/welcome_logo.png";

    // Dynamic colors
    final buttonBg = isDark ? const Color(0xFFD1D1D1) : const Color(0xFF000000);
    final buttonText = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final arrowColor = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
            child: Image.asset(logoPath, width: 83, height: 48),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const LanguageSelectionDialog(),
            ),
            icon: const Icon(Icons.translate),
          ),
        ],
      ),

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
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      tr("the free messenger for bold connections, no strings attached."),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),

                    // FIXED BUTTON - Text aligned left, arrow right
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.router.replaceAll([const SignInRoute()]),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonBg,
                          foregroundColor: buttonText,
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tr("Start Chatting"),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: buttonText,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: arrowColor,
                              size: 22,
                            ),
                          ],
                        ),
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
