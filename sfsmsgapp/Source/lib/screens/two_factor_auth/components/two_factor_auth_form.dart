import 'dart:io' show Platform;
import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

// Import App Files
import '../../../states/system_state.dart';
import '../../../utilities/functions.dart';
import '../../../widgets/snackbars.dart';

class TwoFactorAuthForm extends ConsumerStatefulWidget {
  final String userId;
  final String method;
  const TwoFactorAuthForm({
    super.key,
    required this.userId,
    required this.method,
  });

  @override
  ConsumerState<TwoFactorAuthForm> createState() => _TwoFactorAuthFormState();
}

class _TwoFactorAuthFormState extends ConsumerState<TwoFactorAuthForm> {
  final formKey = GlobalKey<FormState>();
  final pinController = TextEditingController();
  bool isSubmitLoading = false;

  @override
  void dispose() {
    super.dispose();
    pinController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // 2FA Pin Code
          Pinput(
            length: 6,
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: false,
            onChanged: (String value) {
              if (value.length == 6) {
                FocusScope.of(context).unfocus();
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("Enter valid 2FA code");
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
                var deviceInfo = await getDeviceInfo();
                final response = await sendAPIRequest(
                  'auth/two_factor_authentication',
                  method: 'POST',
                  body: {
                    "user_id": widget.userId,
                    "two_factor_key": pinController.text,
                    "device_name": deviceInfo['name'],
                    "device_type": (Platform.isAndroid) ? "A" : "I",
                    "device_os_version": deviceInfo['systemVersion'],
                  },
                );
                setState(() {
                  isSubmitLoading = false;
                });
                if (response['statusCode'] == 200) {
                  // save the token in the local storage
                  await setSharedPref('x-auth-token', response['body']['data']['token']);
                  // update user provider data
                  ref.read(userProvider.notifier).state = response['body']['data']['user'];
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
        ],
      ),
    );
  }
}
