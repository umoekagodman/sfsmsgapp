import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:easy_localization/easy_localization.dart';

// Import App Files
import '../../../utilities/functions.dart';
import '../../../widgets/snackbars.dart';

class ForgetPasswordForm extends StatefulWidget {
  const ForgetPasswordForm({super.key});

  @override
  State<ForgetPasswordForm> createState() => _ForgetPasswordFormState();
}

class _ForgetPasswordFormState extends State<ForgetPasswordForm> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  bool isSubmitLoading = false;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Name
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: tr("Name"),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(Icons.account_circle_rounded),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("Enter valid name");
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Email
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: tr("Email"),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(Icons.email),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("Enter valid email");
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Subject
          TextFormField(
            controller: subjectController,
            decoration: InputDecoration(
              labelText: tr("Subject"),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(Icons.subject),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("Enter valid subject");
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Message
          TextFormField(
            controller: messageController,
            textAlignVertical: TextAlignVertical.top,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: tr("Message"),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 0,
                ),
                child: Icon(Icons.message),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("Enter valid message");
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
                  'app/contact_us',
                  method: 'POST',
                  body: {
                    "name": nameController.text,
                    "email": emailController.text,
                    "subject": subjectController.text,
                    "message": messageController.text,
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
                    child: CircularProgressIndicator(),
                  )
                : Text(tr("Send")),
          ),
        ],
      ),
    );
  }
}
