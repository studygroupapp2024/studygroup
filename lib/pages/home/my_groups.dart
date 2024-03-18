import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatPage(groupChatId: chatIds.groupChatId),
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
                              const CircleAvatar(
                                radius: 30,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(child: Text(chatIds.groupChatId)),
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

// () {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => ChatPage(
//         chatName: data["groupChatTitle"],
//         groupChatId: data["groupChatId"],
//       ),
//     ),
//   );
// },
