import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
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

    final buttonBg = isDark ? const Color(0xFFD1D1D1) : const Color(0xFF242527);
    final buttonText = isDark ? const Color(0xFF000000) : const Color(0xFFD1D1D1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 16, left: 8),
          child: Image.asset(
            logoPath,
            width: 83,
            height: 48,
          ),
        ),
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
      body: _Body(
        buttonBg: buttonBg,
        buttonText: buttonText,
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final Color buttonBg;
  final Color buttonText;

  const _Body({
    required this.buttonBg,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final $system = ref.watch(systemProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Title text updated: only "Sign In"
            Text(
              tr("Sign In"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 60),

            // Sign in form
            const SignInForm(),

            // Social login section
            (socialLoginEnabled && isTrue($system['social_login_enabled']))
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DividerText(tr("Or")),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Facebook login
                          if (isTrue($system['facebook_login_enabled']))
                            Column(
                              children: [
                                SocialLoginButton(
                                  text: tr('Sign in with Facebook'),
                                  image:
                                      'assets/images/icons/social/facebook.svg',
                                  onTap: () {},
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          // Google login
                          if (isTrue($system['google_login_enabled']))
                            Column(
                              children: [
                                SocialLoginButton(
                                  text: tr('Sign in with Google'),
                                  image:
                                      'assets/images/icons/social/google.svg',
                                  onTap: () {},
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          // Twitter login
                          if (isTrue($system['twitter_login_enabled']))
                            Column(
                              children: [
                                SocialLoginButton(
                                  text: tr('Sign in with X'),
                                  image:
                                      'assets/images/icons/social/twitter.svg',
                                  onTap: () {},
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          // LinkedIn login
                          if (isTrue($system['linkedin_login_enabled']))
                            Column(
                              children: [
                                SocialLoginButton(
                                  text: tr('Sign in with LinkedIn'),
                                  image:
                                      'assets/images/icons/social/linkedin.svg',
                                  onTap: () {},
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          // VK login
                          if (isTrue($system['vk_login_enabled']))
                            Column(
                              children: [
                                SocialLoginButton(
                                  text: tr('Sign in with VK'),
                                  image:
                                      'assets/images/icons/social/vk.svg',
                                  onTap: () {},
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          // WordPress login
                          if (isTrue($system['wordpress_login_enabled']))
                            Column(
                              children: [
                                SocialLoginButton(
                                  text: tr('Sign in with WordPress'),
                                  image:
                                      'assets/images/icons/social/wordpress.svg',
                                  onTap: () {},
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                        ],
                      ),
                    ],
                  )
                : const SizedBox.shrink(),

            const SizedBox(height: 20),

            // Sign up prompt
            if (isTrue($system['registration_enabled']))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tr("Don't have an account?")),
                  TextButton(
                    onPressed: () {
                      context.router.push(const SignUpRoute());
                    },
                    child: Text(
                      tr("Sign Up!"),
                      style: TextStyle(
                        color: buttonBg, // matches splash button color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
