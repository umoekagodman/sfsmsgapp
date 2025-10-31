import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:flutter_html/flutter_html.dart';

// Import App Files
import '../common/config.dart' as config;
import '../routes/router.dart';
import '../routes/router.gr.dart';
import '../states/system_state.dart';

// Logger
final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    colors: false,
  ),
);

// initOneSignal
String? _lastNotificationId;
Future<void> initOneSignal(AppRouter appRouter) async {
  if (config.oneSignalAppId.isEmpty) return null;
  OneSignal.initialize(config.oneSignalAppId);
  OneSignal.Notifications.addClickListener((event) async {
    if (_lastNotificationId == event.notification.notificationId) {
      return;
    }
    _lastNotificationId = event.notification.notificationId;
    final launchUrl = event.notification.launchUrl;
    if (launchUrl != null && launchUrl.startsWith('sngine_messenger://')) {
      final uri = Uri.parse(launchUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty && pathSegments[0] == 'messages') {
        final conversationId = pathSegments.length > 1 ? pathSegments[1] : null;
        if (conversationId != null) {
          await appRouter.push(ConversationRoute(conversationId: conversationId));
          await appRouter.root.replaceAll([
            MainRoute(children: [
              ChatsRoute(),
            ]),
          ]);
        }
      }
    }
  });
}

// getOneSignalId
Future<String?> getOneSignalId() async {
  final permission = await OneSignal.Notifications.permission;
  if (permission != OSNotificationPermission.authorized) {
    await OneSignal.Notifications.requestPermission(true);
  }
  return await OneSignal.User.pushSubscription.id;
}

// goHome
goHome(WidgetRef ref, {context, returnRoute = false}) {
  final $system = ref.watch(systemProvider);
  final $user = ref.watch(userProvider);
  /* check registration type */
  if ($system['registration_type'] == 'paid' && int.parse($user['user_group']) > 1 && !isTrue($user['user_subscribed'])) {
    if (returnRoute) return const PackagesRoute();
    AutoRouter.of(context).replaceAll([const PackagesRoute()]);
  }
  /* check user activated */
  else if (isTrue($system['activation_enabled']) && !isTrue($user['user_activated'])) {
    if (returnRoute) return const ActivationRoute();
    AutoRouter.of(context).replaceAll([const ActivationRoute()]);
  }
  /* check if getted started */
  else if (isTrue($system['getting_started']) && !isTrue($user['user_started'])) {
    if (returnRoute) return const GettingStartedRoute();
    AutoRouter.of(context).replaceAll([const GettingStartedRoute()]);
  }
  /* check user approval */
  else if (isTrue($system['users_approval_enabled']) && !isTrue($user['user_approved']) && int.parse($user['user_group']) >= 3) {
    if (returnRoute) return const ApprovalRoute();
    AutoRouter.of(context).replaceAll([const ApprovalRoute()]);
  }
  /* redirect to main screen */
  else {
    if (returnRoute) return MainRoute();
    AutoRouter.of(context).replaceAll([MainRoute()]);
  }
  return null;
}

// getSecureHeaders
Map<String, String> getSecureHeaders() {
  final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
  final key = utf8.encode(config.apiSecret);
  final message = utf8.encode(timestamp);
  final hmacSha256 = Hmac(sha256, key);
  final digest = hmacSha256.convert(message);
  return {
    "Content-Type": "application/json",
    "x-api-key": config.apiKey,
    "x-timestamp": timestamp,
    "x-signature": digest.toString(),
  };
}

// sendAPIRequest
Future<Map<String, dynamic>> sendAPIRequest(
  String endpoint, {
  String method = 'GET',
  bool isAuth = true,
  Map<String, String>? headers,
  Map<String, dynamic>? body,
  Map<String, dynamic>? queryParameters,
  List<String>? files,
}) async {
  http.Response response;
  Map<String, String> initHeaders = getSecureHeaders();
  initHeaders['x-lang'] = await getSharedPref('x-lang') ?? "";
  if (isAuth) {
    initHeaders['x-auth-token'] = await getSharedPref('x-auth-token') ?? "";
  }
  Uri uri = Uri.parse('${config.apiBaseURL}/$endpoint').replace(queryParameters: queryParameters);
  if (config.debugEnabled) {
    logger.i('Request ➜ $method $uri');
    if (body != null) logger.i('Body ➜ ${JsonEncoder.withIndent('  ').convert(body)}');
  }
  switch (method) {
    case 'POST':
      response = await http.post(
        uri,
        headers: {
          ...initHeaders,
          ...?headers,
        },
        body: jsonEncode(body),
      );
      break;
    case 'UPLOAD':
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(initHeaders);
      if (headers != null) request.headers.addAll(headers);
      request.fields.addAll(body! as Map<String, String>);
      if (files != null) {
        for (var file in files) {
          request.files.add(await http.MultipartFile.fromPath('file', file));
        }
      }
      var streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
      break;
    default:
      response = await http.get(
        uri,
        headers: {
          ...initHeaders,
          ...?headers,
        },
      );
      break;
  }
  if (config.debugEnabled) {
    logger.i('Response Status ➜ ${response.statusCode}');
    logger.i('Response Body ➜ ${response.body}');
  }
  return {
    "statusCode": response.statusCode,
    "body": jsonDecode(response.body),
  };
}

// getGUID
String getGUID() {
  return Uuid().v4();
}

// convertedTime
DateTime convertedTime(String utcString) {
  final parts = utcString.split(' ');
  final date = parts[0].split('-').map(int.parse).toList();
  final time = parts[1].split(':').map(int.parse).toList();
  return DateTime.utc(date[0], date[1], date[2], time[0], time[1], time[2]).toLocal();
}

// isTrue
bool isTrue(dynamic value) {
  final valueType = value.runtimeType;
  if (valueType == String) {
    return value == '1' || value == 'true';
  } else if (valueType == bool) {
    return value;
  } else if (valueType == int) {
    return value == 1;
  }
  return false;
}

// getSharedPref
Future<String?> getSharedPref(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(name);
}

// setSharedPref
Future<bool> setSharedPref(String name, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(name, value);
}

// removeSharedPref
Future<bool> removeSharedPref(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.remove(name);
}

// getDeviceInfo
Future<Map<String, dynamic>> getDeviceInfo() async {
  final deviceInfoPlugin = DeviceInfoPlugin();
  final deviceInfo = await deviceInfoPlugin.deviceInfo;
  final allInfo = deviceInfo.data;
  return allInfo;
}

// launchURL
Future<void> launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

// requestMicPermission
Future<bool> requestMicPermission() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    status = await Permission.microphone.request();
  }
  return status.isGranted;
}

// saveImageToGallery
Future<bool> saveImageToGallery(String imageUrl) async {
  PermissionStatus status;
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    if (sdkInt >= 33) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }
    if (!status.isGranted) {
      return false;
    }
  } else {
    status = await Permission.storage.request();
    if (!status.isGranted) {
      return false;
    }
  }
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      await FlutterImageGallerySaver.saveImage(bytes);
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}

// showSavedOverlay
void showSavedOverlay(BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, color: Colors.white, size: 30),
              SizedBox(height: 8),
              Text(context.tr('Saved'), style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 2), () {
    entry.remove();
  });
}

// parsedChatMessage
Widget parsedChatMessage(BuildContext context, String message, bool isCurrentUser, int fontSize) {
  final isHtml = RegExp(r'<(a|img)[^>]*>', caseSensitive: false).hasMatch(message);
  final textColor = isCurrentUser
      ? Colors.white
      : Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

  if (isHtml) {
    return Html(
      shrinkWrap: true,
      data: message,
      style: {
        "body": Style(
          color: textColor,
          fontSize: FontSize(fontSize.toDouble()),
          margin: Margins.zero,
          textDecorationColor: textColor,
        ),
        "a": Style(
          textDecoration: TextDecoration.underline,
          color: textColor,
          fontSize: FontSize(fontSize.toDouble()),
        ),
      },
      onLinkTap: (url, attributes, element) {
        if (url != null) launchURL(url);
      },
    );
  } else {
    return Text(
      message,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize.toDouble(),
      ),
    );
  }
}
