import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/structure/providers/groupchat_provider.dart';

class Members extends ConsumerWidget {
  final String groupChatId;
  const Members({
    super.key,
    required this.groupChatId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberRequestModel = ref.watch(
      singleGroupChatInformationProvider(groupChatId),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Members"),
      ),
      body: Expanded(
        child: Consumer(
          builder: (context, ref, child) {
            return memberRequestModel.when(
              data: (membersList) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: membersList.membersId.length,
                  itemBuilder: (context, index) {
                    final members = membersList.membersId[index];
                    final membersId = membersList.membersId[index];
                    final creator = membersList.creatorId;

                    return ListTile(
                      title: Text(members),
                      subtitle: membersId == creator
                          ? const Text("Admin")
                          : const Text("Member"),
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
      ),
    );
  }
}
