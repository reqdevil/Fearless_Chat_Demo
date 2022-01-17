import 'package:fearless_chat_demo/Utils/global.dart';

// class Message {
//   int userId;
//   String userName;
//   String lastMessage;
//   String lastMsgTime;
//   bool seen;
//   MessageType messagetype;
//   bool hasUnSeenMsgs;
//   int unseenCount;
//   bool isOnline;
//   Message(
//       this.userId,
//       this.userName,
//       this.lastMessage,
//       this.lastMsgTime,
//       this.seen,
//       this.messagetype,
//       this.hasUnSeenMsgs,
//       this.unseenCount,
//       this.isOnline);
// }

// To parse this JSON data, do
//
//     final message = messageFromMap(jsonString);

import 'dart:convert';

class Message {
  Message({
    required this.usrId,
    required this.status,
    required this.contactImgUrl,
    required this.contactName,
    required this.message,
    required this.time,
    required this.hasShareMedia,
    required this.filePaths,
    required this.location,
  });

  int usrId;
  String status;
  String contactImgUrl;
  String contactName;
  String message;
  String time;
  bool hasShareMedia;
  List<dynamic> filePaths;
  List<dynamic> location;

  factory Message.fromJson(String str) => Message.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Message.fromMap(Map<String, dynamic> json) => Message(
        usrId: json["usrId"],
        status: json["status"],
        contactImgUrl: json["contactImgUrl"],
        contactName: json["contactName"],
        message: json["message"],
        time: json["time"],
        hasShareMedia: json["hasShareMedia"],
        filePaths: List<dynamic>.from(json["filePaths"].map((x) => x)),
        location: List<dynamic>.from(json["location"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "usrId": usrId,
        "status": status,
        "contactImgUrl": contactImgUrl,
        "contactName": contactName,
        "message": message,
        "time": time,
        "hasShareMedia": hasShareMedia,
        "filePaths": List<dynamic>.from(filePaths.map((x) => x)),
        "location": List<dynamic>.from(location.map((x) => x)),
      };
}
