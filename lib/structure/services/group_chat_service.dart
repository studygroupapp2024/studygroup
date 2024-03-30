import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:study_buddy/structure/models/chat_members_model.dart';
import 'package:study_buddy/structure/models/group_chat_model.dart';
import 'package:study_buddy/structure/services/university_service.dart';

class GroupChat {
  final institution = FirebaseFirestore.instance.collection("institution");
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UniversityInfo _universityInfo = UniversityInfo();
  // add study group
  Future<bool> addStudyGroup(
    String title,
    String description,
    String course,
    String courseId,
  ) async {
    final institutionId = await _universityInfo.getUniversityBasedId();
    try {
      if (title.isNotEmpty && description.isNotEmpty && course.isNotEmpty) {
        final Timestamp timestamp = Timestamp.now();

        GroupChatModel newGroupChat = GroupChatModel(
          creatorId: _auth.currentUser!.uid,
          creatorName: _auth.currentUser!.displayName.toString(),
          studyGroupTitle: title,
          studyGroupDescription: description,
          studyGroupCourseName: course,
          studyGroupCourseId: courseId,
          timestamp: timestamp,
          membersId: [_auth.currentUser!.uid],
          membersRequest: [],
          membersRequestId: [],
          lastMessage: '',
          lastMessageSender: '',
          lastMessageTimeSent: null,
          lastMessageType: '',
          groupChatImage: null,
        );

        ChatMembersModel newMemberList = ChatMembersModel(
          lastReadChat: '',
          userId: _auth.currentUser!.uid,
          imageUrl: _auth.currentUser!.photoURL.toString(),
          name: _auth.currentUser!.displayName.toString(),
          isAdmin: true,
        );

        // groupChat.add(newGroupChat.toMap());
        // add new study group to the database database
        DocumentReference newGroupChatRef =
            await institution.doc(institutionId).collection("study_groups").add(
                  newGroupChat.toMap(),
                );

        String groupChatId = newGroupChatRef.id;

        institution
            .doc(institutionId)
            .collection("study_groups")
            .doc(groupChatId)
            .update({'chatId': groupChatId});

        await institution
            .doc(institutionId)
            .collection("study_groups")
            .doc(groupChatId)
            .collection("members")
            .doc(_auth.currentUser!.uid)
            .set(
              newMemberList.toMap(),
            );

        // Add the group chat to the user's study group chat

        var data = {
          "groupChatId": groupChatId,
        };
        await institution
            .doc(institutionId)
            .collection("students")
            .doc(_auth.currentUser!.uid)
            .collection("groupChats")
            .doc(groupChatId)
            .set(data);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }

  // remove a member
  Future<void> removeMember(String groupChatId, String userId) async {
    final institutionId = await _universityInfo.getUniversityBasedId();
    await institution
        .doc(institutionId)
        .collection("study_groups")
        .doc(groupChatId)
        .collection("members")
        .doc(userId)
        .delete();

    await institution
        .doc(institutionId)
        .collection("students")
        .doc(userId)
        .collection("groupChats")
        .doc(groupChatId)
        .delete();

    await institution
        .doc(institutionId)
        .collection("study_groups")
        .doc(groupChatId)
        .update(
      {
        "membersId": FieldValue.arrayRemove(
          [userId],
        )
      },
    );
  }

  //Change groupChat profile
  Future<void> changeGroupChatProfile(
    String filePath,
    String filename,
    String groupChatId,
    String institutionId,
  ) async {
    File file = File(filePath);
    try {
      await _firebaseStorage.ref('chatImages/$filename').putFile(file);
      String downloadUrl =
          await _firebaseStorage.ref('chatImages/$filename').getDownloadURL();

      await institution
          .doc(institutionId)
          .collection("study_groups")
          .doc(groupChatId)
          .update({"groupChatImage": downloadUrl});
    } on FirebaseException catch (e) {
      print(e);
    }
  }
}
