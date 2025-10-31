import 'dart:async';
import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';

// Import App Files
import '../../common/config.dart';
import '../../routes/router.gr.dart';
import '../../common/themes.dart';
import '../../states/system_state.dart';
import '../../utilities/functions.dart';
import 'components/live_counter.dart';

@RoutePage()
class MainScreen extends ConsumerStatefulWidget {
  static const routeName = '/main';

  MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  Timer? heartbeatTimer;
  int? _previousIndex;

  // API Call: resetChatsCounter
  Future<void> resetChatsCounter() async {
    await sendAPIRequest(
      'data/reset',
      method: 'POST',
      body: {
        'reset': 'messages',
      },
    );
  }

  // API Call: resetCallsCounter
  Future<void> resetCallsCounter() async {
    await sendAPIRequest(
      'data/reset',
      method: 'POST',
      body: {
        'reset': 'calls',
      },
    );
  }

  // API Call: registerOneSignalId
  Future<void> registerOneSignalId() async {
    final $user = ref.read(userProvider);
    /* check if oneSignalId is already registered */
    if ($user.isEmpty || ($user['session_onesignal_user_id'] != null && $user['session_onesignal_user_id'].isNotEmpty)) {
      return;
    }
    /* get oneSignalId */
    final oneSignalId = await getOneSignalId();
    if (oneSignalId == null) {
      return;
    }
    /* register oneSignalId */
    final response = await sendAPIRequest(
      'user/onesignal',
      method: 'POST',
      body: {
        'onesignal_id': oneSignalId,
      },
    );
    if (response['statusCode'] == 200) {
      ref.read(userProvider.notifier).state['session_onesignal_user_id'] = oneSignalId;
    }
  }

  // Heartbeat: initHeartbeat
  void initHeartbeat() {
    final $system = ref.read(systemProvider);
    final heartbeatMinutes = ($system['chat_heartbeat'] != null) ? int.parse($system['chat_heartbeat']) : 5;
    heartbeatTimer = Timer.periodic(Duration(seconds: heartbeatMinutes), (timer) async {
      try {
        // ignore: unused_result
        await ref.refresh(systemConfigProvider.future);
      } catch (e) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ),
          );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initHeartbeat();
    registerOneSignalId();
  }

  @override
  void dispose() {
    heartbeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final $user = ref.watch(userProvider);
    final $system = ref.watch(systemProvider);
    return AutoTabsScaffold(
      routes: [
        ChatsRoute(),
        if (audioVideoCallEnabled) CallsRoute(),
        ContactsRouter(),
        SettingsRouter(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        final currentIndex = tabsRouter.activeIndex;
        // Check if the user is leaving the chats tab
        if (_previousIndex == 0 && currentIndex != 0) {
          if (int.parse($user['user_live_messages_counter']) > 0) {
            resetChatsCounter();
            ref.read(userProvider.notifier).state['user_live_messages_counter'] = "0";
          }
        }
        // Check if the user is leaving the calls tab
        if (audioVideoCallEnabled) {
          if (_previousIndex == 1 && currentIndex != 1) {
            if (int.parse($user['user_live_calls_counter']) > 0) {
              resetCallsCounter();
              ref.read(userProvider.notifier).state['user_live_calls_counter'] = "0";
            }
          }
        }
        // Update previous index for next time
        _previousIndex = currentIndex;
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? xBackgroundColorDark : xBackgroundColor,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedItemColor: xPrimaryColor,
            unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? xTextColorDark : xBackgroundColorDark,
            currentIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
            items: [
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(
                      "assets/images/icons/navbar/chats.svg",
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        tabsRouter.activeIndex == 0
                            ? xPrimaryColor
                            : Theme.of(context).brightness == Brightness.dark
                                ? xTextColorDark
                                : xBackgroundColorDark,
                        BlendMode.srcIn,
                      ),
                    ),
                    if ($user.isNotEmpty && $user['user_live_messages_counter'] != null && int.parse($user['user_live_messages_counter']) > 0)
                      IconLiveCounter($user['user_live_messages_counter']),
                  ],
                ),
                label: tr("Chats"),
              ),
              if (audioVideoCallEnabled && (isTrue($system['audio_call_enabled']) || isTrue($system['video_call_enabled'])))
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SvgPicture.asset(
                        "assets/images/icons/navbar/calls.svg",
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          tabsRouter.activeIndex == 1
                              ? xPrimaryColor
                              : Theme.of(context).brightness == Brightness.dark
                                  ? xTextColorDark
                                  : xBackgroundColorDark,
                          BlendMode.srcIn,
                        ),
                      ),
                      if ($user.isNotEmpty && $user['user_live_calls_counter'] != null && int.parse($user['user_live_calls_counter']) > 0)
                        IconLiveCounter($user['user_live_calls_counter']),
                    ],
                  ),
                  label: tr("Calls"),
                ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  "assets/images/icons/navbar/contacts.svg",
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    tabsRouter.activeIndex == (audioVideoCallEnabled ? 2 : 1)
                        ? xPrimaryColor
                        : Theme.of(context).brightness == Brightness.dark
                            ? xTextColorDark
                            : xBackgroundColorDark,
                    BlendMode.srcIn,
                  ),
                ),
                label: tr("Contacts"),
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  "assets/images/icons/navbar/settings.svg",
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    tabsRouter.activeIndex == (audioVideoCallEnabled ? 3 : 2)
                        ? xPrimaryColor
                        : Theme.of(context).brightness == Brightness.dark
                            ? xTextColorDark
                            : xBackgroundColorDark,
                    BlendMode.srcIn,
                  ),
                ),
                label: tr("Settings"),
              ),
            ],
          ),
        );
      },
    );
  }
}
