import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/components/containers/user_chat_list.dart';
import 'package:study_buddy/pages/chat/chat_page.dart';
import 'package:study_buddy/pages/home/create_study_group.dart';
import 'package:study_buddy/structure/group/user_chats.dart';

class FindPage extends StatefulWidget {
  const FindPage({super.key});

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  final UserChats _userChats = UserChats();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  late final Stream<QuerySnapshot<Object?>> _groupChats = getUserGroupChatsId(
    _firebaseAuth.currentUser!.uid,
  );

  Stream<QuerySnapshot<Object?>> getUserGroupChatsId(String groupChatId) {
    return _userChats.getUserGroupChatsId(groupChatId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateStudyGroup()),
                );
              },
              icon: const Icon(
                Icons.create,
              ))
        ],
      ),
      body: StreamBuilder(
        stream: _groupChats,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot doc = snapshot.data!.docs[index];
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return UserChatContainer(
                  text: data["groupChatTitle"],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          chatName: data["groupChatTitle"],
                          groupChatId: data["groupChatId"],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
