import 'dart:async';
import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Import App Files
import '../../common/themes.dart';
import '../../states/system_state.dart';
import '../../utilities/functions.dart';
import 'components/conversation_item.dart';
import 'components/new_message.dart';

@RoutePage()
class ChatsScreen extends ConsumerStatefulWidget {
  static const routeName = 'chats';

  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  final scrollController = ScrollController();
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  Timer? heartbeatTimer;
  var conversations = [];
  int offset = 0;
  bool isLoading = false;
  bool initialLoadDone = false;
  bool hasMore = true;
  bool isUpdating = false;

  // API Call: loadConversations
  Future<void> loadConversations({replace = false}) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    final response = await sendAPIRequest(
      'chat/conversations',
      queryParameters: {
        'offset': offset.toString(),
      },
    );
    if (!mounted) return;
    if (response['statusCode'] == 200) {
      if (response['body']['data'] is List && response['body']['data'].isNotEmpty) {
        setState(() {
          if (replace == true) conversations.clear();
          conversations.addAll(response['body']['data']);
          offset++;
          if (response['body']['has_more'] == true) {
            hasMore = true;
          } else {
            hasMore = false;
          }
        });
      } else {
        setState(() {
          hasMore = false;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(tr("There is something that went wrong!")),
            ),
          );
      }
    }
    if (mounted) {
      setState(() {
        isLoading = false;
        initialLoadDone = true;
      });
    }
  }

  // API Call: deleteConversation
  Future<void> deleteConversation(String conversationId) async {
    final response = await sendAPIRequest(
      'chat/reactions/delete',
      method: 'POST',
      body: {
        'conversation_id': conversationId,
      },
    );
    if (response['statusCode'] == 200) {
      setState(() {
        conversations.removeWhere((c) => c['conversation_id'] == conversationId);
      });
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

  // API Call: leaveConversation
  Future<void> leaveConversation(String conversationId) async {
    final response = await sendAPIRequest(
      'chat/reactions/leave',
      method: 'POST',
      body: {
        'conversation_id': conversationId,
      },
    );
    if (response['statusCode'] == 200) {
      setState(() {
        conversations.removeWhere((c) => c['conversation_id'] == conversationId);
      });
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

  // refreshConversations
  Future<void> refreshConversations() async {
    if (isUpdating || isLoading) return;
    setState(() {
      offset = 0;
      isUpdating = true;
    });
    await loadConversations(replace: true);
    setState(() {
      isUpdating = false;
    });
  }

  // Heartbeat: initHeartbeat
  void initHeartbeat() {
    final $system = ref.read(systemProvider);
    final heartbeatMinutes = ($system['chat_heartbeat'] != null) ? int.parse($system['chat_heartbeat']) : 5;
    heartbeatTimer = Timer.periodic(Duration(seconds: heartbeatMinutes), (timer) {
      if (mounted) {
        refreshConversations();
      } else {
        timer.cancel();
      }
    });
  }

  // Scroll Listener
  void onScroll() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMore) {
        loadConversations();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadConversations();
    initHeartbeat();
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    heartbeatTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            Text(context.tr("Chats")),
            if (isUpdating) SizedBox(width: 10),
            if (isUpdating)
              SpinKitFadingCube(
                color: xPrimaryColor,
                size: 10,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                useSafeArea: true,
                isScrollControlled: true,
                elevation: 0,
                builder: (context) {
                  return NewMessage();
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshConversations,
        child: Builder(
          builder: (context) {
            if (!initialLoadDone) {
              return Center(child: CircularProgressIndicator());
            } else if (conversations.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: Text(tr("No conversations found")),
                    ),
                  ),
                ],
              );
            } else {
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                itemCount: conversations.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < conversations.length) {
                    final conversation = conversations[index];
                    return ConversationItem(
                      conversation: conversation,
                      onDelete: deleteConversation,
                      onLeave: leaveConversation,
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
