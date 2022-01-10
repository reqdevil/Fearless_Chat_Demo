import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Message {
  String userName;
  String message;
  String time;
  MessageType messagetype;
  Message(this.userName, this.message, this.time, this.messagetype);
}

enum MessageType { camedMessage, sendedMessage }
