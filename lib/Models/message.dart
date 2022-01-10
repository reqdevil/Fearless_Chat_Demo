import 'package:fearless_chat_demo/Utils/global.dart';

class Message {
  int userId;
  String userName;
  String message;
  String time;
  MessageType messagetype;
  Message(
      this.userId, this.userName, this.message, this.time, this.messagetype);
}
