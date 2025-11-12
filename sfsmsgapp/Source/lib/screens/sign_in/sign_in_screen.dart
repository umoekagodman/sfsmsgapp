import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/config.dart';
import '../../routes/router.gr.dart';
import '../../states/system_state.dart';
import '../../widgets/divider_text.dart';
import '../../widgets/language_dialog.dart';
import '../../utilities/functions.dart';
import 'components/social_login_button.dart';
import 'components/sign_in_form.dart';

@RoutePage()
class SignInScreen extends StatelessWidget {
  static const routeName = '/signin';

  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoPath = isDark
        ? "assets/images/welcome_logo_light.png"
        : "assets/images/welcome_logo.png";

    // Match splash screen button style
    final buttonBg = isDark ? const Color(0xFFD1D1D1) : const Color(0xFF242527);
    final buttonText = isDark ? const Color(0xFF000000) : const Color(0xFFD1D1D1);

    return Scaffold(
      body: Stack(
        children: [
          // Scrollable form content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 100),

                  // Title
                  Text(
                    tr("Sign In"),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Sign-in form fields
                  const SignInForm(),

                  const SizedBox(height: 30),

                  // Sign-in button (styled like splash)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Trigger sign-in from form (handled inside SignInForm)
                        FocusScope.of(context).unfocus();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tr("Sign In"),
                            style: TextStyle(
                              color: buttonText,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: buttonText,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Social login
                  Consumer(builder: (context, ref, _) {
                    final $system = ref.watch(systemProvider);
                    if (!(socialLoginEnabled && isTrue($system['social_login_enabled']))) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        DividerText(tr("Or")),
                        const SizedBox(height: 16),
                        if (isTrue($system['facebook_login_enabled']))
                          Column(
                            children: [
                              SocialLoginButton(
                                text: tr('Sign in with Facebook'),
                                image: 'assets/images/icons/social/facebook.svg',
                                onTap: () {},
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        if (isTrue($system['google_login_enabled']))
                          Column(
                            children: [
                              SocialLoginButton(
                                text: tr('Sign in with Google'),
                                image: 'assets/images/icons/social/google.svg',
                                onTap: () {},
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        if (isTrue($system['twitter_login_enabled']))
                          Column(
                            children: [
                              SocialLoginButton(
                                text: tr('Sign in with X'),
                                image: 'assets/images/icons/social/twitter.svg',
                                onTap: () {},
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        if (isTrue($system['linkedin_login_enabled']))
                          Column(
                            children: [
                              SocialLoginButton(
                                text: tr('Sign in with LinkedIn'),
                                image: 'assets/images/icons/social/linkedin.svg',
                                onTap: () {},
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                      ],
                    );
                  }),

                  const SizedBox(height: 25),

                  // Sign-up prompt
                  Consumer(builder: (context, ref, _) {
                    final $system = ref.watch(systemProvider);
                    if (!isTrue($system['registration_enabled'])) return const SizedBox.shrink();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(tr("Don't have an account?")),
                        TextButton(
                          onPressed: () => context.router.push(const SignUpRoute()),
                          child: Text(
                            tr("Sign Up!"),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Floating logo (high z-index)
          Positioned(
            top: 30,
            left: 20,
            child: Material(
              elevation: 8,
              color: Colors.transparent,
              child: Image.asset(
                logoPath,
                width: 80,
                height: 45,
              ),
            ),
          ),

          // Language button (top right)
          Positioned(
            top: 30,
            right: 10,
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const LanguageSelectionDialog(),
                );
              },
              icon: const Icon(Icons.translate, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}
