import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_buddy/structure/auth/auth_service.dart';

class MemberRequest {
  final groupChat = FirebaseFirestore.instance.collection("study_groups");
  final userChat = FirebaseFirestore.instance.collection("users");

  // request to join
  void requestToJoin(String chatId) {
    groupChat.doc(chatId).update({
      'membersRequest': FieldValue.arrayUnion([AuthService().email]),
      'membersRequestId': FieldValue.arrayUnion([AuthService().id]),
    });
  }

  // Update the Study Group Member List
  void acceptOrreject(
    String documentId,
    String userEmail,
    String userId,
    String title,
    bool isAccepted,
  ) {
    if (isAccepted) {
      groupChat.doc(documentId).update(
        {
          'members': FieldValue.arrayUnion(
            [userEmail],
          ),
          'membersId': FieldValue.arrayUnion(
            [userId],
          ),
          'membersRequest': FieldValue.arrayRemove(
            [userEmail],
          ),
          'membersRequestId': FieldValue.arrayRemove(
            [userId],
          ),
        },
      );

      var data = {
        "groupChatId": documentId,
        "groupChatTitle": title,
      };
      userChat.doc(userId).collection("groupChats").add(data);
    } else {
      groupChat.doc(documentId).update(
        {
          'membersRequest': FieldValue.arrayRemove(
            [userEmail],
          ),
          'membersRequestId': FieldValue.arrayRemove(
            [userId],
          ),
        },
      );
    }
  }
}
