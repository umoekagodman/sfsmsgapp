import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import '../../common/themes.dart';
import '../../states/system_state.dart';
import '../../utilities/functions.dart';
import '../../utilities/image_uploader.dart';
import '../../widgets/language_dialog.dart';
import '../../widgets/no_data.dart';
import '../../widgets/snackbars.dart';
import 'components/user_item.dart';

@RoutePage()
class GettingStartedScreen extends StatelessWidget {
  static const routeName = '/getting_started';

  const GettingStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("Getting Started")),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const LanguageSelectionDialog(),
              );
            },
            icon: const Icon(Icons.translate),
          ),
        ],
      ),
      body: _Body(),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body();

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  int currentStep = 0;
  bool uploadingImage = false;
  final formKey = GlobalKey<FormState>();
  late TextEditingController currentCityController = TextEditingController();
  late TextEditingController homeTownController = TextEditingController();
  late TextEditingController workTitleController = TextEditingController();
  late TextEditingController workPlaceController = TextEditingController();
  late TextEditingController workWebsiteController = TextEditingController();
  late TextEditingController educationMajorController = TextEditingController();
  late TextEditingController educationSchoolController = TextEditingController();
  late TextEditingController educationClassController = TextEditingController();
  bool isSubmitLoading = false;

  // API Call: getCountries
  var countries = [];
  Future<void> getCountries() async {
    final response = await sendAPIRequest('app/countries');
    if (response['statusCode'] == 200) {
      setState(() {
        countries = response['body']['data'];
      });
    }
  }

  // API Call: getNewPeople
  var newPeople = [];
  Future<void> getNewPeople() async {
    final response = await sendAPIRequest(
      'data/load',
      queryParameters: {
        "get": "new_people",
        "offset": "0",
        "random": "true",
      },
    );
    if (response['statusCode'] == 200) {
      setState(() {
        newPeople = response['body']['data'];
      });
    }
  }

  // API Call: deleteProfilePicture
  Future<void> deleteProfilePicture() async {
    if (uploadingImage) return;
    setState(() {
      uploadingImage = true;
    });
    // delete the image
    final response = await sendAPIRequest(
      'user/image_delete',
      method: 'POST',
      body: {
        'handle': 'picture-user',
      },
    );
    setState(() {
      uploadingImage = false;
    });
    if (response['statusCode'] == 200) {
      var user_picture = "${response['body']['data']}";
      // update user provider data
      ref.read(userProvider.notifier).state['user_picture'] = user_picture;
      ref.read(userProvider.notifier).state['user_picture_default'] = true;
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          snackBarError(response['body']['message']),
        );
    }
  }

  @override
  void dispose() {
    super.dispose();
    currentCityController.dispose();
    homeTownController.dispose();
    workTitleController.dispose();
    workPlaceController.dispose();
    workWebsiteController.dispose();
    educationMajorController.dispose();
    educationSchoolController.dispose();
    educationClassController.dispose();
  }

  @override
  void initState() {
    super.initState();
    getCountries();
    getNewPeople();
    final $user = ref.read(userProvider);
    currentCityController = TextEditingController(text: $user['user_current_city']);
    homeTownController = TextEditingController(text: $user['user_hometown']);
    workTitleController = TextEditingController(text: $user['user_work_title']);
    workPlaceController = TextEditingController(text: $user['user_work_place']);
    workWebsiteController = TextEditingController(text: $user['user_work_url']);
    educationMajorController = TextEditingController(text: $user['user_edu_major']);
    educationSchoolController = TextEditingController(text: $user['user_edu_school']);
    educationClassController = TextEditingController(text: $user['user_edu_class']);
  }

  @override
  Widget build(BuildContext context) {
    final $system = ref.watch(systemProvider);
    final $user = ref.watch(userProvider);
    return SafeArea(
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: xPrimaryColor,
          ),
        ),
        child: Stepper(
          currentStep: currentStep,
          onStepContinue: () async {
            if (currentStep == 1) {
              if (isSubmitLoading) return;
              if (formKey.currentState!.validate()) {
                setState(() {
                  isSubmitLoading = true;
                });
                // connect to the server
                final response = await sendAPIRequest(
                  'auth/getting_started_update',
                  method: 'POST',
                  body: {
                    "country": $user['user_country'],
                    "city": currentCityController.text,
                    "hometown": homeTownController.text,
                    "work_title": workTitleController.text,
                    "work_place": workPlaceController.text,
                    "work_url": workWebsiteController.text,
                    "edu_major": educationMajorController.text,
                    "edu_school": educationSchoolController.text,
                    "edu_class": educationClassController.text,
                  },
                );
                setState(() {
                  isSubmitLoading = false;
                });
                if (response['statusCode'] == 200) {
                  setState(() {
                    currentStep += 1;
                  });
                  // update user provider data
                  ref.read(userProvider.notifier).state['user_country'] = $user['user_country'];
                  ref.read(userProvider.notifier).state['user_current_city'] = currentCityController.text;
                  ref.read(userProvider.notifier).state['user_hometown'] = homeTownController.text;
                  ref.read(userProvider.notifier).state['user_work_title'] = workTitleController.text;
                  ref.read(userProvider.notifier).state['user_work_place'] = workPlaceController.text;
                  ref.read(userProvider.notifier).state['user_work_url'] = workWebsiteController.text;
                  ref.read(userProvider.notifier).state['user_edu_major'] = educationMajorController.text;
                  ref.read(userProvider.notifier).state['user_edu_school'] = educationSchoolController.text;
                  ref.read(userProvider.notifier).state['user_edu_class'] = educationClassController.text;
                } else {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      snackBarError(response['body']['message']),
                    );
                }
              }
            } else if (currentStep == 2) {
              setState(() {
                isSubmitLoading = true;
              });
              // connect to the server
              final response = await sendAPIRequest(
                'auth/getting_started_finish',
                method: 'POST',
              );
              setState(() {
                isSubmitLoading = false;
              });
              if (response['statusCode'] == 200) {
                // update user provider data
                ref.read(userProvider.notifier).state['user_started'] = '1';
                // navigate to the home screen
                goHome(ref, context: context);
              } else {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    snackBarError(response['body']['message']),
                  );
              }
            } else {
              setState(() {
                currentStep += 1;
              });
            }
          },
          onStepCancel: () {
            if (currentStep == 0) {
              return;
            } else {
              setState(() {
                currentStep -= 1;
              });
            }
          },
          controlsBuilder: (context, details) {
            return Container(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  (currentStep == 0)
                      ? const SizedBox(width: 0)
                      : Expanded(
                          child: ElevatedButton(
                            onPressed: details.onStepCancel,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.arrow_back_rounded,
                                ),
                                const SizedBox(width: 10),
                                Text(tr("Back")),
                              ],
                            ),
                          ),
                        ),
                  (currentStep == 0) ? const SizedBox(width: 0) : const SizedBox(width: 5),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: (isSubmitLoading)
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (currentStep == 2) ? tr("Finish") : tr("Next"),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  (currentStep == 2) ? Icons.check : Icons.arrow_forward_rounded,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
          steps: [
            // Step 1: Upload your photo
            Step(
              state: (currentStep > 0) ? StepState.complete : StepState.indexed,
              isActive: currentStep >= 0,
              title: Text(tr("Upload your photo")),
              content: Column(
                children: [
                  Text.rich(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    TextSpan(
                      text: tr("Welcome"),
                      children: [
                        const TextSpan(text: " "),
                        TextSpan(
                          text: $user['user_fullname'],
                          style: const TextStyle(
                            color: xTextLinkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tr("Let's start with your photo"),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Circle Avatar
                  Stack(
                    children: [
                      (uploadingImage)
                          ? const SizedBox(
                              height: 160,
                              width: 160,
                              child: CircularProgressIndicator(),
                            )
                          : CircleAvatar(
                              radius: 80,
                              backgroundImage: NetworkImage($user['user_picture']),
                            ),
                      // Upload Button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () async {
                              final response = await showImageUploadOptions(
                                context: context,
                                handle: 'picture-user',
                                setUploadingState: (isUploading) {
                                  setState(() {
                                    uploadingImage = isUploading;
                                  });
                                },
                              );
                              if (response != null) {
                                var user_picture = "${$system['system_uploads']}/${response}";
                                ref.read(userProvider.notifier).state['user_picture'] = user_picture;
                                ref.read(userProvider.notifier).state['user_picture_default'] = false;
                              }
                            },
                            icon: const Icon(Icons.camera_alt_rounded),
                          ),
                        ),
                      ),
                      // Delete Button
                      if (!isTrue($user['user_picture_default']))
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: deleteProfilePicture,
                              icon: const Icon(Icons.delete_rounded),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Step 2: Update your info
            Step(
              state: (currentStep > 1) ? StepState.complete : StepState.indexed,
              isActive: currentStep >= 1,
              title: Text(tr("Update your info")),
              content: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Location Info
                      Text(
                        tr("Location").toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Countries
                      DropdownButtonFormField(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: tr("Country"),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Icon(Icons.location_pin),
                          ),
                          contentPadding: const EdgeInsets.only(left: 20, right: 0),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                        value: $user['user_country'],
                        items: countries.map<DropdownMenuItem<String>>((country) {
                          return DropdownMenuItem<String>(
                            value: country['country_id'],
                            child: Text(country['country_name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          // update user provider data
                          ref.read(userProvider.notifier).state['user_country'] = value;
                        },
                        validator: (value) {
                          if (value == null) {
                            return tr("Select valid country");
                          }
                          return null;
                        },
                      ),
                      (isTrue($system['location_info_enabled']))
                          ? Column(
                              children: [
                                const SizedBox(height: 20),
                                // Current City
                                TextFormField(
                                  controller: currentCityController,
                                  decoration: InputDecoration(
                                    labelText: tr("Current City"),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Icon(Icons.location_pin),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (isTrue($system['getting_started_location_required'])) {
                                      if (value == null || value.isEmpty) {
                                        return tr("Enter your current city");
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Hometown
                                TextFormField(
                                  controller: homeTownController,
                                  decoration: InputDecoration(
                                    labelText: tr("Hometown"),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Icon(Icons.location_city),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (isTrue($system['getting_started_location_required'])) {
                                      if (value == null || value.isEmpty) {
                                        return tr("Enter your hometown");
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            )
                          : const SizedBox(height: 0),
                      const SizedBox(height: 20),
                      // Work Info
                      (isTrue($system['work_info_enabled']))
                          ? Column(
                              children: [
                                const Divider(),
                                const SizedBox(height: 20),
                                Text(
                                  tr("Work").toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Work Title
                                TextFormField(
                                  controller: workTitleController,
                                  decoration: InputDecoration(
                                    labelText: tr("Work Title"),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Icon(Icons.work),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (isTrue($system['getting_started_work_required'])) {
                                      if (value == null || value.isEmpty) {
                                        return tr("Enter your work title");
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Work Place
                                TextFormField(
                                  controller: workPlaceController,
                                  decoration: InputDecoration(
                                    labelText: tr("Work Place"),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Icon(Icons.location_city),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (isTrue($system['getting_started_work_required'])) {
                                      if (value == null || value.isEmpty) {
                                        return tr("Enter your work place");
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Work Website
                                TextFormField(
                                  controller: workWebsiteController,
                                  decoration: InputDecoration(
                                    labelText: tr("Work Website"),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Icon(Icons.link),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (isTrue($system['getting_started_work_required'])) {
                                      if (value == null || value.isEmpty) {
                                        return tr("Enter your work website");
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            )
                          : const SizedBox(height: 0),
                      // Education Info
                      (isTrue($system['education_info_enabled']))
                          ? Column(
                              children: [
                                const Divider(),
                                const SizedBox(height: 20),
                                Text(
                                  tr("Education").toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Education Major
                                TextFormField(
                                  controller: educationMajorController,
                                  decoration: InputDecoration(
                                    labelText: tr("Education Major"),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Icon(Icons.school),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (isTrue($system['getting_started_education_required'])) {
                                      if (value == null || value.isEmpty) {
                                        return tr("Enter your education major");
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Education Schoool
                                TextFormField(
                                  controller: educationSchoolController,
                                  decoration: InputDecoration(
                                    labelText: tr("Education School"),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Icon(Icons.house),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (isTrue($system['getting_started_education_required'])) {
                                      if (value == null || value.isEmpty) {
                                        return tr("Enter your education school");
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Education Class
                                TextFormField(
                                  controller: educationClassController,
                                  decoration: InputDecoration(
                                    labelText: tr("Education Class"),
                                    hintText: tr("Enter your education class"),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Icon(Icons.calendar_today),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (isTrue($system['getting_started_education_required'])) {
                                      if (value == null || value.isEmpty) {
                                        return tr("Enter your education class");
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            )
                          : const SizedBox(height: 0),
                    ],
                  )),
            ),
            // Step 3: Manage Connections
            Step(
              state: (currentStep > 2) ? StepState.complete : StepState.indexed,
              isActive: currentStep >= 2,
              title: Text(tr("Manage Connections")),
              content: Column(
                children: [
                  Text(
                    tr("Get latest activities from our popular users"),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  (newPeople.isNotEmpty)
                      ? SizedBox(
                          height: 400,
                          child: ListView.builder(
                            itemCount: newPeople.length,
                            itemBuilder: (context, index) {
                              final userObject = newPeople[index];
                              return UserItem(
                                userObject: userObject,
                                connectionStatus: 'add',
                                onDone: (status) {
                                  setState(() {
                                    newPeople.removeAt(index);
                                  });
                                },
                              );
                            },
                          ),
                        )
                      : NoData(text: tr("No users available")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
