import 'dart:async';
import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

// Import App Files
import '../../common/config.dart';
import '../../common/themes.dart';
import '../../states/system_state.dart';
import '../../utilities/functions.dart';
import '../../utilities/load_state.dart';
import '../../utilities/timeago_locale/timeago_locale.dart';
import '../../widgets/error.dart';
import '../../widgets/loading.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/profile_overlaped_avatars.dart';
import 'components/chat_message.dart';
import 'components/typing_indicator_bubble.dart';
import 'components/chat_composer.dart';

@RoutePage()
class ConversationScreen extends ConsumerStatefulWidget {
  static const routeName = '/conversation';

  final String? conversationId;
  final String? userId;
  final Map<String, dynamic>? user;

  ConversationScreen({
    super.key,
    this.conversationId,
    this.userId,
    this.user,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final scrollController = ScrollController();
  Timer? heartbeatTimer;
  Map<String, dynamic> conversation = {};
  bool isRecipientsTyping = false;
  String isRecipientsTypingName = '';
  bool isRecipientsSeen = false;
  String isRecipientsSeenName = '';
  LoadState loadState = LoadState.loading;
  int offset = 1;
  bool isLoading = false;
  bool hasMore = true;

  // API Call: getConversation
  Future<void> getConversation() async {
    final $user = ref.read(userProvider);
    final response = await sendAPIRequest('chat/conversation', queryParameters: {
      'user_id': widget.userId,
      'conversation_id': widget.conversationId,
    });
    if (response['statusCode'] == 200) {
      if (response['body']['data'] is Map && response['body']['data'].isNotEmpty) {
        setState(() {
          conversation = response['body']['data'];
          hasMore = isTrue(response['body']['has_more']);
          if (response['body']['data']['seen_name_list'] != null && conversation['messages'].last['user_id'] == $user['user_id']) {
            isRecipientsSeen = true;
            isRecipientsSeenName = response['body']['data']['seen_name_list'];
          }
        });
      }
      setState(() {
        loadState = LoadState.loaded;
      });
    } else {
      setState(() {
        loadState = LoadState.error;
      });
    }
  }

  // API Call: getMessages
  Future<void> getMessages() async {
    if (isLoading) return;
    if (conversation.isEmpty) return;
    setState(() {
      isLoading = true;
    });
    final response = await sendAPIRequest('chat/messages', queryParameters: {
      'conversation_id': widget.conversationId,
      'offset': offset.toString(),
    });
    if (response['statusCode'] == 200) {
      if (response['body']['data'] is Map && response['body']['data'].isNotEmpty) {
        final new_messages = response['body']['data']['messages'] ?? [];
        if (new_messages.isNotEmpty) {
          setState(() {
            conversation['messages'].insertAll(0, new_messages);
            offset++;
            hasMore = (isTrue(response['body']['has_more']) ? true : false);
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(tr("There is something that went wrong!")),
          ),
        );
    }
    setState(() {
      isLoading = false;
    });
  }

  // API Call: chatHeartbeat
  Future<void> chatHeartbeat() async {
    if (conversation.isEmpty) return;
    final $user = ref.read(userProvider);
    final response = await sendAPIRequest('chat/messages', queryParameters: {
      'conversation_id': conversation['conversation_id'],
      'last_message_id': conversation['messages'].last['message_id'],
    });
    if (response['statusCode'] == 200) {
      if (response['body']['data'] is Map && response['body']['data'].isNotEmpty) {
        final new_messages = response['body']['data']['messages'] ?? [];
        final typing_name_list = response['body']['data']['typing_name_list'] ?? '';
        final seen_name_list = response['body']['data']['seen_name_list'] ?? '';
        final user_is_online = response['body']['data']['user_is_online'];
        final user_last_seen = response['body']['data']['user_last_seen'];
        setState(() {
          /* check for a new messages for this conversation */
          if (new_messages.isNotEmpty) {
            conversation['messages'].addAll(new_messages);
          }
          /* check single user's chat status (online|offline) */
          if (!isTrue(conversation['multiple_recipients']) && user_is_online != null) {
            if (conversation['user_is_online'] != user_is_online) {
              conversation['user_is_online'] = user_is_online;
              conversation['user_last_seen'] = user_last_seen;
            }
          }
          /* check for typing status */
          if (typing_name_list != '') {
            isRecipientsTyping = true;
            isRecipientsTypingName = typing_name_list;
          } else {
            isRecipientsTyping = false;
            isRecipientsTypingName = '';
          }
          /* check for seen status */
          if (seen_name_list != '' && conversation['messages'].last['user_id'] == $user['user_id']) {
            isRecipientsSeen = true;
            isRecipientsSeenName = seen_name_list;
          } else {
            isRecipientsSeen = false;
            isRecipientsSeenName = '';
          }
          updateSeenStatus();
        });
      }
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(tr("There is something that went wrong!")),
          ),
        );
    }
  }

  // API Call: updateSeenStatus
  Future<void> updateSeenStatus() async {
    final $system = ref.read(systemProvider);
    if (!isTrue($system['chat_seen_enabled'])) return;
    if (conversation.isEmpty) return;
    await sendAPIRequest(
      'chat/reactions/seen',
      method: 'POST',
      body: {
        'ids': conversation['conversation_id'],
      },
    );
  }

  // Heartbeat: initHeartbeat
  void initHeartbeat() {
    final $system = ref.read(systemProvider);
    final heartbeatMinutes = ($system['chat_heartbeat'] != null) ? int.parse($system['chat_heartbeat']) : 5;
    heartbeatTimer = Timer.periodic(Duration(seconds: heartbeatMinutes), (timer) {
      chatHeartbeat();
    });
  }

  // Scroll Listener
  void onScroll() {
    if (scrollController.position.pixels <= 50) {
      if (!isLoading && hasMore) {
        getMessages();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getConversation();
    initHeartbeat();
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    heartbeatTimer?.cancel();
    scrollController.removeListener(onScroll);
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final $system = ref.read(systemProvider);
    final $user = ref.read(userProvider);
    final languageCode = Localizations.localeOf(context).languageCode;
    setLocaleMessagesForLocale(languageCode);
    switch (loadState) {
      case LoadState.loading:
        return Loading();
      case LoadState.error:
        return Error(callback: () {
          setState(() {
            loadState = LoadState.loading;
          });
          getConversation();
        });
      case LoadState.loaded:
        return Scaffold(
          appBar: AppBar(
            title: (conversation.isEmpty)
                ? Row(
                    children: [
                      ProfileAvatar(
                        imageUrl: widget.user!['user_picture']!,
                        isOnline: isTrue(widget.user!['user_is_online']),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user!['user_fullname'],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            (isTrue(widget.user!['user_is_online']))
                                ? context.tr("Online")
                                : timeago.format(convertedTime(widget.user!['user_last_seen']), locale: languageCode),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      (isTrue(conversation['multiple_recipients']) && conversation['picture_left'] != null && conversation['picture_right'] != null)
                          ? OverlappingProfileAvatars(
                              leftImageUrl: conversation['picture_left'],
                              rightImageUrl: conversation['picture_right'],
                            )
                          : ProfileAvatar(
                              imageUrl: conversation['picture']!,
                              isOnline: isTrue(conversation['user_is_online']),
                            ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation['name'],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          (!isTrue(conversation['multiple_recipients']))
                              ? Text(
                                  (isTrue(conversation['user_is_online']))
                                      ? context.tr("Online")
                                      : timeago.format(convertedTime(conversation['user_last_seen']), locale: languageCode),
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                                )
                              : SizedBox(width: 0),
                        ],
                      ),
                    ],
                  ),
            actions: [
              if ((conversation.isNotEmpty && !isTrue(conversation['multiple_recipients'])) || widget.user != null) ...[
                if (audioVideoCallEnabled && isTrue($system['audio_call_enabled']) && isTrue($user['can_start_audio_call']))
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      "assets/images/icons/chat/call_audio.svg",
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(xPrimaryColor, BlendMode.srcIn),
                    ),
                  ),
                if (audioVideoCallEnabled && isTrue($system['video_call_enabled']) && isTrue($user['can_start_video_call']))
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      "assets/images/icons/chat/call_video.svg",
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(xPrimaryColor, BlendMode.srcIn),
                    ),
                  ),
              ]
            ],
          ),
          body: Column(
            children: [
              // Messages
              Expanded(
                child: (conversation.isEmpty)
                    ? ListView.builder(
                        reverse: true,
                        itemCount: 0,
                        itemBuilder: (context, index) {
                          return SizedBox(width: 0);
                        },
                      )
                    : ListView.builder(
                        controller: scrollController,
                        reverse: true,
                        padding: EdgeInsets.only(bottom: 20),
                        itemCount: conversation['messages'].length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == conversation['messages'].length) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final message = conversation['messages'][conversation['messages'].length - 1 - index];
                          return ChatMessage(
                            message: message,
                            isCurrentUser: message['user_id'] == $user['user_id'],
                            isMultipleRecipients: conversation['multiple_recipients'],
                          );
                        },
                      ),
              ),
              // Seen Status
              if (isRecipientsSeen)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SvgPicture.asset(
                        "assets/images/icons/chat/seen.svg",
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(xPrimaryColor, BlendMode.srcIn),
                      ),
                      SizedBox(width: 5),
                      Text(context.tr("Seen by"), style: TextStyle(fontSize: 12)),
                      SizedBox(width: 5),
                      Text(isRecipientsSeenName),
                    ],
                  ),
                ),
              // Typing Indicator
              if (isRecipientsTyping)
                Row(
                  children: [
                    TypingIndicatorBubble(),
                    Text(isRecipientsTypingName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                    SizedBox(width: 5),
                    Text(context.tr("typing")),
                  ],
                ),
              // Chat Composer
              ChatComposer(
                conversationId: widget.conversationId,
                conversation: conversation as Map<String, dynamic>?,
                user: widget.user,
                onNewMessage: (data) {
                  if (conversation.isEmpty) {
                    setState(() {
                      conversation = data;
                      conversation['messages'] = [];
                      conversation['messages'].add(data['last_message']);
                      isRecipientsSeen = false;
                      isRecipientsSeenName = '';
                    });
                  } else {
                    setState(() {
                      conversation['messages'].add(data['last_message']);
                      isRecipientsSeen = false;
                      isRecipientsSeenName = '';
                    });
                  }
                },
              ),
            ],
          ),
        );
    }
  }
}
