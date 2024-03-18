// get User Study Groups
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/structure/models/chat_model.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

final studyGroupMessageProvider =
    StreamProvider.autoDispose.family<List<MessageModel>, String>(
  (ref, chatId) async* {
    final chats = _firestore
        .collection("study_groups")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map(
                (chats) => MessageModel.fromSnapshot(chats),
              )
              .toList(),
        );
    yield* chats;
  },
);
