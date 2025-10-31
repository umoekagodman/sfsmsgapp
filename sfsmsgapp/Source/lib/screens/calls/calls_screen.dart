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
import 'components/call_item.dart';

@RoutePage()
class CallsScreen extends ConsumerStatefulWidget {
  static const routeName = 'calls';

  const CallsScreen({super.key});

  @override
  ConsumerState<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallsScreen> {
  final scrollController = ScrollController();
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  Timer? heartbeatTimer;
  var calls = [];
  int offset = 0;
  bool initialLoadDone = false;
  bool isLoading = false;
  bool hasMore = true;
  bool isUpdating = false;

  // API Call: loadCalls
  Future<void> loadCalls({replace = false}) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    final response = await sendAPIRequest('chat/calls', queryParameters: {
      'offset': offset.toString(),
    });
    if (response['statusCode'] == 200) {
      if (response['body']['data'] is List && response['body']['data'].isNotEmpty) {
        setState(() {
          if (replace == true) calls.clear();
          calls.addAll(response['body']['data']);
          offset++;
          hasMore = (isTrue(response['body']['has_more']) ? true : false);
        });
      } else {
        setState(() {
          hasMore = false;
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
    setState(() {
      isLoading = false;
      initialLoadDone = true;
    });
  }

  // refreshCalls
  Future<void> refreshCalls() async {
    if (isUpdating || isLoading) return;
    setState(() {
      offset = 0;
      isUpdating = true;
    });
    await loadCalls(replace: true);
    setState(() {
      isUpdating = false;
    });
  }

  // Heartbeat: initHeartbeat
  void initHeartbeat() {
    final $system = ref.read(systemProvider);
    final heartbeatMinutes = ($system['chat_heartbeat'] != null) ? int.parse($system['chat_heartbeat']) : 5;
    heartbeatTimer = Timer.periodic(Duration(seconds: heartbeatMinutes), (timer) {
      refreshCalls();
    });
  }

  // Scroll Listener
  void onScroll() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMore) {
        loadCalls();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadCalls();
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
            Text(context.tr("Calls")),
            if (isUpdating) SizedBox(width: 10),
            if (isUpdating)
              SpinKitFadingCube(
                color: xPrimaryColor,
                size: 10,
              ),
          ],
        ),
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshCalls,
        child: Builder(
          builder: (context) {
            if (!initialLoadDone) {
              return Center(child: CircularProgressIndicator());
            } else if (calls.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: Text(tr("No calls found")),
                    ),
                  ),
                ],
              );
            } else {
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                itemCount: calls.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < calls.length) {
                    final call = calls[index];
                    return CallItem(call: call);
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
