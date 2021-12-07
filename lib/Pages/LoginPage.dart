// ignore_for_file: file_names

import 'package:fearless_chat_demo/Services/AuthService.dart';
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

  Color? _buttonColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        child: Padding(
          padding: const EdgeInsets.all(10),
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
                        child: const Text("Kayıt Ol"),
                        style: ElevatedButton.styleFrom(primary: _buttonColor),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _buttonColor = Colors.amber;
                            });

                            var success = await AuthService.instance.signUpUser(
                                _emailController.text,
                                _passwordController.text);

                            if (success) {
                              setState(() {
                                _buttonColor = Colors.green;
                              });
                            } else {
                              setState(() {
                                _buttonColor = Colors.black;
                              });
                            }
                          } else {
                            setState(() {
                              _buttonColor = Colors.red;
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
      ),
    );
  }
}
