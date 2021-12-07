// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final instance = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signUpUser(String email, String password) async {
    UserCredential? user;

    try {
      user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (user != null) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> signInUser(String email, String password) async {
    return false;
  }

  Future<bool> sendEmailVerification(String email) async {
    return true;
  }
}
