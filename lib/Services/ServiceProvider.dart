import 'package:fearless_chat_demo/Models/friend.dart';
import 'package:flutter/widgets.dart';

class ServiceProvider with ChangeNotifier {
  late int _count;
  int get count => _count;
  Future<void> getUnseenMessageCount(List<Friend> friendList) async {
    _count = 0;
    for (var item in friendList) {
      if (item.hasUnSeenMsgs) {
        _count += item.unseenCount;
      }
    }
    Future.delayed(Duration(seconds: 1), () {
      notifyListeners();
    });
  }
}
