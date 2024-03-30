import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/structure/providers/groupchat_provider.dart';
import 'package:study_buddy/structure/providers/university_provider.dart';

class MembersRequest extends ConsumerWidget {
  final String groupChatId;
  final String groupChatTitle;

  const MembersRequest({
    super.key,
    required this.groupChatId,
    required this.groupChatTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final memberRequestModel = ref.watch(
      singleGroupChatInformationProvider(groupChatId),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Members Request"),
      ),
      body: memberRequestModel.when(
        data: (memberRequests) {
          if (memberRequests.membersRequestId.isEmpty) {
            return Center(
              child: Text("No members request",
                  style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.tertiaryContainer)),
            );
          } else {
            return auth.currentUser!.uid == memberRequests.creatorId
                ? ListView.builder(
                    itemCount: memberRequests.membersRequestId.length,
                    itemBuilder: (context, index) {
                      final memberRequest =
                          memberRequests.membersRequest[index];
                      final memberRequestId =
                          memberRequests.membersRequestId[index];
                      return Padding(
                        padding: const EdgeInsets.all(15),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    memberRequest,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  ref
                                      .read(groupChatMemberRequestProvider)
                                      .acceptOrreject(
                                        groupChatId,
                                        memberRequest,
                                        memberRequestId,
                                        false,
                                        groupChatTitle,
                                        await ref
                                            .watch(
                                                institutionIdProviderBasedOnUser)
                                            .getUniversityBasedId(),
                                      );
                                },
                                icon: const Icon(Icons.close),
                              ),
                              IconButton(
                                onPressed: () async {
                                  ref
                                      .read(groupChatMemberRequestProvider)
                                      .acceptOrreject(
                                        groupChatId,
                                        memberRequest,
                                        memberRequestId,
                                        true,
                                        groupChatTitle,
                                        await ref
                                            .watch(
                                                institutionIdProviderBasedOnUser)
                                            .getUniversityBasedId(),
                                      );
                                },
                                icon: const Icon(Icons.check),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Container();
          }
        },
        error: (error, stackTrace) {
          return Center(
            child: Text('Error: $error'),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
