import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/models/group_chat.dart';

class GroupService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // getting all the study groups
  Stream<QuerySnapshot> getStudyGroups() {
    return _firestore.collection("study_groups").snapshots();
  }

  // Create a Group Chat
  Future<void> sendGroupChatInfo(
    String studyGrpTitle,
    studyGrpDesc,
    course,
    courseId,
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
      studyGroupCourseName: course,
      studyGroupCourseId: courseId,
      timestamp: timestamp,
      members: [curreUserEmail],
      membersId: [currentUserId],
      membersRequest: [],
      membersRequestId: [],
    );

    // add new study group to the database database
    DocumentReference newGroupChatRef =
        await _firestore.collection('study_groups').add(newGroupChat.toMap());
    String groupChatId = newGroupChatRef.id;

    // // Add the group chat to the user's study group chat
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

  // Request to join a group chat
  Future<void> checkAndAddUserEmail(
      String userEmail, String userID, String chatId, String groupTitle) async {
    try {
      // Check if the User ID already exist in the database
      QuerySnapshot querySnapshot = await _firestore
          .collection('study_groups')
          .where('membersId', isEqualTo: userID)
          .get();

      // If the user is not in the database, move the data to the request array
      if (querySnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('study_groups')
            .doc(chatId)
            .update({
          'membersRequest': FieldValue.arrayUnion([userEmail]),
          'membersRequestId': FieldValue.arrayUnion([userID]),
        });

        // NOT YET APPROVE SO DO NOT INSERT
        // Add the group chat to the user's study group chat
        // var data = {
        //   "groupChatId": chatId,
        //   "groupChatTitle": groupTitle,
        // };
        // await _firestore
        //     .collection("users")
        //     .doc(userID)
        //     .collection("groupChats")
        //     .add(
        //       data,
        //     );
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
