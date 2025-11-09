import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import 'functions.dart';
import '../widgets/snackbars.dart';

/// ---------------------------------------------------------------
///  SHOW BOTTOM SHEET – Camera / Gallery
/// ---------------------------------------------------------------
Future<String?> showImageUploadOptions({
  required BuildContext context,
  String handle = 'x-image',
  bool multiple = false,
  required Function(bool) setUploadingState,
  void Function(double)? onProgress,   // ← NEW: optional progress
}) async {
  final source = await showModalBottomSheet<ImageSource>(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    context: context,
    builder: (_) => SafeArea(
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
    ),
  );

  if (source == null) return null;

  final xFile = await ImagePicker().pickImage(source: source);
  if (xFile == null) return null;

  return await uploadImage(
    context: context,
    file: xFile,
    handle: handle,
    multiple: multiple,
    setUploadingState: setUploadingState,
    onProgress: onProgress,
  );
}

/// ---------------------------------------------------------------
///  UPLOAD USING YOUR EXISTING sendAPIRequest() + PROGRESS
/// ---------------------------------------------------------------
Future<String?> uploadImage({
  required BuildContext context,
  required XFile file,
  String? handle,
  bool? multiple,
  required Function(bool) setUploadingState,
  void Function(double)? onProgress,   // 0.0 → 1.0
}) async {
  setUploadingState(true);

  try {
    final response = await sendAPIRequest(
      'data/upload',
      method: 'UPLOAD',
      body: <String, String>{
        'type': 'photos',
        'handle': handle ?? 'x-image',
        'multiple': (multiple ?? false).toString(),
        'name': file.name,
        'guid': getGUID(),
      },
      files: [file.path],
      onSendProgress: (sent, total) {
        if (total > 0 && onProgress != null) {
          onProgress(sent / total);
        }
      },
    );

    if (response['statusCode'] == 200) {
      return response['body']['data'];
    } else {
      throw Exception(response['body']['message'] ?? 'Upload failed');
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBarError(e.toString()));
    return null;
  } finally {
    setUploadingState(false);
  }
}
