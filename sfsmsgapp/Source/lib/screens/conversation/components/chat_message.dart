import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:voice_message_package/voice_message_package.dart';
import 'package:photo_view/photo_view.dart';

// Import App Files
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
    final double avatarRadius = 20;
    final double avatarDiameter = avatarRadius * 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser && isMultipleRecipients)
            Padding(
              padding: EdgeInsets.only(
                bottom: 2.0,
                left: avatarDiameter + 10,
              ),
              child: Column(
                children: [
                  Text(
                    '${message['user_fullname']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isCurrentUser) ...[
                ProfileAvatar(
                  imageUrl: message['user_picture'],
                  radius: avatarRadius,
                ),
                SizedBox(width: 10),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // Text Message
                    if (message['message'].isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? xPrimaryColor
                              : Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF3a3b3b)
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: parsedChatMessage(context, message['message'], isCurrentUser, 17),
                      ),
                    // Image Message
                    if (message['image'].isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: (message['message'].isNotEmpty) ? 5 : 0),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: PhotoView(
                                        imageProvider: NetworkImage("${$system['system_uploads']}/${message['image']}"),
                                        backgroundDecoration: BoxDecoration(color: Colors.black.withValues(alpha: 0)),
                                        minScale: PhotoViewComputedScale.contained,
                                        maxScale: PhotoViewComputedScale.covered * 2,
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: IconButton(
                                        icon: Icon(Icons.download, color: Colors.white),
                                        onPressed: () async {
                                          final saved = await saveImageToGallery("${$system['system_uploads']}/${message['image']}");
                                          if (saved) {
                                            showSavedOverlay(context);
                                          }
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: IconButton(
                                        icon: Icon(Icons.close, color: Colors.white),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              "${$system['system_uploads']}/${message['image']}",
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    // Voice Message
                    if (message['voice_note'].isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: (message['message'].isNotEmpty) ? 5 : 0),
                        child: VoiceMessageView(
                          controller: VoiceController(
                            audioSrc: "${$system['system_uploads']}/${message['voice_note']}",
                            maxDuration: Duration(seconds: int.parse($system['voice_notes_durtaion'])),
                            isFile: false,
                            onComplete: () {},
                            onPause: () {},
                            onPlaying: () {},
                          ),
                          innerPadding: 12,
                          cornerRadius: 18,
                          backgroundColor: isCurrentUser
                              ? xPrimaryColor
                              : Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF3a3b3b)
                                  : Colors.grey.shade200,
                          activeSliderColor: isCurrentUser
                              ? Colors.white
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                          circlesColor: isCurrentUser
                              ? xPrimaryColor
                              : Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF3a3b3b)
                                  : Colors.grey.shade200,
                          playIcon: Icon(Icons.play_arrow_rounded,
                              color: isCurrentUser
                                  ? Colors.white
                                  : Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black),
                          pauseIcon: Icon(Icons.pause_rounded,
                              color: isCurrentUser
                                  ? Colors.white
                                  : Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black),
                          size: 40,
                          counterTextStyle: TextStyle(
                              color: isCurrentUser
                                  ? Colors.white
                                  : Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                              fontSize: 10),
                          circlesTextStyle: TextStyle(
                              color: isCurrentUser
                                  ? Colors.white
                                  : Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    // Timeago
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Text(
                        timeago.format(convertedTime(message['time']), locale: languageCode),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
