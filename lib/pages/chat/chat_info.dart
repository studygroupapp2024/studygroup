import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/pages/chat/members.dart';
import 'package:study_buddy/pages/chat/members_request.dart';
import 'package:study_buddy/structure/providers/groupchat_provider.dart';
import 'package:study_buddy/structure/providers/university_provider.dart';

class ChatInfo extends ConsumerWidget {
  final String groupChatId;
  final String creator;
  final String groupChatTitle;
  final String groupChatDescription;
  final String dateCreated;
  const ChatInfo({
    super.key,
    required this.groupChatId,
    required this.creator,
    required this.groupChatTitle,
    required this.groupChatDescription,
    required this.dateCreated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final image = ref.watch(singleGroupChatInformationProvider(groupChatId));
    print("image: $image");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Info"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      image.when(
                        data: (image) {
                          return SizedBox(
                            height: 125,
                            width: 125,
                            child: GestureDetector(
                              onTap: () async {
                                final result =
                                    await FilePicker.platform.pickFiles(
                                  allowMultiple: false,
                                  type: FileType.custom,
                                  allowedExtensions: [
                                    'jpg',
                                    'png',
                                  ],
                                );

                                if (result == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("No item has been selected."),
                                    ),
                                  );
                                  return;
                                }
                                final path = result.files.single.path;
                                final filename = result.files.single.name;
                                ref
                                    .read(groupChatProvider)
                                    .changeGroupChatProfile(
                                      path.toString(),
                                      filename,
                                      groupChatId,
                                      await ref
                                          .watch(
                                              institutionIdProviderBasedOnUser)
                                          .getUniversityBasedId(),
                                    );
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                  ),
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(image.groupChatImage!),
                                    radius: 58,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        radius: 13,
                                        child: const Icon(Icons.add),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        groupChatTitle,
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "About",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  groupChatDescription,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Created on $dateCreated",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Chat",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Members(
                          groupChatId: groupChatId,
                          creatorId: creator,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Members",
                    style: TextStyle(
                      fontSize: 16,
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
                              groupChatTitle: groupChatTitle),
                        ),
                      );
                    },
                    child: const Text(
                      "Request",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
