// ignore_for_file: file_names

import 'package:fearless_chat_demo/Models/result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final instance = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Result> signUpUser(String email, String password) async {
    UserCredential? user;
    Result result = Result(false, "");
    try {
      user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (user.user != null) {
        await sendEmailVerification(user.user);
        result.message = 'Register Success';
        result.hasError = false;
        return result;
      } else {
        result.message = 'Register Error';
        result.hasError = true;
        return result;
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      result.message = (e as FirebaseAuthException).message!;
      result.hasError = true;
      return result;
    }
  }

  Future<Result> signInUser(String email, String password) async {
    Result result = Result(false, "");
    try {
      UserCredential uc = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (uc.user != null) {
        Result result = Result(false, "Register Success");
        return result;
      } else {
        result.message = 'Error';
        result.hasError = true;
        return result;
      }
    } on Exception catch (e) {
      result.message = (e as FirebaseAuthException).message!;
      result.hasError = true;
      return result;
    }
  }

  Future<bool> sendEmailVerification(User? user) async {
    bool isVerificationSendSuccess = false;
    try {
      await _auth.sendSignInLinkToEmail(
        email: user!.email!,
        actionCodeSettings: ActionCodeSettings(
            url: "https://example.page.link/cYk9",
            androidPackageName: "com.example.fearless_chat_demo",
            iOSBundleId: "com.example.fearless_chat_demo",
            handleCodeInApp: true,
            androidMinimumVersion: "16",
            androidInstallApp: true),
      );
      await user.sendEmailVerification();
      isVerificationSendSuccess = true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      isVerificationSendSuccess = false;
    }

    return isVerificationSendSuccess;
  }
}
