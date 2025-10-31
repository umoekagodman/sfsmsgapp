import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import '../../../routes/router.gr.dart';
import '../../../utilities/functions.dart';
import '../../../widgets/snackbars.dart';

class DeleteForm extends ConsumerStatefulWidget {
  const DeleteForm({super.key});

  @override
  ConsumerState<DeleteForm> createState() => _DeleteFormState();
}

class _DeleteFormState extends ConsumerState<DeleteForm> {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  bool isPasswordObscure = true;
  bool isSubmitLoading = false;

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: passwordController,
            obscureText: isPasswordObscure,
            decoration: InputDecoration(
              labelText: tr("Password"),
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
          ElevatedButton(
            onPressed: () async {
              if (isSubmitLoading) return;
              if (formKey.currentState!.validate()) {
                setState(() {
                  isSubmitLoading = true;
                });
                // connect to the server
                final response = await sendAPIRequest(
                  'user/delete',
                  method: 'POST',
                  body: {
                    'password': passwordController.text,
                  },
                );
                setState(() {
                  isSubmitLoading = false;
                });
                if (response['statusCode'] == 200) {
                  await removeSharedPref('x-auth-token');
                  context.router.replaceAll([const SignInRoute()]);
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
            child: isSubmitLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Text(tr("Delete Account")),
          ),
        ],
      ),
    );
  }
}
