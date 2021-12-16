// ignore_for_file: file_names

import 'package:fearless_chat_demo/Models/error.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        result.result = 'Success';
        result.hasError = false;
        return result;
      } else {
        result.result = 'Error';
        result.hasError = true;
        return result;
      }
    } on Exception catch (e) {
      print(e);
      result.result = (e as FirebaseAuthException).message!;
      result.hasError = true;
      return result;
    }
  }

  Future<bool> signInUser(String email, String password) async {
    UserCredential uc = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    if (uc.user != null) return true;
    return false;
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
      print(e);
      isVerificationSendSuccess = false;
    }

    return isVerificationSendSuccess;
  }
}
