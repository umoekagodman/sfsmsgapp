import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:timeago/timeago.dart' as timeago;

// Import App Files
import '../../../utilities/functions.dart';
import '../../../utilities/timeago_locale/timeago_locale.dart';
import '../../../routes/router.gr.dart';
import '../../../widgets/profile_avatar.dart';

class ContactItem extends StatelessWidget {
  final Map<String, dynamic> user;
  final Function(dynamic)? onContactSelected;

  const ContactItem({
    super.key,
    required this.user,
    this.onContactSelected,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    setLocaleMessagesForLocale(languageCode);
    return InkWell(
      onTap: () {
        if (onContactSelected != null) {
          onContactSelected!(user);
        } else {
          context.router.push(ConversationRoute(userId: user['user_id'], user: user));
        }
      },
      child: (user['user_is_online'] == '1')
          ? ListTile(
              leading: ProfileAvatar(
                imageUrl: user['user_picture'],
                isOnline: (user['user_is_online'] == '1') ? true : false,
              ),
              title: Text(user['user_fullname']),
            )
          : ListTile(
              leading: ProfileAvatar(
                imageUrl: user['user_picture'],
                isOnline: (user['user_is_online'] == '1') ? true : false,
              ),
              title: Text(user['user_fullname']),
              subtitle: Text(timeago.format(convertedTime(user['user_last_seen']), locale: languageCode)),
            ),
    );
  }
}
