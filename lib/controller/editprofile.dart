// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social/utils/globaltheme.dart';

class EditprofilePage extends StatefulWidget {
  final String userID;
  final String userProfile;
  const EditprofilePage(
      {super.key, required this.userID, required this.userProfile});

  @override
  _EditprofilePageState createState() => _EditprofilePageState();
}

class _EditprofilePageState extends State<EditprofilePage> {
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
  bool _enableEmailPassword = false;
  bool iseditProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userID)
        .get();
    if (userDoc.exists) {
      _nameController.text = userDoc['name'];
      _emailController.text = userDoc['email'];
      _schoolIdController.text = userDoc['schoolId'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Edit Profile',
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
                        const PrimaryText(data: "Edit Profile"),
                        const SizedBox(width: 10),
                        iseditProfile == true
                            ? GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: imagepic != null
                                      ? BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image:
                                                FileImage(File(imagepic!.path)),
                                            fit: BoxFit.cover,
                                          ),
                                        )
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
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    iseditProfile = true;
                                  });
                                },
                                child: CircleAvatar(
                                  maxRadius: 23,
                                  foregroundImage:
                                      NetworkImage(widget.userProfile),
                                ),
                              )
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
                            enabled: _enableEmailPassword,
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
                                  enabled: _enableEmailPassword,
                                  // validator: (value) {
                                  //   if (value != null && value.length < 6) {
                                  //     return 'Password must be at least 6 characters';
                                  //   }
                                  //   return null;
                                  // },
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
                                  enabled: _enableEmailPassword,
                                  // validator: (value) {
                                  //   if (_enableEmailPassword &&
                                  //       value != _passwordController.text) {
                                  //     return 'Password did not match';
                                  //   }
                                  //   return null;
                                  // },
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
                                  _updateProfile();
                                }
                              },
                              title: "Update Profile",
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _enableEmailPassword = !_enableEmailPassword;
                              });
                            },
                            child: Text(
                              _enableEmailPassword
                                  ? "Cancel Editing"
                                  : "Edit Email/Password",
                              style: const TextStyle(color: secondColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
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

  Future<void> _updateProfile() async {
    setState(() {
      islaod = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Re-authenticate the user
        if (_enableEmailPassword) {
          if (_emailController.text != user.email) {
            final String email = user.email!;
            final String password =
                await _getUserPassword(); // Get the user's password from a dialog input

            AuthCredential credential = EmailAuthProvider.credential(
              email: email,
              password: password,
            );

            await user
                .reauthenticateWithCredential(credential)
                .then((value) async {
              await verifyBeforeUpdateEmail(user, _emailController.text);
            }).catchError((e) {
              // Handle re-authentication error
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Re-authentication failed. Please try again.')),
              );
            });
          } else {
            await _updateUserProfile(user);
          }
        } else {
          await _updateUserProfile(user);
        }
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
    } finally {
      setState(() {
        islaod = false;
      });
    }
  }

  Future<String> _getUserPassword() async {
    String password = ''; // Store the password

    // Show a dialog to get the user's password
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController passwordController =
            TextEditingController();

        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(hintText: "Password"),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                password = passwordController.text; // Set the password
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    return password; // Return the entered password
  }

  Future<void> _updateUserProfile(User user) async {
    String? profileImageUrl;

    if (imagepic != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profileImages')
          .child('${user.uid}.jpg');
      await storageRef.putFile(File(imagepic!.path));
      profileImageUrl = await storageRef.getDownloadURL();
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userID)
        .update({
      'name': _nameController.text,
      'email': _emailController.text,
      'schoolId': _schoolIdController.text,
      'profileImage': profileImageUrl ?? widget.userProfile,
    });

    // Notify the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  Future<void> verifyBeforeUpdateEmail(User user, String newEmail) async {
    await user.verifyBeforeUpdateEmail(newEmail);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification email sent')),
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userID)
        .update({
      'email': newEmail,
    });
  }
}
