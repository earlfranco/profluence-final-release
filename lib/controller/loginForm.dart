// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social/controller/signupForm.dart';
import 'package:social/utils/globaltheme.dart';
import 'package:social/views/homepage.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailcont = TextEditingController();
  final TextEditingController _passwordcont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isload = false;

  @override
  void dispose() {
    super.dispose();
    _emailcont.dispose();
    _passwordcont.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isload != true
              ? Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _emailcont,
                        decoration: const InputDecoration(
                            labelText: 'Email address',
                            labelStyle: TextStyle(color: Colors.black),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: secondColor),
                            ),
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || !value.endsWith('@cpu.edu.ph')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordcont,
                        decoration: const InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.black),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: secondColor),
                            ),
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: GlobalButton(
                            callback: () {
                              if (_formKey.currentState!.validate()) {
                                _submitform();
                              }
                            },
                            title: "Login"),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUpForm()));
                          },
                          child: const PrimaryText(
                            data: "Dont have an account? Sign up",
                            fcolor: secondColor,
                          ))
                    ],
                  ),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: CircularProgressIndicator(),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _submitform() async {
    setState(() {
      isload = true;
    });
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailcont.text, password: _passwordcont.text)
          .then((uid) {
        setState(() {
          isload = false;
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Homepage()),
              (Route<dynamic> route) => false);
        });
      });
    } catch (error) {
      debugPrint("$error");
        setState(() {
        isload = false;
      });
    }
  }
}
