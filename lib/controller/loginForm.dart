// ignore_for_file: file_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social/controller/forgotpassword.dart';
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
  void initState() {
    super.initState();
    _checkSavedCredentials();
  }

  Future<void> _checkSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');

    if (savedEmail != null && savedPassword != null) {
      _emailcont.text = savedEmail;
      _passwordcont.text = savedPassword;
      _submitform(autoLogin: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isload != true
        ? Scaffold(
            body: SingleChildScrollView(
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
                          crossAxisAlignment: CrossAxisAlignment.end,
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
                                      data: "Profluence",
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
                        crossAxisAlignment: CrossAxisAlignment.end,
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
                            obscureText: true,
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
                            height: 5,
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Forgotpasswordpage()));
                              },
                              child: const PrimaryText(
                                falign: TextAlign.right,
                                data: "Forgot password?",
                                fcolor: secondColor,
                              )),
                          const SizedBox(
                            height: 10,
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
                          Center(
                            child: TextButton(
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
                                )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
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

  Future<void> _submitform({bool autoLogin = false}) async {
    setState(() {
      isload = true;
    });

    try {
      // Attempt to sign in with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailcont.text,
        password: _passwordcont.text,
      );

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Check if the user is banned by looking at the "isvalid" field in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc['isvalid'] == 2) {
          // If "isvalid" is 2, show a modal saying the user is banned
          setState(() {
            isload = false;
          });

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Account Banned"),
              content: const Text(
                  "Your account has been banned for violating our privacy and policy."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        } else if (!user.emailVerified) {
          setState(() {
            isload = false;
          });

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
                    Navigator.of(context).pop();
                  },
                  child: const Text("Resend Verification Email"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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

          if (!autoLogin) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('email', _emailcont.text);
            await prefs.setString('password', _passwordcont.text);
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Homepage()),
            (Route<dynamic> route) => false,
          );

          await _dailylogin(user.uid);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isload = false;
      });

      String errorMessage = "An error occurred. Please try again.";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is invalid.";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This account has been disabled.";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Too many login attempts. Try again later.";
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Login Error"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        isload = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("An unexpected error occurred."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _dailylogin(String uid) async {
    FirebaseFirestore.instance.collection('dailylogin').add({
      'name': _emailcont.text,
      'userid': uid,
      'login': 1,
      'timesignup': Timestamp.now(),
    }).then((id) {
      _dailyloginrecord(uid);
    });
  }

  Future<void> _dailyloginrecord(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isonline': 1,
    });
  }
}
