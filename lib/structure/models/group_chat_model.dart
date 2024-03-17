// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatModel {
  String? docID;
  final String creatorId;
  final String creatorName;
  final String studyGroupTitle;
  final String studyGroupDescription;
  final String studyGroupCourseName;
  final String studyGroupCourseId;
  final Timestamp timestamp;
  final List<dynamic> members;
  final List<dynamic> membersId;
  final List<dynamic> membersRequest;
  final List<dynamic> membersRequestId;

  GroupChatModel({
    this.docID,
    required this.creatorId,
    required this.creatorName,
    required this.studyGroupTitle,
    required this.studyGroupDescription,
    required this.studyGroupCourseName,
    required this.studyGroupCourseId,
    required this.timestamp,
    required this.members,
    required this.membersId,
    required this.membersRequest,
    required this.membersRequestId,
  });

  get reference => null;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatId': docID,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'studyGroupTitle': studyGroupTitle,
      'studyGroupDescription': studyGroupDescription,
      'studyGroupCourseName': studyGroupCourseName,
      'studyGroupCourseId': studyGroupCourseId,
      'createdAt': timestamp,
      'members': members,
      'membersId': membersId,
      'membersRequest': membersRequest,
      'membersRequestId': membersRequestId,
    };
  }

  factory GroupChatModel.fromMap(Map<String, dynamic> map) {
    return GroupChatModel(
      docID: map['docID'] != null ? map['docID'] as String : null,
      creatorId: map['creatorId'] as String,
      creatorName: map['creatorName'] as String,
      studyGroupTitle: map['studyGroupTitle'] as String,
      studyGroupDescription: map['studyGroupDescription'] as String,
      studyGroupCourseName: map['studyGroupCourseName'] as String,
      studyGroupCourseId: map['studyGroupCourseId'] as String,
      timestamp: Timestamp.fromDate(DateTime.parse(map['createdAt'] as String)),
      members: List<dynamic>.from((map['members'] as List<dynamic>)),
      membersId: List<dynamic>.from((map['membersId'] as List<dynamic>)),
      membersRequest:
          List<dynamic>.from((map['membersRequest'] as List<dynamic>)),
      membersRequestId:
          List<dynamic>.from((map['membersRequestId'] as List<dynamic>)),
    );
  }

  factory GroupChatModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    return GroupChatModel(
      docID: doc['chatId'],
      creatorId: doc['creatorId'],
      creatorName: doc['creatorName'],
      studyGroupTitle: doc['studyGroupTitle'],
      studyGroupDescription: doc['studyGroupDescription'],
      studyGroupCourseName: doc['studyGroupCourseName'],
      studyGroupCourseId: doc['studyGroupCourseId'],
      timestamp: doc['createdAt'],
      members: doc['members'],
      membersId: doc['membersId'],
      membersRequest: doc['membersRequest'],
      membersRequestId: doc['membersRequestId'],
    );
  }
}
