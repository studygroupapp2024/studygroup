import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/structure/models/chat_members_model.dart';
import 'package:study_buddy/structure/models/group_chat_model.dart';
import 'package:study_buddy/structure/providers/university_provider.dart';
import 'package:study_buddy/structure/services/group_chat_service.dart';
import 'package:study_buddy/structure/services/member_request_service.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

// ============================ STREAM PROVIDERS =============================

final singleGroupChatInformationProvider =
    StreamProvider.family<GroupChatModel, String>((ref, chatId) async* {
  final institutionId =
      await ref.watch(institutionIdProviderBasedOnUser).getUniversityBasedId();
  final document = _firestore
      .collection("institution")
      .doc(institutionId)
      .collection("study_groups")
      .doc(chatId);
  yield* document.snapshots().map(
        GroupChatModel.fromSnapshot,
      );
});

// collect to all the document
final multipleGroupChatInformationProvider =
    StreamProvider<List<GroupChatModel>>((ref) async* {
  final institutionId =
      await ref.watch(institutionIdProviderBasedOnUser).getUniversityBasedId();
  final getStudyGroups = _firestore
      .collection("institution")
      .doc(institutionId)
      .collection("study_groups")
      .snapshots()
      .map(
        (querySnapshot) => querySnapshot.docs
            .map(
              (snapshot) => GroupChatModel.fromSnapshot(snapshot),
            )
            .toList(),
      );
  yield* getStudyGroups;
});

final groupChatMembersProvider =
    StreamProvider.family<List<ChatMembersModel>, String>(
  (ref, chatId) async* {
    final institutionId = await ref
        .watch(institutionIdProviderBasedOnUser)
        .getUniversityBasedId();
    final getMembers = _firestore
        .collection("institution")
        .doc(institutionId)
        .collection("study_groups")
        .doc(chatId)
        .collection("members")
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map(
                (members) => ChatMembersModel.fromSnapshot(members),
              )
              .toList(),
        );

    yield* getMembers;
  },
);

final courseIdProvider =
    StreamProvider.family<List<String>, String>((ref, userId) async* {
  final institutionId =
      await ref.watch(institutionIdProviderBasedOnUser).getUniversityBasedId();
  yield* _firestore
      .collection("institution")
      .doc(institutionId)
      .collection("students")
      .doc(userId)
      .collection("courses")
      .where('isCompleted', isEqualTo: false)
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs
          .map((doc) => doc.data()['courseId'] as String)
          .toList());
});

final selectedGroupChatInformationProvider = StreamProvider.family
    .autoDispose<List<GroupChatModel>, String>((ref, userId) async* {
  final searchQuery = ref.watch(searchQueryProvider);
  final coursesTaken = ref.watch(courseIdProvider(userId)).value;
  final institutionId =
      await ref.watch(institutionIdProviderBasedOnUser).getUniversityBasedId();
  print("coursesTaken: $coursesTaken");
  print("INSTITUTION ID: $institutionId");
  final getStudyGroups = _firestore
      .collection("institution")
      .doc(institutionId)
      .collection("study_groups")
      .snapshots()
      .map(
        (querySnapshot) => querySnapshot.docs
            .map((snapshot) => GroupChatModel.fromSnapshot(snapshot))
            .where((group) =>
                !group.membersId.contains(userId) &&
                coursesTaken!.contains(group.studyGroupCourseId) &&
                (group.studyGroupTitle
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    group.studyGroupCourseName
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    searchQuery.isEmpty))
            .toList(),
      );

  yield* getStudyGroups;
});
// get User Study Groups
final userChatIdsProvider = StreamProvider.family<List<GroupChatModel>, String>(
  (ref, userId) async* {
    final institutionId = await ref
        .watch(institutionIdProviderBasedOnUser)
        .getUniversityBasedId();
    final userStudyGroups = _firestore
        .collection("institution")
        .doc(institutionId)
        .collection("study_groups")
        .orderBy(
          'lastMessageTimeSent',
          descending: true,
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

final userLastChatProvider =
    StreamProvider.family<List<GroupChatModel>, String>(
  (ref, userId) async* {
    final userStudyGroups = _firestore
        .collection("study_groups")
        .orderBy(
          'lastMessageTimeSent',
          descending: true,
        )
        .where('members', arrayContains: userId)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map(
                (snapshot) => GroupChatModel.fromSnapshot(snapshot),
              )
              .toList(),
        );
    yield* userStudyGroups;
  },
);

final userHasStudyGroupRequest = StreamProvider.autoDispose<bool>((ref) async* {
  final institutionId =
      await ref.watch(institutionIdProviderBasedOnUser).getUniversityBasedId();

  try {
    final querySnapshot = await _firestore
        .collection("institution")
        .doc(institutionId)
        .collection("study_groups")
        .where('creatorId', isEqualTo: _firebaseAuth.currentUser!.uid)
        .get();

    final groups = querySnapshot.docs
        .map((snapshot) => GroupChatModel.fromSnapshot(snapshot))
        .toList();

    final hasRequest = groups.any((group) => group.membersRequestId.isNotEmpty);

    yield hasRequest;
  } catch (e) {
    yield false;
  }
});

// ============================ STATE PROVIDERS =============================

final groupChatMemberRequestProvider =
    StateProvider.autoDispose<MemberRequest>((ref) {
  return MemberRequest();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final groupChatProvider = StateProvider.autoDispose<GroupChat>((ref) {
  return GroupChat();
});
