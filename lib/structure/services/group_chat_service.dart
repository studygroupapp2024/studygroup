import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_buddy/structure/auth/auth_service.dart';
import 'package:study_buddy/structure/models/group_chat_model.dart';

class GroupChat {
  final groupChat = FirebaseFirestore.instance.collection("study_groups");
  final userChat = FirebaseFirestore.instance.collection("users");

  // add study group
  Future<bool> addStudyGroup(
    String title,
    String description,
    String course,
    String courseId,
  ) async {
    try {
      if (title.isNotEmpty && description.isNotEmpty && course.isNotEmpty) {
        final Timestamp timestamp = Timestamp.now();

        GroupChatModel newGroupChat = GroupChatModel(
          creatorId: AuthService().id,
          creatorName: AuthService().name,
          studyGroupTitle: title,
          studyGroupDescription: description,
          studyGroupCourseName: course,
          studyGroupCourseId: courseId,
          timestamp: timestamp,
          members: [AuthService().name],
          membersId: [AuthService().id],
          membersRequest: [],
          membersRequestId: [],
        );

        // groupChat.add(newGroupChat.toMap());
        // add new study group to the database database
        DocumentReference newGroupChatRef = await groupChat.add(
          newGroupChat.toMap(),
        );

        String groupChatId = newGroupChatRef.id;
        groupChat.doc(groupChatId).update({'chatId': groupChatId});
        // // Add the group chat to the user's study group chat
        var data = {
          "groupChatId": groupChatId,
          "groupChatTitle": title,
        };
        await userChat.doc(AuthService().id).collection("groupChats").add(data);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
