import 'package:fearless_chat_demo/Models/cameraimage.dart';
import 'package:fearless_chat_demo/Models/message.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

class Global {
  Global._();

  static init() async {
    documentPath = (await getApplicationDocumentsDirectory()).path + "/";
  }

  static List<Message> getMessages() {
    List<Message> _messages = [];
    for (var item in messages) {
      Message m = Message.fromMap(item);

      _messages.add(m);
    }

    return _messages;
  }

  static List<TakenCameraMedia> allMediaList = [];
  static String selectedUserId = "";
  static const double borderRadius = 27;
  static const double defaultPadding = 8;
  static String documentPath = '';
  static GlobalKey<AnimatedListState> audioListKey =
      GlobalKey<AnimatedListState>();
  static Color mainColor = Colors.purple[900] as Color;
  static List<Map<String, dynamic>> messages = [
    {
      'usrId': '2',
      'status': MessageType.received,
      'contactImgUrl':
          'https://iaahbr.tmgrup.com.tr/985538/0/0/0/0/0/0?u=https://iahbr.tmgrup.com.tr/album/2021/09/11/nasanin-ardindan-simdi-de-cinli-astronot-van-golunu-anka-kusuna-benzetti-1631369786545.jpg',
      'contactName': 'Client',
      'message':
          'Hi mate, I\d like to hire you to create a mobile app for my business',
      'time': '08:43 AM',
      'hasShareMedia': false,
      'filePaths': [],
      'location': []
    },
    {
      'usrId': '2',
      'status': MessageType.sent,
      'message': 'Hi, I hope you are doing great!',
      'time': '08:45 AM',
      'hasShareMedia': false,
      'filePaths': [],
      'location': []
    },
    {
      'usrId': '2',
      'status': MessageType.sent,
      'message':
          'Please share with me the details of your project, as well as your time and budgets constraints.',
      'time': '08:45 AM',
      'hasShareMedia': false,
      'filePaths': [],
      'location': []
    },
    {
      'usrId': '2',
      'status': MessageType.received,
      'contactImgUrl':
          'https://iaahbr.tmgrup.com.tr/985538/0/0/0/0/0/0?u=https://iahbr.tmgrup.com.tr/album/2021/09/11/nasanin-ardindan-simdi-de-cinli-astronot-van-golunu-anka-kusuna-benzetti-1631369786545.jpg',
      'contactName': 'Client',
      'message': 'Sure, let me send you a document that explains everything.',
      'time': '08:47 AM',
      'hasShareMedia': false,
      'filePaths': [],
      'location': []
    },
    {
      'usrId': '2',
      'status': MessageType.sent,
      'message': 'Ok.',
      'time': '08:45 AM',
      'hasShareMedia': false,
      'filePaths': [],
      'location': []
    },
  ];
}

enum MessageType { sent, received }

List<Map<String, dynamic>> friendsList = [
  {
    'usrId': '1',
    'imgUrl':
        'https://media-exp1.licdn.com/dms/image/C5603AQEb1R5k0_7pdA/profile-displayphoto-shrink_800_800/0/1558898361166?e=1647475200&v=beta&t=334NX6VqYm7COEGU00dP9rnYJ9jeTvXgeeo96zyU-KU',
    'username': 'Murat Aslan',
    'lastMsg': 'Hey, checkout this out ;)',
    'seen': true,
    'hasUnSeenMsgs': false,
    'unseenCount': 0,
    'lastMsgTime': '18:44',
    'isOnline': true,
    'isFavorite': false
  },
  {
    'usrId': '2',
    'imgUrl':
        'https://media-exp1.licdn.com/dms/image/C4D03AQFQjlvpRnIFPQ/profile-displayphoto-shrink_200_200/0/1588587309006?e=1647475200&v=beta&t=VwsvIa02DY4-KT21w12-Qe04EiVs2lxBNX-1WeFvdyY',
    'username': 'ArmağanX',
    'lastMsg': 'Hey bro ;)',
    'seen': false,
    'hasUnSeenMsgs': true,
    'unseenCount': 1,
    'lastMsgTime': '18:44',
    'isOnline': false,
    'isFavorite': false
  },
  {
    'usrId': '3',
    'imgUrl':
        'https://media-exp1.licdn.com/dms/image/C4D03AQGFku00U3dUDQ/profile-displayphoto-shrink_800_800/0/1642167635891?e=1647475200&v=beta&t=dCeaFg6zME10kUu67BML34Rzu8D9Zh40p-NQxa2REFI',
    'username': 'Berk Er',
    'lastMsg': 'Hey, checkout my website: my blog ;)',
    'seen': false,
    'hasUnSeenMsgs': true,
    'unseenCount': 3,
    'lastMsgTime': '18:44',
    'isOnline': true,
    'isFavorite': false
  },
  {
    'usrId': '4',
    'imgUrl':
        'https://www.indyturk.com/sites/default/files/styles/1368x911/public/article/main_image/2020/12/11/531136-1057777991.jpg?itok=SZR2vQVu',
    'username': 'Designer',
    'lastMsg': 'No android specific permissions needed for ;)',
    'seen': true,
    'hasUnSeenMsgs': true,
    'unseenCount': 2,
    'lastMsgTime': '18:44',
    'isOnline': true,
    'isFavorite': false
  },
  {
    'usrId': '5',
    'imgUrl':
        'https://i2.milimaj.com/i/milliyet/75/1200x675/60899c1386b24406dc93a873.jpg',
    'username': 'FrontEnd Dev',
    'lastMsg': 'Reloaded 8 of 1812 libraries in 947ms. ;)',
    'seen': false,
    'hasUnSeenMsgs': true,
    'unseenCount': 4,
    'lastMsgTime': '18:44',
    'isOnline': true,
    'isFavorite': false
  },
  {
    'usrId': '6',
    'imgUrl':
        'https://i2.milimaj.com/i/milliyet/75/1200x675/60899c1386b24406dc93a873.jpg',
    'username': 'Full Stack Dev',
    'lastMsg': 'Reloaded 8 of 1812 libraries in 826ms.;)',
    'seen': false,
    'hasUnSeenMsgs': false,
    'unseenCount': 0,
    'lastMsgTime': '18:44',
    'isOnline': true,
    'isFavorite': false
  },
  {
    'usrId': '7',
    'imgUrl':
        'https://im.haberturk.com/2021/04/28/ver1619642744/3055206_414x414.jpg',
    'username': 'Backend Dev',
    'lastMsg': 'Hey, checkout Fearless_Chat_Demo...     ;)',
    'seen': false,
    'hasUnSeenMsgs': true,
    'unseenCount': 3,
    'lastMsgTime': '18:44',
    'isOnline': true,
    'isFavorite': false
  }
];
