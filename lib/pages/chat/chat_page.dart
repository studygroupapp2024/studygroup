import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/components/containers/chat_bubble.dart';
import 'package:study_buddy/components/textfields/chat_textfield.dart';
import 'package:study_buddy/pages/chat/chat_info.dart';
import 'package:study_buddy/structure/group/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String chatName;
  final String groupChatId;

  const ChatPage({
    super.key,
    required this.chatName,
    required this.groupChatId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  late final Stream<QuerySnapshot<Object?>> _messages =
      getMessages(widget.groupChatId);

  Stream<QuerySnapshot<Object?>> getMessages(String groupChatId) {
    return _chatService.getMessages(groupChatId);
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // send message
      await _chatService.sendMessage(
          widget.groupChatId, _messageController.text);

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.chatName,
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatInfo(
                      groupChatId: widget.groupChatId,
                      groupChatTitle: widget.chatName,
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
                child: StreamBuilder(
                  stream: _messages,
                  builder: (context, snapshot) {
                    print("Contents ${widget.groupChatId}");
                    print("Contents of getMEssages ${snapshot.data}");
                    // errors
                    if (snapshot.hasError) {
                      return const Text("Error");
                    }
                    // loading
                    else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Expanded(
                          child: Center(child: CircularProgressIndicator()));
                    } else {
                      return ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot doc = snapshot.data!.docs[index];
                          Map<String, dynamic> data =
                              doc.data() as Map<String, dynamic>;
                          var alignment = (data['senderId'] ==
                                  _firebaseAuth.currentUser!.uid)
                              ? Alignment.centerRight
                              : Alignment.centerLeft;
                          var backgroundColor = (data['senderId'] ==
                                  _firebaseAuth.currentUser!.uid)
                              ? Theme.of(context).colorScheme.inversePrimary
                              : Theme.of(context).colorScheme.primary;
                          var textColor = (data['senderId'] ==
                                  _firebaseAuth.currentUser!.uid)
                              ? Theme.of(context).colorScheme.background
                              : Theme.of(context).colorScheme.background;
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 0,
                            ),
                            child: Column(
                              crossAxisAlignment: (data["senderId"] ==
                                      _firebaseAuth.currentUser!.uid)
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              mainAxisAlignment: (data["senderId"] ==
                                      _firebaseAuth.currentUser!.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (data["senderId"] !=
                                    _firebaseAuth.currentUser!.uid)
                                  Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        top: 10,
                                        bottom: 5,
                                      ),
                                      child: Text(data["senderEmail"])),
                                const SizedBox(
                                  height: 2,
                                ),
                                ChatBubble(
                                  alignment: alignment,
                                  textColor: textColor,
                                  backgroundColor: backgroundColor,
                                  senderMessage: data["message"],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    // return list view
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
