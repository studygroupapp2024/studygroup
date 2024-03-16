import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String groupChatId;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.groupChatId,
    required this.message,
    required this.timestamp,
  });

  // convert to a map
  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderID,
      'senderEmail': senderEmail,
      'groupChatId': groupChatId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
