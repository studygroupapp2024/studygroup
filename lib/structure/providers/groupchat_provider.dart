import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/structure/auth/auth_service.dart';
import 'package:study_buddy/structure/models/group_chat_model.dart';
import 'package:study_buddy/structure/services/group_chat_service.dart';
import 'package:study_buddy/structure/services/member_request_service.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// ============================ STREAM PROVIDERS =============================

// getting a specific Data based on the GroupChat ID
final singleGroupChatInformationProvider =
    StreamProvider.family<GroupChatModel, String>((ref, chatId) async* {
  final document = _firestore.collection("study_groups").doc(chatId);
  yield* document.snapshots().map(
        GroupChatModel.fromSnapshot,
      );
});

// collect to all the document
final multipleGroupChatInformationProvider =
    StreamProvider<List<GroupChatModel>>((ref) async* {
  final getStudyGroups = _firestore.collection("study_groups").snapshots().map(
        (querySnapshot) => querySnapshot.docs
            .map(
              (snapshot) => GroupChatModel.fromSnapshot(snapshot),
            )
            .toList(),
      );
  yield* getStudyGroups;
});

final selectedGroupChatInformationProvider =
    StreamProvider.autoDispose<List<GroupChatModel>>((ref) async* {
  final searchQuery = ref.watch(searchQueryProvider);

  final getStudyGroups = _firestore.collection("study_groups").snapshots().map(
        (querySnapshot) => querySnapshot.docs
            .map(
              (snapshot) => GroupChatModel.fromSnapshot(snapshot),
            )
            .where(
              (group) =>
                  !group.membersId.contains(AuthService().id) &&
                  (group.studyGroupTitle
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) ||
                      group.studyGroupCourseName
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) ||
                      searchQuery.isEmpty),
            )
            .toList(),
      );
  yield* getStudyGroups;
});

// ============================ STATE PROVIDERS =============================

final groupChatMemberRequestProvider = StateProvider<MemberRequest>((ref) {
  return MemberRequest();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final createGroupChatProvider = StateProvider<GroupChat>((ref) {
  return GroupChat();
});

// ============================ FUTURE PROVIDERS ============================

// StateNotifier<MemberRequest>((ref) {
//  return MemberRequest();

// usage
// final membersRequestList = memberRequest.membersRequest
//     .map((e) => e as String)
//     .toList();
