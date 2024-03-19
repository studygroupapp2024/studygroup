import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/pages/chat/members.dart';
import 'package:study_buddy/pages/chat/members_request.dart';

class ChatInfo extends ConsumerWidget {
  final String groupChatId;
  final String creator;
  const ChatInfo({
    super.key,
    required this.groupChatId,
    required this.creator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Info"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Members(groupChatId: groupChatId),
                  ),
                );
              },
              child: const Text(
                "Members",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            if (auth.currentUser!.uid == creator)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MembersRequest(
                        groupChatId: groupChatId,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Member Request",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
