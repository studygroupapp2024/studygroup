import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/structure/models/user_courses.dart';

class Courses extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // getting all the available courses
  Stream<QuerySnapshot> getCourses() {
    return _firestore.collection("subjects").snapshots();
  }

  // join a course
  Future<void> addCourse(String courseCode, courseTitle, courseId) async {
    // get current info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    // create a new course
    StudentCoursesModel newCourse = StudentCoursesModel(
      courseId: courseId,
      courseCode: courseCode,
      courseTitle: courseTitle,
      isCompleted: false,
      completedData: '',
      timestamp: timestamp,
    );

    // add new course to user database
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection("courses")
        .add(newCourse.toMap());

    // add the student Id to the list of who taken a specific course
    await FirebaseFirestore.instance
        .collection('subjects')
        .doc(courseId)
        .update({
      'studentId': FieldValue.arrayUnion(
        [currentUserId],
      )
    });
  }

  // get current user courses
  Stream<QuerySnapshot> getCurrentUserCourses(String userId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("courses")
        .where("isCompleted", isEqualTo: false)
        .snapshots();
  }

  // get completed user courses
  Stream<QuerySnapshot> getCompletedUserCourses(String userId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("courses")
        .where("isCompleted", isEqualTo: true)
        .snapshots();
  }

  // mark course as completed
  Future<void> markCompleted(String documentId) async {
    final Timestamp timestamp = Timestamp.now();
    // add the student Id to the list of who taken a specific course
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection("courses")
        .doc(documentId)
        .update({'isCompleted': true, 'completedData': timestamp});
  }

  // Delete course from firestore
  Future<void> deleteCourse(String documentId, courseId) async {
    await _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection("courses")
        .doc(documentId)
        .delete();

    await _firestore.collection("subjects").doc(courseId).update(
      {
        "studentId": FieldValue.arrayRemove(
          [_firebaseAuth.currentUser!.uid],
        ),
      },
    );
  }
}
