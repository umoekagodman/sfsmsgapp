import 'dart:io' show Platform;
import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import '../../../routes/router.gr.dart';
import '../../../states/system_state.dart';
import '../../../utilities/functions.dart';
import '../../../widgets/snackbars.dart';

class SignInForm extends ConsumerStatefulWidget {
  final Color buttonBg;
  final Color buttonText;

  const SignInForm({
    super.key,
    required this.buttonBg,
    required this.buttonText,
  });

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  final formKey = GlobalKey<FormState>();
  final usernameEmailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordObscure = true;
  bool isSubmitLoading = false;

  @override
  void dispose() {
    usernameEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (isSubmitLoading) return;
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isSubmitLoading = true;
    });

    try {
      var deviceInfo = await getDeviceInfo();
      final response = await sendAPIRequest(
        'auth/signin',
        method: 'POST',
        body: {
          "username_email": usernameEmailController.text,
          "password": passwordController.text,
          "device_name": deviceInfo['name'],
          "device_type": Platform.isAndroid ? "A" : "I",
          "device_os_version": deviceInfo['systemVersion'],
        },
      );

      setState(() {
        isSubmitLoading = false;
      });

      if (response['statusCode'] == 200) {
        if (response['body']['data']['2FA'] != null) {
          context.router.push(TwoFactorAuthRoute(
            userId: response['body']['data']['user_id'],
            method: response['body']['data']['method'],
          ));
        } else {
          await setSharedPref('x-auth-token', response['body']['data']['token']);
          ref.read(userProvider.notifier).state = response['body']['data']['user'];
          goHome(ref, context: context);
        }
      } else {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            snackBarError(response['body']['message'] ?? tr("Invalid username or password")),
          );
      }
    } catch (e) {
      setState(() {
        isSubmitLoading = false;
      });
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          snackBarError(tr("Network error. Please try again.")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Email / Username
          TextFormField(
            controller: usernameEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: tr("Email or Username"),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(Icons.email),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("Enter valid email or username");
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password
          TextFormField(
            controller: passwordController,
            obscureText: isPasswordObscure,
            decoration: InputDecoration(
              labelText: tr("Password"),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(Icons.password),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordObscure = !isPasswordObscure;
                    });
                  },
                  icon: Icon(isPasswordObscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("Enter valid password");
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Forgot Password – remains blue link
          TextButton(
            onPressed: () {
              context.router.push(const ForgetPasswordRoute());
            },
            child: Text(tr("Forgotten password?")),
          ),
          const SizedBox(height: 10),

          // Sign In Button – matches splash, loader adapts
          ElevatedButton(
            onPressed: _handleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.buttonBg,
              foregroundColor: widget.buttonText,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: isSubmitLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: widget.buttonText, // Adapts to theme!
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    tr("Sign In"),
                    style: TextStyle(
                      color: widget.buttonText,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
