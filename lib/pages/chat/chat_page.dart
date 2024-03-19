import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/components/containers/chat_bubble.dart';
import 'package:study_buddy/components/textfields/chat_textfield.dart';
import 'package:study_buddy/pages/chat/chat_info.dart';
import 'package:study_buddy/structure/group/chat_services.dart';
import 'package:study_buddy/structure/providers/chat_provider.dart';
import 'package:study_buddy/structure/services/storage_service.dart';

class ChatPage extends ConsumerWidget {
  final String groupChatId;
  final String title;
  final String creator;

  ChatPage({
    super.key,
    required this.groupChatId,
    required this.title,
    required this.creator,
  });

  final Storage _storage = Storage();

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
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  mainAxisAlignment: (messageInfo.senderId ==
                                          _firebaseAuth.currentUser!.uid)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    if (messageInfo.senderId !=
                                        _firebaseAuth.currentUser!.uid)
                                      Align(
                                        alignment: Alignment.centerLeft,
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
                                            _firebaseAuth.currentUser!.uid)
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
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        ChatBubble(
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
                                                  _firebaseAuth.currentUser!.uid
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          senderMessage: messageInfo.message,
                                          backgroundColor: messageInfo
                                                      .senderId ==
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
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'png'],
                        );

                        if (result == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("No item has been selected."),
                            ),
                          );
                          return;
                        }
                        final path = result.files.single.path;
                        final filename = result.files.single.name;

                        print(path);
                        print(filename);

                        _storage.uploadFile(path!, filename).then(
                              (value) => print("Done"),
                            );
                      },
                      icon: const Icon(Icons.upload_file),
                    ),
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
