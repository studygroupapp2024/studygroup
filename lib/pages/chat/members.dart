import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/components/containers/members_container.dart';
import 'package:study_buddy/structure/providers/groupchat_provider.dart';

class Members extends ConsumerWidget {
  final String groupChatId;
  final String creatorId;
  const Members({
    super.key,
    required this.groupChatId,
    required this.creatorId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupChatMembers = ref.watch(
      groupChatMembersProvider(groupChatId),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Members"),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          return groupChatMembers.when(
            data: (membersList) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: membersList.length,
                itemBuilder: (context, index) {
                  final members = membersList[index];

                  return MembersContainer(
                    member: members.name,
                    role: members.isAdmin ? "Admin" : "Member",
                    image: members.imageUrl,
                    isAdmin: members.isAdmin,
                    creatorId: creatorId,
                    onPressed: () {
                      ref
                          .read(groupChatProvider)
                          .removeMember(groupChatId, members.userId);
                    },
                  );
                },
              );
            },
            error: (error, stackTrace) {
              return Center(
                child: Text('Error: $error'),
              );
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }
}
