class Message {
  int userId;
  String userName;
  String message;
  String time;
  MessageType messagetype;
  Message(
      this.userId, this.userName, this.message, this.time, this.messagetype);
}

enum MessageType { camedMessage, sendedMessage }
