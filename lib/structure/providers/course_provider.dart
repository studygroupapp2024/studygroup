// collect to all the document
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:study_buddy/structure/models/user_courses.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

final multipleStudentCoursesInformationProvider =
    StreamProvider.autoDispose<List<StudentCoursesModel>>((ref) async* {
  final getUserCourses = _firestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection("courses")
      .snapshots()
      .map(
        (querySnapshot) => querySnapshot.docs
            .map(
              (snapshot) => StudentCoursesModel.fromSnapshot(snapshot),
            )
            .toList(),
      );
  yield* getUserCourses;
});

final currentStudentCoursesInformationProvider =
    StreamProvider.autoDispose<List<StudentCoursesModel>>((ref) async* {
  final getCompletedUserCourses = _firestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection("courses")
      .snapshots()
      .map(
        (querySnapshot) => querySnapshot.docs
            .map(
              (snapshot) => StudentCoursesModel.fromSnapshot(snapshot),
            )
            .where((course) => !course.isCompleted)
            .toList(),
      );
  yield* getCompletedUserCourses;
});
