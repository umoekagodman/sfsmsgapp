import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import '../../../states/system_state.dart';
import '../../../routes/router.gr.dart';
import '../../../utilities/functions.dart';
import '../../../widgets/snackbars.dart';

class ActivationResetForm extends ConsumerStatefulWidget {
  const ActivationResetForm({super.key});

  @override
  ConsumerState<ActivationResetForm> createState() => _ActivationResetFormState();
}

class _ActivationResetFormState extends ConsumerState<ActivationResetForm> {
  final formKey = GlobalKey<FormState>();
  final emailPhoneController = TextEditingController();
  bool isSubmitLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailPhoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final $system = ref.watch(systemProvider);
    return Form(
      key: formKey,
      child: Column(
        children: [
          // New Email|Phone
          TextFormField(
            controller: emailPhoneController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: ($system['activation_type'] == 'email') ? tr("New Email") : tr("New Phone"),
              prefixIcon: Padding(
                padding: EdgeInsets.all(20),
                child: ($system['activation_type'] == 'email') ? Icon(Icons.email) : Icon(Icons.phone),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return ($system['activation_type'] == 'email') ? tr("Enter valid email") : tr("Enter valid phone");
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
                  'auth/activation_reset',
                  method: 'POST',
                  body: {
                    ($system['activation_type'] == 'email') ? "email" : "phone": emailPhoneController.text,
                  },
                );
                setState(() {
                  isSubmitLoading = false;
                });
                if (response['statusCode'] == 200) {
                  // update user provider data
                  if ($system['activation_type'] == 'email') {
                    ref.read(userProvider.notifier).state['user_email'] = emailPhoneController.text;
                  } else {
                    ref.read(userProvider.notifier).state['user_phone'] = emailPhoneController.text;
                  }
                  // show success message
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      snackBarSuccess(
                          ($system['activation_type'] == 'email') ? tr("Your email has been changed") : tr("Your phone has been changed")),
                    );
                  // navigate to the activation screen
                  context.router.replace(const ActivationRoute());
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
