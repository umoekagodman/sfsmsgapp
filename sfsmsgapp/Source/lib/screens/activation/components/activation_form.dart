import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

// Import App Files
import '../../../routes/router.gr.dart';
import '../../../states/system_state.dart';
import '../../../utilities/functions.dart';
import '../../../widgets/snackbars.dart';

class ActivationForm extends ConsumerStatefulWidget {
  const ActivationForm({super.key});

  @override
  ConsumerState<ActivationForm> createState() => _ActivationFormState();
}

class _ActivationFormState extends ConsumerState<ActivationForm> {
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
    final $system = ref.watch(systemProvider);
    final $user = ref.watch(userProvider);
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Activation Code
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
                return tr("Enter valid activation code");
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
                  'auth/activation',
                  method: 'POST',
                  body: {
                    "code": codeController.text,
                  },
                );
                setState(() {
                  isSubmitLoading = false;
                });
                if (response['statusCode'] == 200) {
                  // update the user data
                  $user['user_activated'] = '1';
                  if ($system['activation_type'] == 'email') {
                    // update user provider data
                    ref.read(userProvider.notifier).state['user_email_verified'] = '1';
                  } else {
                    // update user provider data
                    ref.read(userProvider.notifier).state['user_phone_verified'] = '1';
                  }
                  // show success message
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      snackBarSuccess(tr("Account activated successfully")),
                    );
                  // navigate to the home screen
                  goHome(ref, context: context);
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
          const SizedBox(height: 20),
          // Resend Code & Change Email|Phone
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Resend Code
              TextButton(
                onPressed: () async {
                  // show sending snackbar
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      snackBarInfo(tr("Sending ...")),
                    );
                  final response = await sendAPIRequest(
                    'auth/activation_resend',
                    method: 'POST',
                  );
                  if (response['statusCode'] == 200) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        snackBarSuccess(tr("Activation code sent successfully")),
                      );
                  } else {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        snackBarError(response['body']['message']),
                      );
                  }
                },
                child: Text(tr("Resend Code")),
              ),
              const Text(" | "),
              // Change Email|Phone
              TextButton(
                onPressed: () {
                  // Go to change email screen
                  context.router.push(const ActivationResetRoute());
                },
                child: ($system['activation_type'] == 'email') ? Text(tr("Change Email")) : Text(tr("Change Phone")),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
