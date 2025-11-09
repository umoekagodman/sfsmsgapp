import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_message_package/voice_message_package.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../common/themes.dart';
import '../../../states/system_state.dart'; 
import '../../../utilities/functions.dart';
import '../../../widgets/profile_avatar.dart';

class ChatMessage extends ConsumerWidget {
  final Map<String, dynamic> message;
  final bool isCurrentUser;
  final bool isMultipleRecipients;

  const ChatMessage({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.isMultipleRecipients,
  });

  // WhatsApp exact timestamp: 14:32 or Today 14:32
  String _formatTime(BuildContext context, DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) {
      return DateFormat('HH:mm').format(dt);
    } else if (date == yesterday) {
      return '${tr('Yesterday')} ${DateFormat('HH:mm').format(dt)}';
    } else {
      return DateFormat('dd/MM HH:mm').format(dt);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final $system = ref.read(systemProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final time = convertedTime(message['time']);
    final bubbleColor = isCurrentUser
        ? xPrimaryColor
        : (dark ? const Color(0xFF2A2A2A) : const Color(0xFFE1FFC7));
    final textColor = isCurrentUser ? Colors.white : (dark ? Colors.white70 : Colors.black87);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Group name
          if (!isCurrentUser && isMultipleRecipients)
            Padding(
              padding: const EdgeInsets.only(left: 50, bottom: 2),
              child: Text(
                message['user_fullname'] ?? '',
                style: TextStyle(fontSize: 12, color: xPrimaryColor, fontWeight: FontWeight.w600),
              ),
            ),

          Row(
            mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isCurrentUser)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ProfileAvatar(imageUrl: message['user_picture'], radius: 18),
                ),

              // Bubble
              Flexible(
                child: IntrinsicWidth(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: isCurrentUser ? const Radius.circular(18) : const Radius.circular(4),
                        bottomRight: isCurrentUser ? const Radius.circular(4) : const Radius.circular(18),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text
                              if (message['message']?.toString().isNotEmpty == true)
                                SelectionArea(
                                  child: Html(
                                    data: message['message'],
                                    style: {
                                      "body": Style(
                                        margin: Margins.zero,
                                        padding: HtmlPaddings.zero,
                                        fontSize: FontSize(15.5),
                                        color: textColor,
                                        lineHeight: const LineHeight(1.35),
                                      ),
                                    },
                                  ),
                                ),

                              // Image
                              if (message['image']?.toString().isNotEmpty == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => Scaffold(
                                            backgroundColor: Colors.black,
                                            body: PhotoView(
                                              imageProvider: NetworkImage("${$system['system_uploads']}/${message['image']}"),
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Image.network(
                                        "${$system['system_uploads']}/${message['image']}",
                                        width: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),

                              // Voice note
                              if (message['voice_note']?.toString().isNotEmpty == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: VoiceMessageView(
                                    controller: VoiceController(
                                      audioSrc: "${$system['system_uploads']}/${message['voice_note']}",
                                      maxDuration: const Duration(seconds: 180),
                                      isFile: false,
                                      onComplete: () {},
                                      onPause: () {},
                                      onPlaying: () {},
                                    ),
                                    cornerRadius: 20,
                                    backgroundColor: bubbleColor,
                                    activeSliderColor: Colors.white,
                                    circlesColor: bubbleColor,
                                    size: 38,
                                    innerPadding: 8,
                                    counterTextStyle: TextStyle(color: textColor, fontSize: 10),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Timestamp + checkmarks
                        Positioned(
                          bottom: 2,
                          right: 6,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(context, time),
                                style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.8)),
                              ),
                              if (isCurrentUser) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  message['seen'] == true ? Icons.done_all : Icons.done,
                                  size: 14,
                                  color: message['seen'] == true ? Colors.cyanAccent : textColor.withOpacity(0.8),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (isCurrentUser)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ProfileAvatar(imageUrl: message['user_picture'], radius: 18),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
