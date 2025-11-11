// chat_message.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_message_package/voice_message_package.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_html/flutter_html.dart'; 
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import '../../../common/themes.dart';
import '../../../states/system_state.dart';
import '../../../utilities/functions.dart';
import '../../../utilities/timeago_locale/timeago_locale.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final $system = ref.read(systemProvider);
    final languageCode = Localizations.localeOf(context).languageCode;
    setLocaleMessagesForLocale(languageCode);

    final double avatarRadius = 18;
    final double avatarDiameter = avatarRadius * 2;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleMaxWidth = screenWidth * 0.78; // ~Telegram feel
    final bubbleMinWidth = 50.0;

    // convert time to local and format HH:mm
    DateTime sentTime = convertedTime(message['time']);
    final timeString = DateFormat.Hm().format(sentTime); // 24-hour HH:mm

    // Content widget (text/html)
    Widget contentWidget = const SizedBox.shrink();
    final hasText = (message['message'] != null && message['message'].toString().trim().isNotEmpty);
    final hasImage = (message['image'] != null && message['image'].toString().isNotEmpty);
    final hasVoice = (message['voice_note'] != null && message['voice_note'].toString().isNotEmpty);

    if (hasText) {
      contentWidget = Html(
        data: message['message'],
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(16),
            color: isCurrentUser ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            lineHeight: const LineHeight(1.4),
          ),
        },
      );
    }

    // Bubble decoration
    BoxDecoration bubbleDecoration(bool me) {
      return BoxDecoration(
        color: me
            ? xPrimaryColor
            : (isDark ? const Color(0xFF2A2B2C) : const Color(0xFFF2F3F5)),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(me ? 18 : 4),
          bottomRight: Radius.circular(me ? 4 : 18),
        ),
      );
    }

    // Build bubble child which contains content + timestamp row (timestamp right aligned in new line)
    Widget bubbleChild() {
      return Container(
        constraints: BoxConstraints(
          minWidth: bubbleMinWidth,
          maxWidth: bubbleMaxWidth,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        width: null, // let width adapt dynamically
        decoration: bubbleDecoration(isCurrentUser),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // If it's a reply/quoted message, show small header line with quoted sender
            if (message['reply_to'] != null && message['reply_to'].isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  color: isCurrentUser ? xPrimaryColor.withOpacity(0.12) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message['reply_to']['user_fullname'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCurrentUser ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),

            // text html
            if (hasText) contentWidget,

            // image
            if (hasImage)
              Container(
                margin: EdgeInsets.only(top: hasText ? 6 : 0),
                child: GestureDetector(
                  onTap: () => _showImageFullScreen(context, $system, message),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "${$system['system_uploads']}/${message['image']}",
                      fit: BoxFit.cover,
                      width: bubbleMaxWidth * 0.65,
                      errorBuilder: (_, __, ___) => const Icon(Icons.error),
                    ),
                  ),
                ),
              ),

            // voice
            if (hasVoice)
              Container(
                margin: EdgeInsets.only(top: hasText || hasImage ? 6 : 0),
                child: VoiceMessageView(
                  controller: VoiceController(
                    audioSrc: "${$system['system_uploads']}/${message['voice_note']}",
                    maxDuration: Duration(
                        seconds: int.parse($system['voice_notes_durtaion'] ?? '60')),
                    isFile: false,
                    onComplete: () {},
                    onPause: () {},
                    onPlaying: () {},
                  ),
                  innerPadding: 12,
                  cornerRadius: 12,
                  backgroundColor: isCurrentUser
                      ? xPrimaryColor
                      : (isDark ? const Color(0xFF3a3b3b) : Colors.grey.shade200),
                  activeSliderColor:
                      isCurrentUser ? Colors.white : (isDark ? Colors.white : Colors.black),
                  circlesColor: isCurrentUser
                      ? xPrimaryColor
                      : (isDark ? const Color(0xFF3a3b3b) : Colors.grey.shade200),
                  playIcon: Icon(Icons.play_arrow_rounded,
                      color: isCurrentUser ? Colors.white : (isDark ? Colors.white : Colors.black)),
                  pauseIcon: Icon(Icons.pause_rounded,
                      color: isCurrentUser ? Colors.white : (isDark ? Colors.white : Colors.black)),
                  size: 40,
                  counterTextStyle: TextStyle(
                    color: isCurrentUser ? Colors.white : (isDark ? Colors.white : Colors.black),
                    fontSize: 10,
                  ),
                  circlesTextStyle: TextStyle(
                    color: isCurrentUser ? Colors.white : (isDark ? Colors.white : Colors.black),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // timestamp row: new line, right aligned
            Container(
  margin: const EdgeInsets.only(top: 6),
  child: Text(
    timeString,
    style: TextStyle(
      fontSize: 11,
      color: isCurrentUser
          ? Colors.white.withOpacity(0.8)
          : (isDark ? Colors.white70 : Colors.black54),
    ),
  ),
),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // show sender name for group chats above bubble (Telegram-like)
          if (!isCurrentUser && isMultipleRecipients)
            Padding(
              padding: EdgeInsets.only(bottom: 6, left: avatarDiameter + 8),
              child: Text(
                message['user_fullname'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),

          Row(
  mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
  children: [
    Flexible(child: bubbleChild()),
  ],
),
        ],
      ),
    );
  }

  void _showImageFullScreen(BuildContext context, Map<String, dynamic> system, Map<String, dynamic> msg) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(18),
              ),
              child: PhotoView(
                imageProvider: NetworkImage("${system['system_uploads']}/${msg['image']}"),
                backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: () async {
                  final saved = await saveImageToGallery("${system['system_uploads']}/${msg['image']}");
                  if (saved) showSavedOverlay(context);
                  Navigator.of(context).pop();
                },
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
