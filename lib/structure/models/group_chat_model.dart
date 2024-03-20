import 'package:cloud_firestore/cloud_firestore.dart';

// GROUPCHAT MODEL
class GroupChatModel {
  String? docID;
  final String creatorId;
  final String creatorName;
  final String studyGroupTitle;
  final String studyGroupDescription;
  final String studyGroupCourseName;
  final String studyGroupCourseId;
  final Timestamp timestamp;
  final RoomMembers members; //Room Members //List<dynamic>
  final List<dynamic> membersId;
  final List<dynamic> membersRequest;
  final List<dynamic> membersRequestId;
  final String lastMessage;
  final String lastMessageSender;
  final Timestamp? lastMessageTimeSent;

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
    required this.lastMessage,
    required this.lastMessageSender,
    required this.lastMessageTimeSent,
  });

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
      'members': members.toMap(), //.toMap()
      'membersId': membersId,
      'membersRequest': membersRequest,
      'membersRequestId': membersRequestId,
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'lastMessageTimeSent': lastMessageTimeSent,
    };
  }

  factory GroupChatModel.fromMap(Map<String, dynamic> map) {
    return GroupChatModel(
      docID: map['chatId'] != null ? map['chatId'] as String : null,
      creatorId: map['creatorId'] as String,
      creatorName: map['creatorName'] as String,
      studyGroupTitle: map['studyGroupTitle'] as String,
      studyGroupDescription: map['studyGroupDescription'] as String,
      studyGroupCourseName: map['studyGroupCourseName'] as String,
      studyGroupCourseId: map['studyGroupCourseId'] as String,
      timestamp: Timestamp.fromDate(DateTime.parse(map['createdAt'] as String)),
      members: RoomMembers(
        imageUrl: map['members']["F7MyU5Ikk7c3cKUvrpjHvdwAwM13"]['imageUrl'],
        lastReadChat: map['members']["F7MyU5Ikk7c3cKUvrpjHvdwAwM13"]
            ['lastReadChat'],
        name: map['members']["F7MyU5Ikk7c3cKUvrpjHvdwAwM13"]['name'],
        uid: map['members']["F7MyU5Ikk7c3cKUvrpjHvdwAwM13"]['uid'],
      ),
      membersId: List<dynamic>.from((map['membersId'] as List<dynamic>)),
      membersRequest:
          List<dynamic>.from((map['membersRequest'] as List<dynamic>)),
      membersRequestId:
          List<dynamic>.from((map['membersRequestId'] as List<dynamic>)),
      lastMessage: map['lastMessage'] as String,
      lastMessageSender: map['lastMessageSender'] as String,
      lastMessageTimeSent: map['lastMessageTimeSent'] != null
          ? Timestamp.fromDate(
              DateTime.parse(map['lastMessageTimeSent'] as String))
          : null,
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
      members: RoomMembers(
        imageUrl: doc['members']["F7MyU5Ikk7c3cKUvrpjHvdwAwM13"]['imageUrl'],
        lastReadChat: doc['members']["F7MyU5Ikk7c3cKUvrpjHvdwAwM13"]
            ['lastReadChat'],
        name: doc['members']["F7MyU5Ikk7c3cKUvrpjHvdwAwM13"]['name'],
        uid: doc['members']["F7MyU5Ikk7c3cKUvrpjHvdwAwM13"]['uid'],
      ),
      membersId: doc['membersId'],
      membersRequest: doc['membersRequest'],
      membersRequestId: doc['membersRequestId'],
      lastMessage: doc['lastMessage'],
      lastMessageSender: doc['lastMessageSender'],
      lastMessageTimeSent: doc['lastMessageTimeSent'],
    );
  }
}

// ROOM MEMBERS MODEL
class RoomMembers {
  final String imageUrl;
  final String lastReadChat; // lastReadChat is now nullable
  final String name;
  final String uid;

  RoomMembers({
    required this.imageUrl,
    required this.lastReadChat,
    required this.name,
    required this.uid,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      uid: {
        'imageUrl': imageUrl,
        'lastReadChat': lastReadChat,
        'name': name,
        'uid': uid,
      },
    };
  }

  factory RoomMembers.fromMap(Map<String, dynamic> map) {
    return RoomMembers(
      imageUrl: map['imageUrl'] as String,
      lastReadChat: map['lastReadChat'] as String, // Nullable
      name: map['name'] as String, // Nullable
      uid: map['uid'] as String,
    );
  }

  factory RoomMembers.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    return RoomMembers(
      imageUrl: doc['imageUrl'],
      lastReadChat: doc['lastReadChat'], // Provide a default value if null
      name: doc['name'], // Provide a default value if null
      uid: doc['uid'],
    );
  }
}
