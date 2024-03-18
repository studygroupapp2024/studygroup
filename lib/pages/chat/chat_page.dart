import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/components/containers/chat_bubble.dart';
import 'package:study_buddy/components/textfields/chat_textfield.dart';
import 'package:study_buddy/pages/chat/chat_info.dart';
import 'package:study_buddy/structure/group/chat_services.dart';
import 'package:study_buddy/structure/providers/chat_provider.dart';

class ChatPage extends ConsumerWidget {
  final String groupChatId;

  ChatPage({
    super.key,
    required this.groupChatId,
  });

  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // send message
      await _chatService.sendMessage(groupChatId, _messageController.text);

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(
      studyGroupMessageProvider(groupChatId),
    );
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Haha",
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatInfo(
                      groupChatId: groupChatId,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.info_outline,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            bottom: 10,
          ),
          child: Column(
            children: [
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    return chats.when(
                      data: (message) {
                        return ListView.builder(
                          itemCount: message.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            final messageInfo = message[index];

                            return Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                mainAxisAlignment: (messageInfo.senderId ==
                                        _firebaseAuth.currentUser!.uid)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  if (messageInfo.senderId !=
                                      _firebaseAuth.currentUser!.uid)
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: CircleAvatar(
                                        radius: 25,
                                      ),
                                    ),
                                  Column(
                                    crossAxisAlignment: (messageInfo.senderId ==
                                            _firebaseAuth.currentUser!.uid)
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (messageInfo.senderId !=
                                          _firebaseAuth.currentUser!.uid)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                            top: 10,
                                          ),
                                          child: Text(messageInfo.senderEmail),
                                        ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      ChatBubble(
                                        borderRadius: messageInfo.senderId ==
                                                _firebaseAuth.currentUser!.uid
                                            ? const BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                                bottomLeft: Radius.circular(15),
                                                bottomRight: Radius.circular(5),
                                              )
                                            : const BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(20),
                                                topLeft: Radius.circular(5),
                                                topRight: Radius.circular(15),
                                                bottomLeft: Radius.circular(15),
                                              ),
                                        alignment: messageInfo.senderId ==
                                                _firebaseAuth.currentUser!.uid
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        senderMessage: messageInfo.message,
                                        backgroundColor: messageInfo.senderId ==
                                                _firebaseAuth.currentUser!.uid
                                            ? Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                        textColor: messageInfo.senderId ==
                                                _firebaseAuth.currentUser!.uid
                                            ? Theme.of(context)
                                                .colorScheme
                                                .background
                                            : Theme.of(context)
                                                .colorScheme
                                                .background,
                                      ),
                                    ],
                                  ),
                                ],
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
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ChatTextField(
                        hintText: "Enter a message",
                        obscureText: false,
                        controller: _messageController,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Expanded(
//                 child: StreamBuilder(
//                   stream: _messages,
//                   builder: (context, snapshot) {
//                     print("Contents ${widget.groupChatId}");
//                     print("Contents of getMEssages ${snapshot.data}");
//                     // errors
//                     if (snapshot.hasError) {
//                       return const Text("Error");
//                     }
//                     // loading
//                     else if (snapshot.connectionState ==
//                         ConnectionState.waiting) {
//                       return const Expanded(
//                           child: Center(child: CircularProgressIndicator()));
//                     } else {
//                       return ListView.builder(
//                         reverse: true,
//                         itemCount: snapshot.data!.docs.length,
//                         itemBuilder: (context, index) {
//                           DocumentSnapshot doc = snapshot.data!.docs[index];
//                           Map<String, dynamic> data =
//                               doc.data() as Map<String, dynamic>;
//                           var alignment = (data['senderId'] ==
//                                   _firebaseAuth.currentUser!.uid)
//                               ? Alignment.centerRight
//                               : Alignment.centerLeft;
//                           var backgroundColor = (data['senderId'] ==
//                                   _firebaseAuth.currentUser!.uid)
//                               ? Theme.of(context).colorScheme.inversePrimary
//                               : Theme.of(context).colorScheme.primary;
//                           var textColor = (data['senderId'] ==
//                                   _firebaseAuth.currentUser!.uid)
//                               ? Theme.of(context).colorScheme.background
//                               : Theme.of(context).colorScheme.background;
//                           return Padding(
//                             padding: const EdgeInsets.only(
//                               bottom: 0,
//                             ),
//                             child: Column(
//                               crossAxisAlignment: (data["senderId"] ==
//                                       _firebaseAuth.currentUser!.uid)
//                                   ? CrossAxisAlignment.end
//                                   : CrossAxisAlignment.start,
//                               mainAxisAlignment: (data["senderId"] ==
//                                       _firebaseAuth.currentUser!.uid)
//                                   ? MainAxisAlignment.end
//                                   : MainAxisAlignment.start,
//                               children: [
//                                 if (data["senderId"] !=
//                                     _firebaseAuth.currentUser!.uid)
//                                   Padding(
//                                       padding: const EdgeInsets.only(
//                                         left: 10,
//                                         top: 10,
//                                         bottom: 5,
//                                       ),
//                                       child: Text(data["senderEmail"])),
//                                 const SizedBox(
//                                   height: 2,
//                                 ),
//                                 ChatBubble(
//                                   alignment: alignment,
//                                   textColor: textColor,
//                                   backgroundColor: backgroundColor,
//                                   senderMessage: data["message"],
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     }
//                     // return list view
//                   },
//                 ),
//               ),