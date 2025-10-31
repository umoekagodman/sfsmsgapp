import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

// Import Third Party Packages
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import '../../../states/system_state.dart';
import '../../../utilities/functions.dart';
import '../../../common/themes.dart';
import '../../../widgets/snackbars.dart';
import 'custom_field.dart';
import 'static_screen.dart';

class SignUpForm extends ConsumerStatefulWidget {
  const SignUpForm({super.key});

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  final formKey = GlobalKey<FormState>();
  final invitationCodeController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final birthdateController = TextEditingController();
  bool isPasswordObscure = true;
  bool isNewsletterConsent = false;
  bool isSubmitLoading = false;

  // API Call: getGenders
  var genders = [];
  var selectedGender = '';
  Future<void> getGenders() async {
    final response = await sendAPIRequest('app/genders');
    if (response['statusCode'] == 200) {
      setState(() {
        genders = response['body']['data'];
      });
    }
  }

  // API Call: getUserGroups
  var userGroups = [];
  var selectedUserGroup = '';
  Future<void> getUserGroups() async {
    final response = await sendAPIRequest('app/user_groups');
    if (response['statusCode'] == 200) {
      setState(() {
        userGroups = response['body']['data'];
      });
    }
  }

  // API Call: getCustomFields
  var customedFields = [];
  Future<void> getCustomFields() async {
    final response = await sendAPIRequest('app/custom_fields');
    if (response['statusCode'] == 200) {
      // loop through custom fields
      if (response['body']['data'] == null) return;
      response['body']['data'].forEach((customField) {
        // check if custom field is required
        if (customField['mandatory'] == '1') {
          // add required validator
          customField['validator'] = (value) {
            if (value == null || value.isEmpty) {
              return (customField['type'] == 'selectbox' || customField['type'] == 'multipleselectbox')
                  ? tr("Select valid customField", args: [customField['label']])
                  : tr("Enter valid customField", args: [customField['label']]);
            }
            return null;
          };
        }
        // init value
        customField['value'] = (customField['type'] == 'multipleselectbox') ? [] : null;
        // update custom fields list
        customedFields.add(customField);
      });
    }
  }

  // API Call: getStaticPageContent
  Future<String> getStaticPageContent(String pageURL) async {
    final response = await sendAPIRequest('app/static_pages/$pageURL');
    if (response['statusCode'] == 200) {
      return response['body']['data']['page_text'];
    }
    return '';
  }

  // initSignupForm
  bool screenLoadingDone = false;
  late Future<String> termsContnet;
  late Future<String> privacyConetnt;
  void initSignupForm() async {
    // get genders
    await getGenders();
    // get user groups
    await getUserGroups();
    // get custom fields
    await getCustomFields();
    termsContnet = getStaticPageContent('terms');
    privacyConetnt = getStaticPageContent('privacy');
    setState(() {
      screenLoadingDone = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    invitationCodeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    birthdateController.dispose();
  }

  @override
  void initState() {
    super.initState();
    initSignupForm();
  }

  @override
  Widget build(BuildContext context) {
    final $system = ref.watch(systemProvider);
    return (!screenLoadingDone)
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: formKey,
            child: Column(
              children: [
                // Invitation Code
                (isTrue($system['invitation_enabled']))
                    ? Column(
                        children: [
                          TextFormField(
                            controller: invitationCodeController,
                            decoration: InputDecoration(
                              labelText: tr("Invitation Code"),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(20),
                                child: Icon(Icons.code),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr("Enter valid invitation code");
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    : const SizedBox(height: 0),
                (!isTrue($system['show_usernames_enabled']))
                    ? Column(
                        children: [
                          // First Name
                          TextFormField(
                            controller: firstNameController,
                            decoration: InputDecoration(
                              labelText: tr("First Name"),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(20),
                                child: Icon(Icons.account_circle_rounded),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr("Enter valid first name");
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Last Name
                          TextFormField(
                            controller: lastNameController,
                            decoration: InputDecoration(
                              labelText: tr("Last Name"),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(20),
                                child: Icon(Icons.account_circle_rounded),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr("Enter valid last name");
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    : const SizedBox(height: 0),
                // Username
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: tr("Username"),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Icon(Icons.alternate_email),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr("Enter valid username");
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
                // Phone
                (isTrue($system['activation_enabled']) && $system['activation_type'] == 'sms')
                    ? Column(
                        children: [
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: tr("Phone Number (e.g +1234567890)"),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(20),
                                child: Icon(Icons.phone),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr("Enter valid phone");
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    : const SizedBox(height: 0),
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
                const SizedBox(height: 20),
                // Gender
                (!isTrue($system['genders_disabled']))
                    ? Column(
                        children: [
                          DropdownButtonFormField(
                            decoration: InputDecoration(
                              labelText: tr("Gender"),
                              hintText: tr("Gender"),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(20),
                                child: Icon(Icons.female),
                              ),
                              contentPadding: const EdgeInsets.only(left: 20, right: 0),
                            ),
                            items: genders.map<DropdownMenuItem<String>>((gender) {
                              return DropdownMenuItem<String>(
                                value: gender['gender_id'],
                                child: Text(gender['gender_name']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return tr("Select valid gender");
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    : const SizedBox(height: 0),
                // Birthdate
                (isTrue($system['age_restriction']))
                    ? Column(
                        children: [
                          TextFormField(
                            controller: birthdateController,
                            decoration: InputDecoration(
                              labelText: tr("Birthdate"),
                              hintText: tr("Select your birthdate"),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(20),
                                child: Icon(Icons.cake),
                              ),
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  birthdateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr("Select valid birthdate");
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    : const SizedBox(height: 0),
                // User Group
                (isTrue($system['select_user_group_enabled']))
                    ? Column(
                        children: [
                          DropdownButtonFormField(
                            decoration: InputDecoration(
                              labelText: tr("User Group"),
                              hintText: tr("User Group"),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(20),
                                child: Icon(Icons.group),
                              ),
                              contentPadding: const EdgeInsets.only(left: 20, right: 0),
                            ),
                            items: userGroups.map<DropdownMenuItem<String>>((group) {
                              return DropdownMenuItem<String>(
                                value: group['user_group_id'],
                                child: Text(group['user_group_title']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedUserGroup = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return tr("Select valid user group");
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    : const SizedBox(height: 0),
                // Custom Fields
                (customedFields.isNotEmpty)
                    ? Column(
                        children: customedFields.map<Widget>((field) {
                          return CustomField(field);
                        }).toList(),
                      )
                    : const SizedBox(height: 0),
                // Newsletter Consent
                (isTrue($system['newsletter_consent']))
                    ? Column(
                        children: [
                          CheckboxListTile(
                            title: Text(tr("I expressly agree to receive the newsletter")),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            value: isNewsletterConsent,
                            onChanged: (value) {
                              setState(() {
                                isNewsletterConsent = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    : const SizedBox(height: 0),
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
                        'auth/signup',
                        method: 'POST',
                        body: {
                          "invitation_code": invitationCodeController.text,
                          "first_name": firstNameController.text,
                          "last_name": lastNameController.text,
                          "username": usernameController.text,
                          "email": emailController.text,
                          "phone": phoneController.text,
                          "password": passwordController.text,
                          "gender": selectedGender,
                          "custom_user_group": selectedUserGroup,
                          "birth_month": (isTrue($system['age_restriction'])) ? DateTime.parse(birthdateController.text).month.toString() : "",
                          "birth_day": (isTrue($system['age_restriction'])) ? DateTime.parse(birthdateController.text).day.toString() : "",
                          "birth_year": (isTrue($system['age_restriction'])) ? DateTime.parse(birthdateController.text).year.toString() : "",
                          for (var customField in customedFields) "fld_${customField['field_id']}": customField['value'],
                          "newsletter_agree": (isNewsletterConsent) ? "1" : "0",
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
                      : Text(tr("Sign Up")),
                ),
                const SizedBox(height: 20),
                // Terms and Conditions & Privacy Policy
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      height: 1.8,
                    ),
                    text: tr("By creating your account, you agree to our"),
                    children: [
                      const TextSpan(text: " "),
                      TextSpan(
                        text: tr("Terms and Conditions"),
                        style: const TextStyle(
                          color: xTextLinkColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                              ),
                              builder: (context) {
                                return StaticScreen(
                                  title: tr("Terms and Conditions"),
                                  content: termsContnet,
                                );
                              },
                            );
                          },
                      ),
                      const TextSpan(text: " "),
                      TextSpan(text: tr("and")),
                      const TextSpan(text: " "),
                      TextSpan(
                        text: tr("Privacy Policy"),
                        style: const TextStyle(
                          color: xTextLinkColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                              ),
                              builder: (context) {
                                return StaticScreen(
                                  title: tr("Privacy Policy"),
                                  content: privacyConetnt,
                                );
                              },
                            );
                          },
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
  }
}
