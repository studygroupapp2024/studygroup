import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChat {
  final String creatorId;
  final String creatorName;
  final String studyGroupTitle;
  final String studyGroupDescription;
  final Timestamp timestamp;
  final List<dynamic> members;
  final List<dynamic> membersId;

  GroupChat({
    required this.creatorId,
    required this.creatorName,
    required this.studyGroupTitle,
    required this.studyGroupDescription,
    required this.timestamp,
    required this.members,
    required this.membersId,
  });

  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'creatorName': creatorName,
      'studyGrppTitle': studyGroupTitle,
      'studyGrpDescription': studyGroupDescription,
      'createdAt': timestamp,
      'members': members,
      'membersId': membersId,
    };
  }
}
