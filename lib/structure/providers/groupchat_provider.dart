import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
    StreamProvider.family<List<GroupChatModel>, String>((ref, userId) async* {
  final searchQuery = ref.watch(searchQueryProvider);

  final getStudyGroups = _firestore.collection("study_groups").snapshots().map(
        (querySnapshot) => querySnapshot.docs
            .map(
              (snapshot) => GroupChatModel.fromSnapshot(snapshot),
            )
            .where(
              (group) =>
                  !group.membersId.contains(userId) &&
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

// get User Study Groups
final userChatIdsProvider = StreamProvider.family<List<GroupChatModel>, String>(
  (ref, userId) async* {
    final userStudyGroups = _firestore
        .collection("study_groups")
        .orderBy(
          'lastMessageTimeSent',
          descending: false,
        )
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map(
                (snapshot) => GroupChatModel.fromSnapshot(snapshot),
              )
              .where((group) => group.membersId.contains(userId))
              .toList(),
        );
    yield* userStudyGroups;
  },
);

// check if there is a member request
// StreamProvider<bool> userHasStudyGroupRequest = StreamProvider<bool>((ref) {
//   return _firestore
//       .collection("study_groups")
//       .where('membersId', arrayContains: FirebaseAuth.instance.currentUser!.uid)
//       .snapshots()
//       .map((querySnapshot) => querySnapshot.docs
//           .any((snapshot) => (snapshot.data()['studyGroupTitle'] == null)));
// });

final userHasStudyGroupRequest = StreamProvider.autoDispose<bool>(
  (ref) {
    print("The array is NOT EMPTY?: ${FirebaseAuth.instance.currentUser!.uid}");
    return _firestore
        .collection("study_groups")
        .where('membersId',
            arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map(
              (snapshot) => GroupChatModel.fromSnapshot(snapshot),
            )
            .any((group) => group.membersRequestId.isNotEmpty));
  },
);

// ============================ STATE PROVIDERS =============================

final groupChatMemberRequestProvider =
    StateProvider.autoDispose<MemberRequest>((ref) {
  return MemberRequest();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final createGroupChatProvider = StateProvider.autoDispose<GroupChat>((ref) {
  return GroupChat();
});

// 



// ============================ FUTURE PROVIDERS ============================

// StateNotifier<MemberRequest>((ref) {
//  return MemberRequest();

// usage
// final membersRequestList = memberRequest.membersRequest
//     .map((e) => e as String)
//     .toList();
