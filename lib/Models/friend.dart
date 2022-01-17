// To parse this JSON data, do
//
//     final firend = firendFromMap(jsonString);

import 'dart:convert';

class Firend {
  Firend({
    required this.usrId,
    required this.imgUrl,
    required this.username,
    required this.lastMsg,
    required this.seen,
    required this.hasUnSeenMsgs,
    required this.unseenCount,
    required this.lastMsgTime,
    required this.isOnline,
    required this.isFavorite,
  });

  String usrId;
  String imgUrl;
  String username;
  String lastMsg;
  bool seen;
  bool hasUnSeenMsgs;
  int unseenCount;
  String lastMsgTime;
  bool isOnline;
  bool isFavorite;

  factory Firend.fromJson(String str) => Firend.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Firend.fromMap(Map<String, dynamic> json) => Firend(
        usrId: json["usrId"],
        imgUrl: json["imgUrl"],
        username: json["username"],
        lastMsg: json["lastMsg"],
        seen: json["seen"],
        hasUnSeenMsgs: json["hasUnSeenMsgs"],
        unseenCount: json["unseenCount"],
        lastMsgTime: json["lastMsgTime"],
        isOnline: json["isOnline"],
        isFavorite: json["isFavorite"],
      );

  Map<String, dynamic> toMap() => {
        "usrId": usrId,
        "imgUrl": imgUrl,
        "username": username,
        "lastMsg": lastMsg,
        "seen": seen,
        "hasUnSeenMsgs": hasUnSeenMsgs,
        "unseenCount": unseenCount,
        "lastMsgTime": lastMsgTime,
        "isOnline": isOnline,
        "isFavorite": isFavorite,
      };
}
