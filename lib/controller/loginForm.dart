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
    return isload != true
        ? Scaffold(
            body: SingleChildScrollView(
              child: Center(
                  child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 330,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(100)),
                          color: secondColor),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                    width: 83,
                                    height: 83,
                                    child: Image.asset('assets/logo.png')),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PrimaryText(
                                      data: "Socials App",
                                      fsize: 30,
                                      fw: FontWeight.bold,
                                      fcolor: Colors.white,
                                    ),
                                    PrimaryText(
                                      data:
                                          "Number 1 Social Media app\nfor student",
                                      fsize: 14,
                                      fw: FontWeight.normal,
                                      fcolor: Colors.white,
                                    )
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
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
                              if (value == null ||
                                  !value.endsWith('@cpu.edu.ph')) {
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
                                        builder: (context) =>
                                            const SignUpForm()));
                              },
                              child: const PrimaryText(
                                data: "Dont have an account? Sign up",
                                fcolor: secondColor,
                              ))
                        ],
                      ),
                    )
                  ],
                ),
              )),
            ),
          )
        : const Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ),
          );
  }

  Future<void> _submitform() async {
    setState(() {
      isload = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailcont.text, password: _passwordcont.text);

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        setState(() {
          isload = false;
        });

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Email not verified"),
            content: const Text(
                "Your email is not verified. Please check your inbox and verify your email to proceed."),
            actions: [
              TextButton(
                onPressed: () async {
                  await user.sendEmailVerification();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Resend Verification Email"),
              ),
              TextButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          isload = false;
        });

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (error) {
      debugPrint("$error");
      setState(() {
        isload = false;
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Login Error"),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }
}
