// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social/controller/loginForm.dart';
import 'package:social/utils/globaltheme.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  XFile? imagepic;
  bool islaod = false;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _schoolIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpasswordController = TextEditingController();

  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: secondColor,
      ),
      body: islaod != true
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const PrimaryText(data: "Add Profile"),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: imagepic != null
                                ? BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: FileImage(File(imagepic!.path))))
                                : const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(43, 0, 0, 0),
                                  ),
                            child: imagepic != null
                                ? Container()
                                : const Center(
                                    child: Icon(
                                      Icons.add_a_photo_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                                labelText: 'Name',
                                labelStyle: TextStyle(color: Colors.black),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: secondColor),
                                ),
                                border: OutlineInputBorder()),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.black),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: secondColor),
                              ),
                              border: OutlineInputBorder(),
                            ),
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
                            controller: _schoolIdController,
                            decoration: const InputDecoration(
                                labelText: 'School ID',
                                labelStyle: TextStyle(color: Colors.black),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: secondColor),
                                ),
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              String pattern = r'^\d{2}-\d{4}-\d{2}$';
                              RegExp regex = RegExp(pattern);
                              if (value == null || !regex.hasMatch(value)) {
                                return 'Invalid School ID format';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: secondColor),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordHidden
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: secondColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordHidden =
                                              !_isPasswordHidden;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: _isPasswordHidden,
                                  validator: (value) {
                                    if (value == null || value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _cpasswordController,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: secondColor),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordHidden
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: secondColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordHidden =
                                              !_isPasswordHidden;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: _isPasswordHidden,
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return 'Password did not match';
                                    }
                                    return null;
                                  },
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: GlobalButton(
                                callback: () {
                                  if (_formKey.currentState!.validate()) {
                                    _submitForm();
                                  }
                                },
                                title: "Signup"),
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
                                            const LoginForm()));
                              },
                              child: const PrimaryText(
                                data: "Already have an account? Login",
                                fcolor: secondColor,
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ),
    );
  }

  Future<void> _pickImage() async {
    XFile? imagedata =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (imagedata != null) {
      setState(() {
        imagepic = imagedata;
      });
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      islaod = true;
    });

    try {
      if (imagepic != null) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);

        User? user = userCredential.user;
        if (user != null) {
          await user.sendEmailVerification();

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}.jpg');
          await storageRef.putFile(File(imagepic!.path));
          String imageUrl = await storageRef.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'name': _nameController.text,
            'email': _emailController.text,
            'schoolId': _schoolIdController.text,
            'isvalid': 1,
            'isonline': 0,
            'profileImage': imageUrl,
            'userid': user.uid,
            'timesignup': Timestamp.now(),
          }).then((uid) {
            // Inform the user to check their email for verification
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Verification Email Sent"),
                content: const Text(
                    "A verification email has been sent to your email address. Please check your inbox."),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginForm()));
                    },
                  ),
                ],
              ),
            );
          });

          debugPrint("Account created successfully! Verification email sent.");
        }
      } else {
        _showSnackBar("Please upload a profile picture.");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showSnackBar("This email is already registered. Please log in.");
      } else if (e.code == 'invalid-email') {
        _showSnackBar("The email address is not valid.");
      } else if (e.code == 'operation-not-allowed') {
        _showSnackBar("Email/password accounts are not enabled.");
      } else if (e.code == 'too-many-requests') {
        _showSnackBar("Too many requests. Please try again later.");
      } else {
        _showSnackBar("An error occurred. Please try again.");
      }
    } on FirebaseException catch (e) {
      if (e.code == 'unauthorized') {
        _showSnackBar("You are not authorized to perform this action.");
      } else if (e.code == 'cancelled') {
        _showSnackBar("The operation was cancelled.");
      } else {
        _showSnackBar("Failed to upload image. Please try again.");
      }
    } catch (e) {
      debugPrint("Error: $e");
      _showSnackBar("An unexpected error occurred.");
    } finally {
      setState(() {
        islaod = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _schoolIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
