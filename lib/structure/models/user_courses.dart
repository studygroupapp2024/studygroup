// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentCoursesModel {
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final bool isCompleted;
  final String completedData;
  final Timestamp timestamp;

  StudentCoursesModel({
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.isCompleted,
    required this.completedData,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'courseId': courseId,
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'isCompleted': isCompleted,
      'completedData': completedData,
      'joinedDate': timestamp,
    };
  }

  factory StudentCoursesModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    return StudentCoursesModel(
      courseId: doc['courseId'],
      courseCode: doc['courseCode'],
      courseTitle: doc['courseTitle'],
      isCompleted: doc['isCompleted'],
      completedData: doc['completedData'],
      timestamp: doc['joinedDate'],
    );
  }
}
