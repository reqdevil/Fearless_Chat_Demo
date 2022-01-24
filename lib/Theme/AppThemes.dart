import 'package:fearless_chat_demo/Utils/global.dart';
import 'package:flutter/material.dart';

class AppThemes {
  //-------------DARK THEME SETTINGS----
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF151026),
    appBarTheme: AppBarTheme(
      color: const Color(0xFF151026),
    ),
    primaryColor: Global.mainColor,
    iconTheme: new IconThemeData(
      color: Colors.white,
      opacity: 1.0,
    ),
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      surface: Colors.grey,
      onSurface: Colors.black,
      // Colors that are not relevant to AppBar in DARK mode:
      primary: Global.mainColor,
      onPrimary: Colors.grey,
      primaryVariant: Colors.grey,
      secondary: Colors.grey,
      secondaryVariant: Colors.white,
      onSecondary: Colors.black,
      background: Colors.grey,
      onBackground: Colors.grey,
      error: Colors.grey,
      onError: Colors.grey,
    ),
    // colorScheme: ColorScheme.dark(),
  );

  //-------------light THEME SETTINGS----
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: Colors.white,
    ),
    primaryColor: Global.mainColor,
    iconTheme: new IconThemeData(
      color: Global.mainColor,
      opacity: 1.0,
    ),
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      surface: Colors.white,
      onSurface: Colors.black,
      // Colors that are not relevant to AppBar in DARK mode:
      primary: Global.mainColor,
      onPrimary: Colors.grey,
      primaryVariant: Colors.grey,
      secondary: Colors.grey,
      secondaryVariant: Colors.white,
      onSecondary: Global.mainColor,
      background: Colors.grey[300] as Color,
      onBackground: Global.mainColor,
      error: Colors.grey,
      onError: Colors.grey,
    ),
    // colorScheme: ColorScheme.light(),
  );
}
