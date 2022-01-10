import 'package:flutter/material.dart';

class Global {
  Color purple = Colors.purple[900] as Color;
}

enum MessageType { sent, received }

List<Map<String, dynamic>> friendsList = [
  {
    'usrId': '1',
    'imgUrl':
        'https://cdn.pixabay.com/photo/2019/11/06/17/26/gear-4606749_960_720.jpg',
    'username': 'Cybdom Tech',
    'lastMsg': 'Hey, checkout my website: cybdom.tech ;)',
    'seen': true,
    'hasUnSeenMsgs': false,
    'unseenCount': 0,
    'lastMsgTime': '18:44',
    'isOnline': true
  },
  {
    'usrId': '2',
    'imgUrl':
        'https://iaahbr.tmgrup.com.tr/985538/0/0/0/0/0/0?u=https://iahbr.tmgrup.com.tr/album/2021/09/11/nasanin-ardindan-simdi-de-cinli-astronot-van-golunu-anka-kusuna-benzetti-1631369786545.jpg',
    'username': 'Flutter Dev',
    'lastMsg': 'Hey, checkout my website: cybdom.tech ;)',
    'seen': false,
    'hasUnSeenMsgs': false,
    'unseenCount': 0,
    'lastMsgTime': '18:44',
    'isOnline': false
  },
  {
    'usrId': '3',
    'imgUrl':
        'https://cdn.pixabay.com/photo/2019/11/05/08/52/adler-4603104_960_720.jpg',
    'username': 'Dart Dev',
    'lastMsg': 'Hey, checkout my website: cybdom.tech ;)',
    'seen': false,
    'hasUnSeenMsgs': true,
    'unseenCount': 3,
    'lastMsgTime': '18:44',
    'isOnline': true
  },
  {
    'usrId': '4',
    'imgUrl':
        'https://cdn.pixabay.com/photo/2015/02/04/08/03/baby-623417_960_720.jpg',
    'username': 'Designer',
    'lastMsg': 'Hey, checkout my website: cybdom.tech ;)',
    'seen': true,
    'hasUnSeenMsgs': true,
    'unseenCount': 2,
    'lastMsgTime': '18:44',
    'isOnline': true
  },
  {
    'usrId': '5',
    'imgUrl':
        'https://i2.milimaj.com/i/milliyet/75/1200x675/60899c1386b24406dc93a873.jpg',
    'username': 'FrontEnd Dev',
    'lastMsg': 'Hey, checkout my website: cybdom.tech ;)',
    'seen': false,
    'hasUnSeenMsgs': true,
    'unseenCount': 4,
    'lastMsgTime': '18:44',
    'isOnline': true
  },
  {
    'usrId': '6',
    'imgUrl':
        'https://i2.milimaj.com/i/milliyet/75/1200x675/60899c1386b24406dc93a873.jpg',
    'username': 'Full Stack Dev',
    'lastMsg': 'Hey, checkout my website: cybdom.tech ;)',
    'seen': false,
    'hasUnSeenMsgs': false,
    'unseenCount': 0,
    'lastMsgTime': '18:44',
    'isOnline': true
  },
  {
    'usrId': '7',
    'imgUrl':
        'https://im.haberturk.com/2021/04/28/ver1619642744/3055206_414x414.jpg',
    'username': 'Backend Dev',
    'lastMsg': 'Hey, checkout my website: cybdom.tech ;)',
    'seen': false,
    'hasUnSeenMsgs': true,
    'unseenCount': 3,
    'lastMsgTime': '18:44',
    'isOnline': true
  }
];

List<Map<String, dynamic>> messages = [
  {
    'usrId': '2',
    'status': MessageType.received,
    'contactImgUrl':
        'https://iaahbr.tmgrup.com.tr/985538/0/0/0/0/0/0?u=https://iahbr.tmgrup.com.tr/album/2021/09/11/nasanin-ardindan-simdi-de-cinli-astronot-van-golunu-anka-kusuna-benzetti-1631369786545.jpg',
    'contactName': 'Client',
    'message':
        'Hi mate, I\d like to hire you to create a mobile app for my business',
    'time': '08:43 AM',
    'hasShareMedia': false
  },
  {
    'usrId': '2',
    'status': MessageType.sent,
    'message': 'Hi, I hope you are doing great!',
    'time': '08:45 AM',
    'hasShareMedia': false
  },
  {
    'usrId': '2',
    'status': MessageType.sent,
    'message':
        'Please share with me the details of your project, as well as your time and budgets constraints.',
    'time': '08:45 AM',
    'hasShareMedia': false
  },
  {
    'usrId': '2',
    'status': MessageType.received,
    'contactImgUrl':
        'https://iaahbr.tmgrup.com.tr/985538/0/0/0/0/0/0?u=https://iahbr.tmgrup.com.tr/album/2021/09/11/nasanin-ardindan-simdi-de-cinli-astronot-van-golunu-anka-kusuna-benzetti-1631369786545.jpg',
    'contactName': 'Client',
    'message': 'Sure, let me send you a document that explains everything.',
    'time': '08:47 AM',
    'hasShareMedia': false
  },
  {
    'usrId': '2',
    'status': MessageType.sent,
    'message': 'Ok.',
    'time': '08:45 AM',
    'hasShareMedia': true
  },
];
