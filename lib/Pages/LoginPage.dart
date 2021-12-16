// ignore_for_file: file_names

import 'package:fearless_chat_demo/Models/error.dart';
import 'package:fearless_chat_demo/Services/AuthService.dart';
import 'package:fearless_chat_demo/Widgets/CustomDialogBox.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Color? _buttonColorRegister = Colors.red;
  Color? _buttonColorLogin = Colors.green;
  bool userLoginSuccess = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height / 1.2,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.blueAccent,
                  size: 100,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.mail),
                            hintText: 'Sana nereden ulaşabiliriz?',
                            labelText: 'E-Posta',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (String? value) {
                            if (value == null) {
                              return "Lütfen alanı doldurunuz.";
                            }

                            if (!value.contains('@')) {
                              return "Lütfen e-posta adresinizi doğru giriniz.";
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.vpn_key),
                            hintText: 'Lütfen parolanızı gizli tutunuz.',
                            labelText: 'Şifre',
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          validator: (String? value) {
                            if (value == null) {
                              return "Lütfen alanı doldurunuz.";
                            }

                            if (value.length < 10) {
                              return "Şifreniz minimum 10 karakterden oluşmalıdır.";
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(),
                            ),
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                child: const Text("Giriş"),
                                style: ElevatedButton.styleFrom(
                                    primary: _buttonColorLogin),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _buttonColorLogin = Colors.green;
                                    });

                                    Result result = await AuthService.instance
                                        .signInUser(_emailController.text,
                                            _passwordController.text);

                                    if (!result.hasError) {
                                      setState(() {
                                        _buttonColorLogin =
                                            Colors.lightGreenAccent;
                                      });
                                    } else {
                                      setState(() {
                                        _buttonColorLogin = Colors.black;
                                      });
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return WillPopScope(
                                              onWillPop: () =>
                                                  Future.value(false),
                                              child: CustomDialogBox(
                                                title: "",
                                                descriptions: result.message,
                                                submitText: 'OK',
                                                widget: const Icon(
                                                    Icons.warning_rounded,
                                                    color: Colors.red,
                                                    size: 50),
                                              ),
                                            );
                                          });
                                    }
                                  } else {
                                    setState(() {
                                      _buttonColorLogin = Colors.red;
                                    });
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(),
                            ),
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                child: const Text("Kayıt Ol"),
                                style: ElevatedButton.styleFrom(
                                    primary: _buttonColorRegister),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _buttonColorRegister = Colors.amber;
                                    });
                                    Result result = Result(false, "");
                                    result = await AuthService.instance
                                        .signUpUser(_emailController.text,
                                            _passwordController.text);

                                    if (!result.hasError) {
                                      setState(() {
                                        _buttonColorRegister = Colors.green;
                                      });
                                    } else {
                                      setState(() {
                                        _buttonColorRegister = Colors.black;
                                      });
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return WillPopScope(
                                            onWillPop: () =>
                                                Future.value(false),
                                            child: CustomDialogBox(
                                              title: "",
                                              descriptions: result.message,
                                              submitText: 'OK',
                                              widget: const Icon(
                                                  Icons.warning_rounded,
                                                  color: Colors.red,
                                                  size: 50),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    setState(() {
                                      _buttonColorRegister = Colors.red;
                                    });
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
