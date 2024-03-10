import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/models/group_chat.dart';

class GroupService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a Group Chat
  Future<void> sendGroupChatInfo(
    String studyGrpTitle,
    String studyGrpDesc,
  ) async {
    // get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String curreUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // create a new Group Chat
    GroupChat newGroupChat = GroupChat(
      creatorId: currentUserId,
      creatorName: curreUserEmail,
      studyGroupTitle: studyGrpTitle,
      studyGroupDescription: studyGrpDesc,
      timestamp: timestamp,
      members: [curreUserEmail],
      membersId: [currentUserId],
    );
    // construct a Group Chat ID

    // add new data to database
    DocumentReference newGroupChatRef =
        await _firestore.collection('study_groups').add(newGroupChat.toMap());
    String groupChatId = newGroupChatRef.id;

    // add a new collection
    var data = {
      "groupChatId": groupChatId,
      "groupChatTitle": studyGrpTitle,
    };
    _firestore
        .collection("users")
        .doc(currentUserId)
        .collection("groupChats")
        .add(
          data,
        );
  }

  // Join a Group Chat
  Future<void> checkAndAddUserEmail(
      String userEmail, String userID, String chatId, String groupTitle) async {
    // insert the current user to the group chat
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('study_groups')
          .where('membersId', isEqualTo: userID)
          .get();
      print("Query result: ${querySnapshot.docs}");

      if (querySnapshot.docs.isEmpty) {
        print("Joining group chat with chatId: $chatId");
        await FirebaseFirestore.instance
            .collection('study_groups')
            .doc(chatId)
            .update({
          'members': FieldValue.arrayUnion([userEmail]),
          'membersId': FieldValue.arrayUnion([userID]),
        });

        var data = {
          "groupChatId": chatId,
          "groupChatTitle": groupTitle,
        };
        await _firestore
            .collection("users")
            .doc(userID)
            .collection("groupChats")
            .add(
              data,
            );
        print("Update executed successfully");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
