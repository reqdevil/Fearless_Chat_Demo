import 'package:fearless_chat_demo/Services/ServiceProvider.dart';
import 'package:fearless_chat_demo/Theme/AppThemes.dart';
import 'package:fearless_chat_demo/Theme/ThemeModel.dart';
import 'package:fearless_chat_demo/Utils/global.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
}
