import 'package:fearless_chat_demo/Utils/global.dart';

class Message {
  int userId;
  String userName;
  String lastMessage;
  String lastMsgTime;
  bool seen;
  MessageType messagetype;
  bool hasUnSeenMsgs;
  int unseenCount;
  bool isOnline;
  Message(
      this.userId,
      this.userName,
      this.lastMessage,
      this.lastMsgTime,
      this.seen,
      this.messagetype,
      this.hasUnSeenMsgs,
      this.unseenCount,
      this.isOnline);
}
