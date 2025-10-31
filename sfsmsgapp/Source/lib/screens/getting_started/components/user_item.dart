import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import App Files
import '../../../states/system_state.dart';
import '../../../utilities/functions.dart';
import '../../../widgets/snackbars.dart';

class UserItem extends ConsumerStatefulWidget {
  const UserItem({
    super.key,
    required this.userObject,
    required this.connectionStatus,
    required this.onDone,
  });

  final Map userObject;
  final String connectionStatus;
  final Function(bool) onDone;
  @override
  ConsumerState<UserItem> createState() => _UserItemState();
}

class _UserItemState extends ConsumerState<UserItem> {
  bool isLoading = false;

  // API Call: Add Friend
  Future<void> addFriend() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    final response = await sendAPIRequest(
      'user/connect',
      method: 'POST',
      body: {
        'do': 'friend-add',
        'id': int.parse(widget.userObject['user_id']),
      },
    );
    setState(() {
      isLoading = false;
    });
    if (response['statusCode'] == 200) {
      widget.onDone(true);
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          snackBarError(response['body']['message']),
        );
    }
  }

  // API Call: Follow User
  Future<void> followUser() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    final response = await sendAPIRequest(
      'user/connect',
      method: 'POST',
      body: {
        'do': 'follow',
        'id': int.parse(widget.userObject['user_id']),
      },
    );
    setState(() {
      isLoading = false;
    });
    if (response['statusCode'] == 200) {
      widget.onDone(true);
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          snackBarError(response['body']['message']),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final $system = ref.watch(systemProvider);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(widget.userObject['user_picture']!),
      ),
      title: Text(widget.userObject['user_firstname']!),
      trailing: (isTrue($system['friends_enabled']))
          ? ElevatedButton(
              onPressed: addFriend,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: (isLoading) ? const CircularProgressIndicator(color: Colors.white) : Text(tr("Add")),
            )
          : ElevatedButton(
              onPressed: followUser,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: (isLoading) ? const CircularProgressIndicator(color: Colors.white) : Text(tr("Follow")),
            ),
    );
  }
}
