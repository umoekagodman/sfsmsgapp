import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import '../../../routes/router.gr.dart';
import '../../../utilities/functions.dart';
import '../../../widgets/profile_avatar.dart';
import '../../contacts/components/contact_item.dart';
import '../../conversation/components/chat_composer.dart';

class NewMessage extends ConsumerStatefulWidget {
  const NewMessage({super.key});

  @override
  ConsumerState<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends ConsumerState<NewMessage> {
  final searchController = TextEditingController();
  final textMessageController = TextEditingController();
  final scrollController = ScrollController();
  Timer? debounce;
  Timer? typingTimer;
  var contacts = [];
  var selectedContacts = [];
  int offset = 0;
  bool isLoading = false;
  bool hasMore = true;
  bool isTyping = false;

  // API Call: searchContacts
  Future<void> searchContacts({required String query, replace = true}) async {
    if (isLoading) return;
    setState(() {
      if (replace == true) {
        isLoading = true;
        offset = 0;
        contacts.clear();
      }
    });
    final response = await sendAPIRequest(
      'chat/contacts',
      queryParameters: {
        'query': query,
        'offset': offset.toString(),
        if (selectedContacts.isNotEmpty) 'skipped_ids': selectedContacts.map((user) => user['user_id']).toList().toString(),
      },
    );
    if (response['statusCode'] == 200) {
      if (response['body']['data'] is List) {
        final newContacts = response['body']['data'];
        setState(() {
          contacts.addAll(newContacts);
          offset++;
          hasMore = (response['body']['has_more'] == true) ? true : false;
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
      if (replace == true) isLoading = false;
    });
  }

  // Add Tag
  void addTag(dynamic user) {
    if (!selectedContacts.contains(user)) {
      setState(() {
        selectedContacts.add(user);
        searchController.clear();
        contacts.clear();
        offset = 0;
        isLoading = false;
      });
    }
  }

  // Remove Tag
  void removeTag(dynamic user) {
    setState(() {
      selectedContacts.remove(user);
    });
  }

  // Handle Backspace
  void handleBackspace(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace && searchController.text.isEmpty && selectedContacts.isNotEmpty) {
      setState(() {
        selectedContacts.removeLast();
      });
    }
  }

  // On Search Changed
  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty) {
        searchContacts(query: value);
      } else {
        setState(() {
          contacts.clear();
          offset = 0;
        });
      }
    });
  }

  // Scroll Listener
  void onScroll() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMore) {
        searchContacts(query: searchController.text, replace: false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    textMessageController.dispose();
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    debounce?.cancel();
    typingTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            tr("New Message"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: SizedBox(width: 0),
          actions: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // To
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0XFF3a3b3b) : const Color(0XFFf0f1f4),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(tr("To:"), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: [
                          ...selectedContacts
                              .map(
                                (user) => Chip(
                                  avatar: ProfileAvatar(
                                    imageUrl: user['user_picture'],
                                  ),
                                  label: Text(user['user_fullname']),
                                  onDeleted: () => removeTag(user),
                                ),
                              )
                              .toList(),
                          SizedBox(
                            width: 200,
                            child: KeyboardListener(
                              focusNode: FocusNode(),
                              onKeyEvent: handleBackspace,
                              child: TextField(
                                controller: searchController,
                                onChanged: onSearchChanged,
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    searchContacts(query: value);
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: tr('Search'),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  suffixIcon: searchController.text.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              searchController.clear();
                                              contacts.clear();
                                              offset = 0;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                            size: 16,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Search Results
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (isLoading && contacts.isEmpty) {
                      return Center(child: CircularProgressIndicator());
                    } else if (contacts.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Center(
                              child: (offset == 0) ? SizedBox(height: 0) : Text(tr("No users found")),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: contacts.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < contacts.length) {
                            return ContactItem(user: contacts[index], onContactSelected: addTag);
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
              // Chat Composer
              if (selectedContacts.isNotEmpty)
                ChatComposer(
                  selectedContacts: selectedContacts,
                  onSendMessage: (data) {
                    context.router.pop();
                    context.router.push(ConversationRoute(conversationId: data['conversation_id']));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
