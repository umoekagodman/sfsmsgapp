import 'dart:async';
import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Import App Files
import '../../common/themes.dart';
import '../../routes/router.gr.dart';
import '../../states/system_state.dart';
import '../../utilities/functions.dart';
import 'components/contact_item.dart';

@RoutePage()
class ContactsScreen extends ConsumerStatefulWidget {
  static const routeName = 'contacts';

  ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final scrollController = ScrollController();
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  Timer? heartbeatTimer;
  var contacts = [];
  int offset = 0;
  bool initialLoadDone = false;
  bool isLoading = false;
  bool hasMore = true;
  bool isUpdating = false;

  // API Call: loadContacts
  Future<void> loadContacts({replace = false}) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    final response = await sendAPIRequest('chat/contacts', queryParameters: {
      'offset': offset.toString(),
    });
    if (response['statusCode'] == 200) {
      if (response['body']['data'] is List && response['body']['data'].isNotEmpty) {
        setState(() {
          if (replace == true) contacts.clear();
          contacts.addAll(response['body']['data']);
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

  // refreshContacts
  Future<void> refreshContacts() async {
    if (isUpdating || isLoading) return;
    setState(() {
      offset = 0;
      isUpdating = true;
    });
    await loadContacts(replace: true);
    setState(() {
      isUpdating = false;
    });
  }

  // Heartbeat: initHeartbeat
  void initHeartbeat() {
    final $system = ref.read(systemProvider);
    final heartbeatMinutes = ($system['chat_heartbeat'] != null) ? int.parse($system['chat_heartbeat']) : 5;
    heartbeatTimer = Timer.periodic(Duration(seconds: heartbeatMinutes), (timer) {
      setState(() {
        refreshContacts();
      });
    });
  }

  // Scroll Listener
  void onScroll() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMore) {
        loadContacts();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadContacts();
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
            Text(context.tr("Contacts")),
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
            onPressed: () => context.router.push(SearchRoute()),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshContacts,
        child: Builder(
          builder: (context) {
            if (!initialLoadDone) {
              return Center(child: CircularProgressIndicator());
            } else if (contacts.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: Text(tr("No users found")),
                    ),
                  ),
                ],
              );
            } else {
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                itemCount: contacts.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < contacts.length) {
                    return ContactItem(user: contacts[index]);
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
