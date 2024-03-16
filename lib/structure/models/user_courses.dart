import 'package:cloud_firestore/cloud_firestore.dart';

class StudentCourses {
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final bool isCompleted;
  final String completedData;
  final Timestamp timestamp;

  StudentCourses({
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.isCompleted,
    required this.completedData,
    required this.timestamp,
  });

  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'isCompleted': isCompleted,
      'completedData': completedData,
      'joinedDate': timestamp,
    };
  }
}
