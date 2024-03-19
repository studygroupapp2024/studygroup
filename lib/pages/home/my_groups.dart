import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/pages/chat/chat_page.dart';
import 'package:study_buddy/structure/providers/groupchat_provider.dart';

class FindPage extends ConsumerWidget {
  FindPage({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGroupIds = ref.watch(userChatIdsProvider(_auth.currentUser!.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Study Groups"),
        centerTitle: true,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          return userGroupIds.when(
            data: (ids) {
              return ListView.builder(
                itemCount: ids.length,
                itemBuilder: (context, index) {
                  final chatIds = ids[index];
                  final String fullName = chatIds.lastMessageSender;
                  final List<String> nameParts = fullName.split(' ');
                  final String firstName = nameParts[0];
                  final String format = (chatIds.lastMessageTimeSent != null)
                      ? '${firstName.substring(0, 1).toUpperCase()}${firstName.substring(1).toLowerCase()}'
                      : '';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                groupChatId: chatIds.docID.toString(),
                                title: chatIds.studyGroupTitle,
                                creator: chatIds.creatorId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          height: 100,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(30),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60,
                                    padding: const EdgeInsets.all(5),
                                    child: const CircleAvatar(
                                      radius: 30,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 53,
                                    width: 54,
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      chatIds.studyGroupTitle,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    chatIds.lastMessageTimeSent != null
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "$format: ${chatIds.lastMessage}",
                                                style: const TextStyle(
                                                    fontSize: 13),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      fontSize: 12),
                                                  DateFormat('hh:mm a').format(
                                                    chatIds.lastMessageTimeSent!
                                                        .toDate(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            chatIds.studyGroupDescription,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
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
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        },
      ),
    );
  }
}
