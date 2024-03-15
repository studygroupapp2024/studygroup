import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef MemberRequest = Map<String, dynamic>;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

final memberRequestProvider = StreamProvider<List<MemberRequest>>((ref) {
  return _firestore
      .collection("users")
      .doc(_firebaseAuth.currentUser!.uid)
      .collection("courses")
      .where("isCompleted", isEqualTo: false)
      .snapshots()
      .map((querySnapshot) =>
          querySnapshot.docs.map((doc) => doc.data()).toList());
});
