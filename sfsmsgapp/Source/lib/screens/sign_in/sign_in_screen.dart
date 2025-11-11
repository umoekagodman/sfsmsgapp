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
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("Sign In")),
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
            // Removed the "Sign In to your Account" and "Welcome back!" text block.
            // Kept a small spacer to preserve layout.
            const SizedBox(height: 20),

            SignInForm(),
            (socialLoginEnabled && isTrue($system['social_login_enabled']))
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DividerText(tr("Or")),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Facebook login
                          (isTrue($system['facebook_login_enabled']))
                              ? Column(
                                  children: [
                                    SocialLoginButton(
                                      text: tr('Sign in with Facebook'),
                                      image: 'assets/images/icons/social/facebook.svg',
                                      onTap: () {},
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                )
                              : const SizedBox(height: 0),
                          // Google login
                          (isTrue($system['google_login_enabled']))
                              ? Column(
                                  children: [
                                    SocialLoginButton(
                                      text: tr('Sign in with Google'),
                                      image: 'assets/images/icons/social/google.svg',
                                      onTap: () {},
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                )
                              : const SizedBox(height: 0),
                          // Twitter login
                          (isTrue($system['twitter_login_enabled']))
                              ? Column(
                                  children: [
                                    SocialLoginButton(
                                      text: tr('Sign in with X'),
                                      image: 'assets/images/icons/social/twitter.svg',
                                      onTap: () {},
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                )
                              : const SizedBox(height: 0),
                          // LinkedIn login
                          (isTrue($system['linkedin_login_enabled']))
                              ? Column(
                                  children: [
                                    SocialLoginButton(
                                      text: tr('Sign in with LinkedIn'),
                                      image: 'assets/images/icons/social/linkedin.svg',
                                      onTap: () {},
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                )
                              : const SizedBox(height: 0),
                          // VK login
                          (isTrue($system['vk_login_enabled']))
                              ? Column(
                                  children: [
                                    SocialLoginButton(
                                      text: tr('Sign in with VK'),
                                      image: 'assets/images/icons/social/vk.svg',
                                      onTap: () {},
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                )
                              : const SizedBox(height: 0),
                          // WordPress login
                          (isTrue($system['wordpress_login_enabled']))
                              ? Column(
                                  children: [
                                    SocialLoginButton(
                                      text: tr('Sign in with WordPress'),
                                      image: 'assets/images/icons/social/wordpress.svg',
                                      onTap: () {},
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                )
                              : const SizedBox(height: 0),
                        ],
                      ),
                    ],
                  )
                : const SizedBox(height: 0),
            (isTrue($system['registration_enabled']))
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(tr("Don't have an account?")),
                      TextButton(
                        onPressed: () {
                          context.router.push(const SignUpRoute());
                        },
                        child: Text(tr("Sign Up!")),
                      ),
                    ],
                  )
                : const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}
