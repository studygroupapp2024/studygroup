import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/structure/models/chat_model.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(
    String groupChatid,
    String message,
    String type,
    String downloadUrl,
    String institutionId,
  ) async {
    // get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String curreUserEmail =
        _firebaseAuth.currentUser!.displayName.toString();
    final String currentPhoto = _firebaseAuth.currentUser!.photoURL!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    MessageModel newMessage = MessageModel(
      senderId: currentUserId,
      senderEmail: curreUserEmail,
      groupChatId: groupChatid,
      message: message,
      senderImage: currentPhoto,
      timestamp: timestamp,
      type: type,
      downloadUrl: downloadUrl,
    );

    // add new message to database
    await _firestore
        .collection("institution")
        .doc(institutionId)
        .collection('study_groups')
        .doc(groupChatid)
        .collection("messages")
        .add(newMessage.toMap());

    // add GroupChat LastMessage, LastMessageSender, and LastMessageTimeSent
    _firestore
        .collection("institution")
        .doc(institutionId)
        .collection("study_groups")
        .doc(groupChatid)
        .update(
      {
        "lastMessage": message,
        "lastMessageSender": curreUserEmail,
        "lastMessageTimeSent": timestamp,
        "lastMessageType": type,
      },
    );
  }

  // get messages
  // Stream<QuerySnapshot> getMessages(String groupChatId) {
  //   return _firestore
  //       .collection("institution")
  //       .doc(institutionId)
  //       .collection("study_groups")
  //       .doc(groupChatId)
  //       .collection("messages")
  //       .orderBy("timestamp", descending: true)
  //       .snapshots();
  // }
}
