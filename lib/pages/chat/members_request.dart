import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/structure/providers/groupchat_provider.dart';

class MembersRequest extends ConsumerWidget {
  final String groupChatId;

  const MembersRequest({
    super.key,
    required this.groupChatId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FirebaseAuth auth = FirebaseAuth.instance;
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
              data: (memberRequests) {
                return auth.currentUser!.uid == memberRequests.creatorId
                    ? ListView.builder(
                        itemCount: memberRequests.membersRequest.length,
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
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  top: 5,
                                  bottom: 5,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        memberRequest,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        ref
                                            .read(
                                                groupChatMemberRequestProvider)
                                            .acceptOrreject(
                                              groupChatId,
                                              memberRequest,
                                              memberRequestId,
                                              false,
                                            );
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        ref
                                            .read(
                                                groupChatMemberRequestProvider)
                                            .acceptOrreject(
                                              groupChatId,
                                              memberRequest,
                                              memberRequestId,
                                              true,
                                            );
                                      },
                                      icon: const Icon(Icons.check),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Container();
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
