import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/components/containers/chat_bubble.dart';
import 'package:study_buddy/components/textfields/chat_textfield.dart';
import 'package:study_buddy/pages/chat/chat_info.dart';
import 'package:study_buddy/pages/chat/special_message.dart';
import 'package:study_buddy/structure/group/chat_services.dart';
import 'package:study_buddy/structure/providers/chat_provider.dart';
import 'package:study_buddy/structure/providers/storage_provider.dart';
import 'package:study_buddy/structure/providers/university_provider.dart';

class ChatPage extends ConsumerWidget {
  final String groupChatId;
  final String title;
  final String creator;
  final String desc;
  final String dateCreated;

  ChatPage({
    super.key,
    required this.groupChatId,
    required this.title,
    required this.creator,
    required this.desc,
    required this.dateCreated,
  });

  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage(String institutionId) async {
    if (_messageController.text.isNotEmpty) {
      // send message
      var chat = "chat";
      await _chatService.sendMessage(
          groupChatId, _messageController.text, chat, "", institutionId);
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
          title: Text(
            title,
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatInfo(
                      groupChatId: groupChatId,
                      creator: creator,
                      groupChatTitle: title,
                      groupChatDescription: desc,
                      dateCreated: dateCreated,
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
                        return Align(
                          alignment: Alignment.topCenter,
                          child: ListView.builder(
                            itemCount: message.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final messageInfo = message[index];
                              final String fullName = messageInfo.senderEmail;
                              final List<String> nameParts =
                                  fullName.split(' ');
                              final String firstName = nameParts[0];
                              final String format =
                                  firstName.substring(0, 1).toUpperCase() +
                                      firstName.substring(1).toLowerCase();
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment: messageInfo.senderId ==
                                              _firebaseAuth.currentUser!.uid &&
                                          messageInfo.type == "chat"
                                      ? MainAxisAlignment.end
                                      : messageInfo.senderId ==
                                                  _firebaseAuth
                                                      .currentUser!.uid &&
                                              messageInfo.type == "special"
                                          ? MainAxisAlignment.end
                                          : messageInfo.senderId !=
                                                      _firebaseAuth
                                                          .currentUser!.uid &&
                                                  messageInfo.type == "chat"
                                              ? MainAxisAlignment.start
                                              : MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (messageInfo.senderId !=
                                                _firebaseAuth
                                                    .currentUser!.uid &&
                                            messageInfo.type == "chat" ||
                                        messageInfo.senderId !=
                                                _firebaseAuth
                                                    .currentUser!.uid &&
                                            messageInfo.type == "special")
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundImage: NetworkImage(
                                                  messageInfo.senderImage),
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                            ),
                                            Container(
                                              height: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary,
                                            )
                                          ],
                                        ),
                                      ),
                                    Column(
                                      crossAxisAlignment: (messageInfo
                                                  .senderId ==
                                              _firebaseAuth.currentUser!.uid)
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        if (messageInfo.senderId !=
                                                _firebaseAuth
                                                    .currentUser!.uid &&
                                            messageInfo.type == "chat")
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              top: 10,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  format,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  DateFormat('hh:mm a').format(
                                                    messageInfo.timestamp
                                                        .toDate(),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ChatBubble(
                                          textAlign:
                                              messageInfo.type == "announcement"
                                                  ? TextAlign.center
                                                  : TextAlign.start,
                                          fontSize:
                                              messageInfo.type == "announcement"
                                                  ? 12
                                                  : 16,
                                          borderRadius: messageInfo.senderId ==
                                                  _firebaseAuth.currentUser!.uid
                                              ? const BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                  bottomLeft:
                                                      Radius.circular(20),
                                                  bottomRight:
                                                      Radius.circular(5),
                                                )
                                              : const BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(20),
                                                  topLeft: Radius.circular(5),
                                                  topRight: Radius.circular(20),
                                                  bottomLeft:
                                                      Radius.circular(20),
                                                ),
                                          alignment: messageInfo.senderId ==
                                                      _firebaseAuth
                                                          .currentUser!.uid &&
                                                  messageInfo.type == "chat"
                                              ? Alignment.centerRight
                                              : messageInfo.senderId !=
                                                          _firebaseAuth
                                                              .currentUser!
                                                              .uid &&
                                                      messageInfo.type == "chat"
                                                  ? Alignment.centerLeft
                                                  : Alignment.center,
                                          senderMessage:
                                              messageInfo.type == "special"
                                                  ? messageInfo.message +
                                                      messageInfo.downloadUrl
                                                          .toString()
                                                  : messageInfo.message,
                                          backgroundColor: messageInfo
                                                              .senderId ==
                                                          _firebaseAuth
                                                              .currentUser!
                                                              .uid &&
                                                      messageInfo.type ==
                                                          "chat" ||
                                                  messageInfo.senderId ==
                                                          _firebaseAuth
                                                              .currentUser!
                                                              .uid &&
                                                      messageInfo.type ==
                                                          "special"
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .tertiaryContainer
                                              : messageInfo.senderId !=
                                                          _firebaseAuth
                                                              .currentUser!
                                                              .uid &&
                                                      messageInfo.type == "chat"
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .background,
                                          textColor: messageInfo.senderId ==
                                                          _firebaseAuth
                                                              .currentUser!
                                                              .uid &&
                                                      messageInfo.type ==
                                                          "chat" ||
                                                  messageInfo.senderId ==
                                                          _firebaseAuth
                                                              .currentUser!
                                                              .uid &&
                                                      messageInfo.type ==
                                                          "special"
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .background
                                              : messageInfo.senderId !=
                                                          _firebaseAuth
                                                              .currentUser!
                                                              .uid &&
                                                      messageInfo.type == "chat"
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .inversePrimary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                          onTap: messageInfo.type == "special"
                                              ? () {
                                                  ref
                                                      .read(uploadFileProvider)
                                                      .downloadFile(
                                                        context,
                                                        messageInfo.downloadUrl
                                                            .toString(),
                                                        "errrr.png",
                                                      );
                                                }
                                              : null,
                                        ),
                                        messageInfo.senderId !=
                                                _firebaseAuth.currentUser!.uid
                                            ? const SizedBox(
                                                height: 6,
                                              )
                                            : const SizedBox(
                                                height: 3,
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
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
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SendSpecialMessage(
                              groupChatId: groupChatId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline_outlined),
                    ),
                    Expanded(
                      child: ChatTextField(
                        hintText: "Enter a message",
                        obscureText: false,
                        controller: _messageController,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        sendMessage(
                          await ref
                              .watch(institutionIdProviderBasedOnUser)
                              .getUniversityBasedId(),
                        );
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
