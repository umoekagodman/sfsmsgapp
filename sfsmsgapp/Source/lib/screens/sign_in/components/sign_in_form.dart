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
  const SignInForm({super.key});

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
    super.dispose();
    usernameEmailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Username or Email
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordObscure = !isPasswordObscure;
                    });
                  },
                  icon: Icon((isPasswordObscure) ? Icons.visibility : Icons.visibility_off),
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
          // Forget Password
          TextButton(
            onPressed: () {
              context.router.push(const ForgetPasswordRoute());
            },
            child: Text(tr("Forgotten password?")),
          ),
          const SizedBox(height: 10),
          // Submit
          ElevatedButton(
            onPressed: () async {
              if (isSubmitLoading) return;
              if (formKey.currentState!.validate()) {
                setState(() {
                  isSubmitLoading = true;
                });
                // connect to the server
                var deviceInfo = await getDeviceInfo();
                final response = await sendAPIRequest(
                  'auth/signin',
                  method: 'POST',
                  body: {
                    "username_email": usernameEmailController.text,
                    "password": passwordController.text,
                    "device_name": deviceInfo['name'],
                    "device_type": (Platform.isAndroid) ? "A" : "I",
                    "device_os_version": deviceInfo['systemVersion'],
                  },
                );
                setState(() {
                  isSubmitLoading = false;
                });
                if (response['statusCode'] == 200) {
                  // check if 2FA enabled
                  if (response['body']['data']['2FA'] != null) {
                    // navigate to the 2FA screen
                    context.router.push(TwoFactorAuthRoute(
                      userId: response['body']['data']['user_id'],
                      method: response['body']['data']['method'],
                    ));
                  } else {
                    // save the token in the local storage
                    await setSharedPref('x-auth-token', response['body']['data']['token']);
                    // update user provider data
                    ref.read(userProvider.notifier).state = response['body']['data']['user'];
                    // navigate to the home screen
                    goHome(ref, context: context);
                  }
                } else {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      snackBarError(response['body']['message']),
                    );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: (isSubmitLoading)
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Text(tr("Sign In")),
          ),
        ],
      ),
    );
  }
}
