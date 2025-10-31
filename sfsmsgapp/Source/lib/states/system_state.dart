// Import Third Party Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import '../utilities/functions.dart';

// System Config Provider
final systemConfigProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final response = await sendAPIRequest('app/settings');
  if (response['statusCode'] == 200) {
    return response['body']['data'];
  } else {
    throw response['body']['message'];
  }
});

// System Provider
final systemProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(systemConfigProvider).value?['system'];
});

// User Provider
final userProvider = StateProvider<Map<String, dynamic>>((ref) {
  return ref.watch(systemConfigProvider).value?['user'] ?? {};
});
