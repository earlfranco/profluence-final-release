import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social/utils/globaltheme.dart';

class CreateUserPost extends StatefulWidget {
  final String userID;
  const CreateUserPost({super.key, required this.userID});

  @override
  State<CreateUserPost> createState() => _CreateUserPostState();
}

class _CreateUserPostState extends State<CreateUserPost> {
  XFile? imagepic;
  bool isload = false;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _postdes = TextEditingController();

  Future<void> creatpost(String type) async {
    setState(() {
      isload = true;
    });
    if (_postdes.text.isEmpty && imagepic == null) {
      scaffoldmessenger('Post needs either a description or an image');

      return;
    }

    String? imageUrl;
    try {
      if (imagepic != null) {
        String fileName =
            'posts/${widget.userID}/${DateTime.now().millisecondsSinceEpoch}';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(File(imagepic!.path));
        TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
        imageUrl = await storageSnapshot.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('userpost')
          .doc(widget.userID)
          .collection('posts')
          .add({
        'userID': widget.userID,
        'description': _postdes.text,
        'imageUrl': imageUrl,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _postdes.clear();
        imagepic = null;
        isload = false;
      });
      scaffoldmessenger('Post created!');
    } catch (e) {
      debugPrint('Error creating post: $e');
      scaffoldmessenger('Error creating post');
    }
  }

  void scaffoldmessenger(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: secondColor,
        automaticallyImplyLeading: true,
        title: const PrimaryText(
          data: "Create Post",
          fcolor: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 240,
                decoration: imagepic != null
                    ? BoxDecoration(
                        color: secondColor,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(File(imagepic!.path))))
                    : const BoxDecoration(color: secondColor),
                child: Center(
                  child: imagepic == null
                      ? const PrimaryText(
                          data: "Add Photo",
                          fcolor: Colors.white,
                        )
                      : Container(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  maxLines: 20,
                  minLines: 13,
                  textAlign: TextAlign.start,
                  controller: _postdes,
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    hintText: 'Whats on your mind ?',
                    labelStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  isload != true
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GlobalButton(
                                callback: () {
                                  creatpost("post");
                                },
                                title: "Post"),
                            const SizedBox(
                              width: 10,
                            ),
                            GlobalButton(
                                callback: () {
                                  creatpost("story");
                                },
                                title: "Story")
                          ],
                        )
                      : const CircularProgressIndicator()
                ],
              ),
            )
          ],
        ),
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

  @override
  void dispose() {
    super.dispose();
    _postdes.dispose();
  }
}
