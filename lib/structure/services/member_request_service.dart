import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_buddy/structure/group/chat_services.dart';
import 'package:study_buddy/structure/messaging/message_api.dart';
import 'package:study_buddy/structure/models/chat_members_model.dart';
import 'package:study_buddy/structure/services/user_service.dart';

class MemberRequest {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessage _firebaseMessage = FirebaseMessage();
  final UserInformation _users = UserInformation();
  final ChatService _chatService = ChatService();
  // request to join
  Future<void> requestToJoin(
    String chatId,
    String ownerId,
    String groupChatTitle,
    String requestorName,
    String institutionId,
  ) async {
    // get FCM
    final getFcm = await _firestore
        .collection("institution")
        .doc(institutionId)
        .collection("students")
        .doc(ownerId)
        .get();

    final data = getFcm.data();

    final fcm = data!['fcmtoken'];

    print("THE FCM OF THE OWNER IS: $fcm");

    // send notification
    _firebaseMessage.sendPushMessage(
        recipientToken: fcm,
        title: "Member Request Notification",
        body:
            "$groupChatTitle: $requestorName wants to join your study group.");

    // add the study group to the user groups.
    await _firestore
        .collection("institution")
        .doc(institutionId)
        .collection("study_groups")
        .doc(chatId)
        .update({
      'membersRequest':
          FieldValue.arrayUnion([_auth.currentUser!.displayName.toString()]),
      'membersRequestId': FieldValue.arrayUnion([_auth.currentUser!.uid]),
    });
  }

  // Update the Study Group Member List
  Future<void> acceptOrreject(
    String documentId,
    String userEmail,
    String userId,
    bool isAccepted,
    String title,
    String institutionId,
  ) async {
    final userInfo = await _users.getUserInfo(userId, institutionId);

    final userInfodata = userInfo.data();

    final uid = userInfodata!['uid'];
    final userName = userInfodata['name'];
    final imageUrl = userInfodata['imageUrl'];
    final fcmtoken = userInfodata['fcmtoken'];

    if (isAccepted) {
      // create a new Member
      ChatMembersModel newMember = ChatMembersModel(
        lastReadChat: '',
        userId: uid,
        imageUrl: imageUrl,
        name: userName,
        isAdmin: false,
      );

      await _firestore
          .collection("institution")
          .doc(institutionId)
          .collection("study_groups")
          .doc(documentId)
          .collection("members")
          .doc(userId)
          .set(
            newMember.toMap(),
          );

      // send notification
      _firebaseMessage.sendPushMessage(
          recipientToken: fcmtoken,
          title: "Welcome!",
          body: "You request to join $title has been accepted.");
      await _firestore
          .collection("institution")
          .doc(institutionId)
          .collection("study_groups")
          .doc(documentId)
          .update(
        {
          'membersId': FieldValue.arrayUnion(
            [userId],
          ),
          // 'membersId': FieldValue.arrayUnion(
          //   [userId],
          //     // ),
        },
      );

      await _firestore
          .collection("institution")
          .doc(institutionId)
          .collection("study_groups")
          .doc(documentId)
          .update(
        {
          'membersRequest': FieldValue.arrayRemove(
            [userEmail],
          ),
          'membersRequestId': FieldValue.arrayRemove(
            [userId],
          ),
        },
      );

      // add the study group to the user groups.
      var data = {
        "groupChatId": documentId,
      };
      await _firestore
          .collection("institution")
          .doc(institutionId)
          .collection("students")
          .doc(userId)
          .collection("groupChats")
          .doc(documentId)
          .set(data);

      // add message to the group chat
      var type = "announcement";
      var message = "$userName has joined the study group.";

      await _chatService.sendMessage(
          documentId, message, type, "", institutionId);
    } else {
      await _firestore
          .collection("institution")
          .doc(institutionId)
          .collection("study_groups")
          .doc(documentId)
          .update(
        {
          'membersRequest': FieldValue.arrayRemove(
            [userEmail],
          ),
          'membersRequestId': FieldValue.arrayRemove(
            [userId],
          ),
        },
      );
      // send notification
      _firebaseMessage.sendPushMessage(
          recipientToken: fcmtoken,
          title: "Notice",
          body: "You request to join $title has been rejected.");
    }
  }
}
