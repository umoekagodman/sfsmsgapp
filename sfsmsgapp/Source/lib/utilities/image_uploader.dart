import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

// Import App Files
import 'functions.dart';
import '../widgets/snackbars.dart';

Future<String?> showImageUploadOptions({
  required BuildContext context,
  String handle = 'x-image',
  bool multiple = false,
  required Function(bool) setUploadingState,
}) async {
  final ImageSource? source = await showModalBottomSheet<ImageSource>(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    context: context,
    builder: (context) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () => Navigator.pop(context, ImageSource.camera),
                leading: const Icon(Icons.camera_alt_rounded),
                title: Text(tr('Camera')),
              ),
              ListTile(
                onTap: () => Navigator.pop(context, ImageSource.gallery),
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(tr('Gallery')),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (source != null) {
    final XFile? file = await ImagePicker().pickImage(source: source);
    if (file != null) {
      return await uploadImage(
        context: context,
        file: file,
        handle: handle,
        multiple: multiple,
        setUploadingState: setUploadingState,
      );
    }
  }
  return null;
}

Future<String?> uploadImage({
  required BuildContext context,
  required XFile file,
  String? handle,
  bool? multiple,
  required Function(bool) setUploadingState,
}) async {
  try {
    setUploadingState(true);
    final response = await sendAPIRequest(
      'data/upload',
      method: 'UPLOAD',
      body: <String, String>{
        'type': 'photos',
        'handle': handle!,
        'multiple': multiple!.toString(),
        'name': file.name,
        'guid': getGUID(),
      },
      files: [file.path],
    );
    if (response['statusCode'] == 200) {
      setUploadingState(false);
      return response['body']['data'];
    } else {
      setUploadingState(false);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          snackBarError(response['body']['message']),
        );
    }
  } catch (e) {
    setUploadingState(false);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        snackBarError(tr('There is something that went wrongX!')),
      );
  }
  return null;
}
