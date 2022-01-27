import 'dart:io';

import 'package:fearless_chat_demo/Models/cameraimage.dart';
import 'package:fearless_chat_demo/Services/ServiceProvider.dart';
import 'package:fearless_chat_demo/Theme/AppThemes.dart';
import 'package:fearless_chat_demo/Theme/ThemeModel.dart';
import 'package:fearless_chat_demo/Utils/global.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'Pages/mainPage.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  await Global.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => ThemeModel()),
      ],
      child: const FearlessChatApp(),
    ),
  );

  // runApp(ChangeNotifierProvider<ServiceProvider>(
  //     create: (context) => ServiceProvider(), child: const FearlessChatApp()));
}

class FearlessChatApp extends StatefulWidget {
  const FearlessChatApp({Key? key}) : super(key: key);

  @override
  State<FearlessChatApp> createState() => _FearlessChatAppState();
}

class _FearlessChatAppState extends State<FearlessChatApp> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      List<TakenCameraMedia> t = await getAlbumss();
      Global.allMediaList = t;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: null,
      statusBarColor: Color(0xFF4a148c),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ));
    return ChangeNotifierProvider(
      create: (BuildContext context) => ThemeModel(),
      child: Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: themeNotifier.isDark
                ? AppThemes.darkTheme
                : AppThemes.lightTheme,
            themeMode: ThemeMode.system,

            home: MainPage(),
            // home: const AnnotatedRegion<SystemUiOverlayStyle>(
            //     value: SystemUiOverlayStyle(statusBarColor: Colors.white),
            //     child: MainPage()),
          );
        },
      ),
    );
  }

  Future<bool> _promptPermissionSetting() async {
    // if (!t) {
    //   showDialog(
    //       context: context,
    //       builder: (BuildContext context) => CupertinoAlertDialog(
    //             title: Text('Camera Permission'),
    //             content: Text('This app needs media gallery'),
    //             actions: <Widget>[
    //               CupertinoDialogAction(
    //                 child: Text('Deny'),
    //                 onPressed: () => Navigator.of(context).pop(),
    //               ),
    //               CupertinoDialogAction(
    //                 child: Text('Settings'),
    //                 onPressed: () => openAppSettings(),
    //               ),
    //             ],
    //           ));
    // }
    if (Platform.isIOS &&
            await Permission.storage.request().isGranted &&
            await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<List<TakenCameraMedia>> getAlbumss() async {
    List<TakenCameraMedia> mediaPathList = [];
    if (await _promptPermissionSetting()) {
      List<Medium> allMedia = [];
      List<Album> imageAlbums = [];
      List<Album> videoAlbums = [];
      await PhotoGallery.listAlbums(mediumType: MediumType.image).then((value) {
        imageAlbums = value;
        // _imageAlbumCount = imageAlbums.length;
      });

      await PhotoGallery.listAlbums(
              mediumType: MediumType.video, hideIfEmpty: false)
          .then((value) {
        videoAlbums = value;
        // _videoAlbumCount = videoAlbums.length;
      });
      List<Medium> dataImage = [];
      for (var item in imageAlbums) {
        // dataImage.addAll(await item.getThumbnail());
        MediaPage mediaPage = await item.listMedia(newest: true);
        dataImage.addAll(mediaPage.items);
      }
      List<Medium> dataVideo = [];
      for (var item in videoAlbums) {
        // dataVideo.addAll(await item.getThumbnail());
        MediaPage mediaPage = await item.listMedia(newest: true);
        dataVideo.addAll(mediaPage.items);
      }
      allMedia = [
        ...dataImage,
        ...dataVideo,
      ];
      // MediaPage imagePage;
      // await imageAlbums[0]
      //     .listMedia(
      //   newest: true,
      // )
      //     .then((value) {
      //   imagePage = value;
      //   setState(() {
      //     allMedia.addAll(imagePage.items);
      //   });
      // });
      // MediaPage videoPage;

      // await videoAlbums[0]
      //     .listMedia(
      //   newest: true,
      // )
      //     .then((value) {
      //   setState(() {
      //     videoPage = value;
      //     allMedia.addAll(videoPage.items);
      //   });
      // });

      for (var item in allMedia) {
        TakenCameraMedia media = TakenCameraMedia(
            "",
            false,
            item.modifiedDate!,
            item.mediumType == MediumType.video
                ? FileType.video
                : FileType.photo,
            item);

        mediaPathList.add(media);
        mediaPathList.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      }
    }
    return mediaPathList;
  }
}
