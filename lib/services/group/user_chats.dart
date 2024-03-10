import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserChats extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // getGroupChatId
  Stream<QuerySnapshot> getUserGroupChatsId(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('groupChats')
        .snapshots();
  }
}
