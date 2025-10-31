import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pinput/pinput.dart';

// Import App Files
import '../../../routes/router.gr.dart';
import '../../../utilities/functions.dart';
import '../../../widgets/snackbars.dart';

class ForgetPasswordConfirmForm extends StatefulWidget {
  final String email;
  const ForgetPasswordConfirmForm({
    super.key,
    required this.email,
  });

  @override
  State<ForgetPasswordConfirmForm> createState() => _ForgetPasswordConfirmFormState();
}

class _ForgetPasswordConfirmFormState extends State<ForgetPasswordConfirmForm> {
  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  bool isSubmitLoading = false;

  @override
  void dispose() {
    super.dispose();
    codeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Code
          Pinput(
            length: 6,
            controller: codeController,
            keyboardType: TextInputType.number,
            obscureText: false,
            onChanged: (String value) {
              if (value.length == 6) {
                FocusScope.of(context).unfocus();
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("Enter valid code");
              }
              return null;
            },
          ),
          const SizedBox(height: 25),
          // Submit
          ElevatedButton(
            onPressed: () async {
              if (isSubmitLoading) return;
              if (formKey.currentState!.validate()) {
                setState(() {
                  isSubmitLoading = true;
                });
                final response = await sendAPIRequest(
                  'auth/forget_password_confirm',
                  method: 'POST',
                  body: {
                    "email": widget.email,
                    "reset_key": codeController.text,
                  },
                );
                setState(() {
                  isSubmitLoading = false;
                });
                if (response['statusCode'] == 200) {
                  context.router.push(
                    ForgetPasswordResetRoute(email: widget.email, resetKey: codeController.text),
                  );
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
