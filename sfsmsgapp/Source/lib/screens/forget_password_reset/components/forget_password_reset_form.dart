import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';

// Import App Files
import '../../../routes/router.gr.dart';
import '../../../utilities/functions.dart';
import '../../../widgets/snackbars.dart';

class ForgetPasswordResetForm extends StatefulWidget {
  final String email;
  final String resetKey;
  const ForgetPasswordResetForm({
    super.key,
    required this.email,
    required this.resetKey,
  });

  @override
  State<ForgetPasswordResetForm> createState() => _ForgetPasswordResetFormState();
}

class _ForgetPasswordResetFormState extends State<ForgetPasswordResetForm> {
  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  bool isPasswordObscure = true;
  bool isPasswordConfirmObscure = true;
  bool isSubmitLoading = false;

  @override
  void dispose() {
    super.dispose();
    newPasswordController.dispose();
    repeatPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // New Password
          TextFormField(
            controller: newPasswordController,
            obscureText: isPasswordObscure,
            decoration: InputDecoration(
              labelText: tr("New Password"),
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
          const SizedBox(height: 20),
          // Repeat Password
          TextFormField(
            controller: repeatPasswordController,
            obscureText: isPasswordConfirmObscure,
            decoration: InputDecoration(
              labelText: tr("Confirm Password"),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(Icons.password),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordConfirmObscure = !isPasswordConfirmObscure;
                    });
                  },
                  icon: Icon((isPasswordConfirmObscure) ? Icons.visibility : Icons.visibility_off),
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
          const SizedBox(height: 20),
          // Submit
          ElevatedButton(
            onPressed: () async {
              if (isSubmitLoading) return;
              if (formKey.currentState!.validate()) {
                setState(() {
                  isSubmitLoading = true;
                });
                final response = await sendAPIRequest(
                  'auth/forget_password_reset',
                  method: 'POST',
                  body: {
                    "email": widget.email,
                    "reset_key": widget.resetKey,
                    "password": newPasswordController.text,
                    "confirm": repeatPasswordController.text,
                  },
                );
                setState(() {
                  isSubmitLoading = false;
                });
                if (response['statusCode'] == 200) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      snackBarSuccess(response['body']['message']),
                    );
                  context.router.navigate(const SignInRoute());
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
                : Text(tr("Continue")),
          ),
        ],
      ),
    );
  }
}
