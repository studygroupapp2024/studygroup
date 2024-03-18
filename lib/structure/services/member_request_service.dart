import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemberRequest {
  final groupChat = FirebaseFirestore.instance.collection("study_groups");
  final userChat = FirebaseFirestore.instance.collection("users");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // request to join
  void requestToJoin(String chatId) {
    groupChat.doc(chatId).update({
      'membersRequest':
          FieldValue.arrayUnion([_auth.currentUser!.displayName.toString()]),
      'membersRequestId': FieldValue.arrayUnion([_auth.currentUser!.uid]),
    });
  }

  // Update the Study Group Member List
  void acceptOrreject(
    String documentId,
    String userEmail,
    String userId,
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
