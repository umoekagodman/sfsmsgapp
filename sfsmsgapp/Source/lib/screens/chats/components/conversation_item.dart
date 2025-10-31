import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_slidable/flutter_slidable.dart';

// Import App Files
import '../../../common/themes.dart';
import '../../../utilities/functions.dart';
import '../../../utilities/timeago_locale/timeago_locale.dart';
import '../../../routes/router.gr.dart';
import '../../../widgets/profile_avatar.dart';
import '../../../widgets/profile_overlaped_avatars.dart';

class ConversationItem extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final void Function(String conversationId)? onDelete;
  final void Function(String conversationId)? onLeave;

  const ConversationItem({
    super.key,
    required this.conversation,
    this.onDelete,
    this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    setLocaleMessagesForLocale(languageCode);
    return Slidable(
      key: ValueKey(conversation['conversation_id']),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.30,
        children: [
          (isTrue(conversation['is_chatbox']))
              ? SlidableAction(
                  onPressed: (context) async {
                    bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(tr('Leave Conversation')),
                        content: Text(tr('Are you sure you want to leave this conversation?')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(tr('Cancel')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(tr('Leave'), style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && onLeave != null) {
                      onLeave!(conversation['conversation_id']);
                    }
                  },
                  backgroundColor: Colors.red,
                  icon: Icons.exit_to_app,
                  label: tr("Leave"),
                )
              : SlidableAction(
                  onPressed: (context) async {
                    bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(tr('Delete Conversation')),
                        content: Text(tr('Are you sure you want to delete this conversation?')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(tr("Cancel")),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(tr("Delete"), style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && onDelete != null) {
                      onDelete!(conversation['conversation_id']);
                    }
                  },
                  backgroundColor: Colors.red,
                  icon: Icons.delete,
                  label: tr("Delete"),
                )
        ],
      ),
      child: InkWell(
        onTap: () {
          context.router.push(ConversationRoute(conversationId: conversation['conversation_id']));
        },
        child: ListTile(
          leading: (conversation['multiple_recipients'] == true && conversation['picture_left'] != null && conversation['picture_right'] != null)
              ? OverlappingProfileAvatars(
                  leftImageUrl: conversation['picture_left'],
                  rightImageUrl: conversation['picture_right'],
                )
              : ProfileAvatar(
                  imageUrl: conversation['picture']!,
                  isOnline: isTrue(conversation['user_is_online']),
                ),
          title: Row(
            children: [
              Text(
                conversation['name'],
                style: TextStyle(
                  fontWeight: (!isTrue(conversation['seen'])) ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (!isTrue(conversation['seen'])) ...[
                const SizedBox(width: 5),
                Icon(Icons.circle, size: 10, color: xPrimaryColor),
              ],
            ],
          ),
          subtitle: (conversation['voice_note'] != '')
              ? Text(
                  tr('Sent a voice message'),
                  style: TextStyle(
                    fontWeight: (!isTrue(conversation['seen'])) ? FontWeight.bold : FontWeight.normal,
                  ),
                )
              : (conversation['image'] != '')
                  ? Text(
                      tr('Sent a photo'),
                      style: TextStyle(
                        fontWeight: (!isTrue(conversation['seen'])) ? FontWeight.bold : FontWeight.normal,
                      ),
                    )
                  : Text(
                      conversation['message_orginal'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: (!isTrue(conversation['seen'])) ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (conversation['time'] != null) ? timeago.format(convertedTime(conversation['time']), locale: languageCode) : '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (conversation['unread_messages'] != null && conversation['unread_messages'] > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    conversation['unread_messages'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
