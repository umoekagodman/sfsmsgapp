import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
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
  final bool showDateHeader;
  final String? dateHeader;

  const ChatMessage({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.isMultipleRecipients,
    this.showDateHeader = false,
    this.dateHeader,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final $system = ref.read(systemProvider);
    final languageCode = Localizations.localeOf(context).languageCode;
    setLocaleMessagesForLocale(languageCode);

    final double avatarRadius = 16;
    final double avatarDiameter = avatarRadius * 2;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Date Header
        if (showDateHeader && dateHeader != null)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dateHeader!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Message Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar (left side only for received messages)
              if (!isCurrentUser)
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 2),
                  child: ProfileAvatar(
                    imageUrl: message['user_picture'],
                    radius: avatarRadius,
                  ),
                ),

              // Message Bubble
              Flexible(
                child: Column(
                  crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // Sender Name (for group chats)
                    if (!isCurrentUser && isMultipleRecipients)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2, left: 12),
                        child: Text(
                          message['user_fullname'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),

                    // Message Content Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        // Main Message Content
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                            ),
                            child: Column(
                              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                // Text Message
                                if (message['message'].isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isCurrentUser
                                          ? xPrimaryColor
                                          : (isDark ? Color(0xFF2A2A2A) : Colors.grey.shade100),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                        bottomLeft: isCurrentUser ? Radius.circular(12) : Radius.circular(4),
                                        bottomRight: isCurrentUser ? Radius.circular(4) : Radius.circular(12),
                                      ),
                                    ),
                                    child: Html(
                                      data: message['message'],
                                      style: {
                                        "body": Style(
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                          fontSize: FontSize(16),
                                          color: isCurrentUser
                                              ? Colors.white
                                              : (isDark ? Colors.white : Colors.black87),
                                          lineHeight: LineHeight(1.4),
                                        ),
                                        "br": Style(display: Display.block),
                                      },
                                    ),
                                  ),

                                // Image
                                if (message['image'].isNotEmpty)
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: message['message'].isNotEmpty ? 4 : 0),
                                    child: GestureDetector(
                                      onTap: () => _showImageFullScreen(context, $system, message),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          "${$system['system_uploads']}/${message['image']}",
                                          width: 200,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                width: 200,
                                                height: 150,
                                                color: Colors.grey,
                                                child: Icon(Icons.error, color: Colors.white),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // Voice Note
                                if (message['voice_note'].isNotEmpty)
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: message['message'].isNotEmpty ? 4 : 0),
                                    child: VoiceMessageView(
                                      controller: VoiceController(
                                        audioSrc:
                                            "${$system['system_uploads']}/${message['voice_note']}",
                                        maxDuration: Duration(
                                            seconds: int.parse(
                                                $system['voice_notes_durtaion'] ?? '60')),
                                        isFile: false,
                                        onComplete: () {},
                                        onPause: () {},
                                        onPlaying: () {},
                                      ),
                                      innerPadding: 12,
                                      cornerRadius: 18,
                                      backgroundColor: isCurrentUser
                                          ? xPrimaryColor
                                          : (isDark ? Color(0xFF2A2A2A) : Colors.grey.shade100),
                                      activeSliderColor:
                                          isCurrentUser ? Colors.white : (isDark ? Colors.white : Colors.black),
                                      circlesColor: isCurrentUser
                                          ? Colors.white.withOpacity(0.3)
                                          : (isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)),
                                      playIcon: Icon(Icons.play_arrow_rounded,
                                          color: isCurrentUser
                                              ? Colors.white
                                              : (isDark ? Colors.white : Colors.black)),
                                      pauseIcon: Icon(Icons.pause_rounded,
                                          color: isCurrentUser
                                              ? Colors.white
                                              : (isDark ? Colors.white : Colors.black)),
                                      size: 40,
                                      counterTextStyle: TextStyle(
                                        color: isCurrentUser
                                            ? Colors.white
                                            : (isDark ? Colors.white : Colors.black),
                                        fontSize: 12,
                                      ),
                                      circlesTextStyle: TextStyle(
                                        color: isCurrentUser
                                            ? Colors.white
                                            : (isDark ? Colors.white : Colors.black),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Timestamp (aligned right like WhatsApp/Telegram)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 4),
                      child: Text(
                        _formatMessageTime(convertedTime(message['time'])),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Spacer for sent messages (to balance alignment)
              if (isCurrentUser)
                SizedBox(width: avatarDiameter + 8),
            ],
          ),
        ),
      ],
    );
  }

  String _formatMessageTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  void _showImageFullScreen(
      BuildContext context, Map<String, dynamic> system, Map<String, dynamic> msg) {
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
                imageProvider:
                    NetworkImage("${system['system_uploads']}/${msg['image']}"),
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
                  final saved = await saveImageToGallery(
                      "${system['system_uploads']}/${msg['image']}");
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
