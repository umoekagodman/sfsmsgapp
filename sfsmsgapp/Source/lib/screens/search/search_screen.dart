import 'dart:async';
import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';

// Import App Files
import '../../utilities/functions.dart';
import '../contacts/components/contact_item.dart';

@RoutePage()
class SearchScreen extends StatelessWidget {
  static const routeName = 'search';

  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("Search")),
      ),
      body: _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final searchController = TextEditingController();
  final scrollController = ScrollController();
  Timer? debounce;
  var contacts = [];
  int offset = 0;
  bool isLoading = false;
  bool hasMore = true;

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
      },
    );
    if (response['statusCode'] == 200) {
      if (response['body']['data'] is List) {
        final List<dynamic> newContacts = response['body']['data'];
        setState(() {
          contacts.addAll(newContacts);
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
      if (replace == true) {
        isLoading = false;
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

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    debounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0XFF3a3b3b) : const Color(0XFFf0f1f4),
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: tr('Search'),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
      ],
    );
  }
}
