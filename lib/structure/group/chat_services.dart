import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/structure/models/chat_model.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String groupChatid, message) async {
    // get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String curreUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderID: currentUserId,
      senderEmail: curreUserEmail,
      groupChatId: groupChatid,
      message: message,
      timestamp: timestamp,
    );

    // add new message to database
    await _firestore
        .collection('study_groups')
        .doc(groupChatid)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String groupChatId) {
    print("Fetching messages for groupChatId: $groupChatId");
    return _firestore
        .collection("study_groups")
        .doc(groupChatId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }
}
