import 'package:fearless_chat_demo/Utils/Transitions/fade_route.dart';
import 'package:fearless_chat_demo/Utils/Transitions/scale_rotate_route.dart';
import 'package:fearless_chat_demo/Utils/Transitions/scale_route.dart';
import 'package:fearless_chat_demo/Utils/Transitions/slide_route.dart';
import 'package:flutter/material.dart';

/// rootNavigator parametresi = false ise bottom navigation bar görünür, true olarak setlenirse görünmez.
Future<void> navigatePageRight({
  required BuildContext context,
  required Widget page,
  required bool rootNavigator,
}) async {
  await Navigator.of(context, rootNavigator: rootNavigator)
      .push(SlideRightRoute(page: page));
}

/// rootNavigator parametresi = false ise bottom navigation bar görünür, true olarak setlenirse görünmez.
Future<void> navigatePageLeft({
  required BuildContext context,
  required Widget page,
  required bool rootNavigator,
}) async {
  await Navigator.of(context, rootNavigator: rootNavigator)
      .push(SlideLeftRoute(page: page));
}

/// rootNavigator parametresi = false ise bottom navigation bar görünür, true olarak setlenirse görünmez.
Future<void> navigatePageBottom({
  required BuildContext context,
  required Widget page,
  required bool rootNavigator,
}) async {
  await Navigator.of(context, rootNavigator: rootNavigator)
      .push(SlideBottomRoute(page: page));
}

/// rootNavigator parametresi = false ise bottom navigation bar görünür, true olarak setlenirse görünmez.
Future<void> navigatePageTop({
  required BuildContext context,
  required Widget page,
  required bool rootNavigator,
}) async {
  await Navigator.of(context, rootNavigator: rootNavigator)
      .push(SlideTopRoute(page: page));
}

/// rootNavigator parametresi = false ise bottom navigation bar görünür, true olarak setlenirse görünmez.
Future<void> navigatePageFade({
  required BuildContext context,
  required Widget page,
  required bool rootNavigator,
}) async {
  await Navigator.of(context, rootNavigator: rootNavigator)
      .push(FadeRoute(page: page));
}

/// rootNavigator parametresi = false ise bottom navigation bar görünür, true olarak setlenirse görünmez.
Future<void> navigatePageScale({
  required BuildContext context,
  required Widget page,
  required bool rootNavigator,
}) async {
  await Navigator.of(context, rootNavigator: rootNavigator)
      .push(ScaleRoute(page: page));
}

/// rootNavigator parametresi = false ise bottom navigation bar görünür, true olarak setlenirse görünmez.
Future<void> navigatePageScaleRotate({
  required BuildContext context,
  required Widget page,
  required bool rootNavigator,
}) async {
  await Navigator.of(context, rootNavigator: rootNavigator)
      .push(ScaleRotateRoute(page: page));
}

Future<void> navigateRootPage({
  required BuildContext context,
  required Widget page,
  required bool fullscreenDialog,
}) async {
  Navigator.of(context).push(
    MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return page;
      },
      fullscreenDialog: fullscreenDialog,
    ),
  );
}
