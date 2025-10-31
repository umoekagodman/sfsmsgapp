import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:flutter_svg/svg.dart';
import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

// Import App Files
import '../../../common/themes.dart';
import '../../../utilities/functions.dart';
import '../../../utilities/timeago_locale/timeago_locale.dart';
import '../../../widgets/profile_avatar.dart';

class CallItem extends StatelessWidget {
  final Map<String, dynamic> call;
  const CallItem({
    required this.call,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    setLocaleMessagesForLocale(languageCode);
    return ListTile(
      leading: ProfileAvatar(
        imageUrl: call['caller_receiver']['user_picture'],
        isOnline: (isTrue(call['caller_receiver']['user_is_online'])) ? true : false,
      ),
      title: Text(
        call['caller_receiver']['user_fullname'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: [
          getCallIcon(call['is_missed_call'], call['is_ingoing']),
          const SizedBox(width: 4),
          Text(timeago.format(convertedTime(call['created_time']), locale: languageCode)),
        ],
      ),
      trailing: call['is_video_call'] == true
          ? SvgPicture.asset(
              "assets/images/icons/chat/call_video.svg",
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(xPrimaryColor, BlendMode.srcIn),
            )
          : SvgPicture.asset(
              "assets/images/icons/chat/call_audio.svg",
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(xPrimaryColor, BlendMode.srcIn),
            ),
    );
  }

  Icon getCallIcon(bool is_missed_call, bool is_ingoing) {
    if (is_missed_call) {
      return Icon(Icons.call_missed, size: 18, color: Colors.red);
    } else if (is_ingoing) {
      return Icon(Icons.call_made, size: 18, color: Colors.green);
    } else {
      return Icon(Icons.call_received, size: 18, color: Colors.grey);
    }
  }
}
