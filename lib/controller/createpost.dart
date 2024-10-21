import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social/utils/globaltheme.dart';
import 'package:video_player/video_player.dart';

class CreateUserPost extends StatefulWidget {
  final String userID;
  const CreateUserPost({super.key, required this.userID});

  @override
  State<CreateUserPost> createState() => _CreateUserPostState();
}

class _CreateUserPostState extends State<CreateUserPost> {
  XFile? mediaFile;
  VideoPlayerController? _videoController;
  bool isVideo = false;
  bool isload = false;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _postdes = TextEditingController();
  double _uploadProgress = 0; // To store upload progress percentage

  Future<void> creatpost(String type) async {
    setState(() {
      isload = true;
    });
    if (_postdes.text.isEmpty && mediaFile == null) {
      scaffoldmessenger('Post needs either a description or an image/video');
      setState(() {
        isload = false;
      });
      return;
    }

    String? mediaUrl;
    try {
      if (mediaFile != null) {
        String fileName =
            'posts/${widget.userID}/${DateTime.now().millisecondsSinceEpoch}';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

        UploadTask uploadTask = storageRef.putFile(File(mediaFile!.path));

        // Show upload progress dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Uploading..."),
                  SizedBox(height: 20),
                  CircularProgressIndicator(value: _uploadProgress),
                  SizedBox(height: 10),
                  Text("${(_uploadProgress * 100).toStringAsFixed(2)} %"),
                ],
              ),
            );
          },
        );

        // Listen to the upload progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        });

        // Wait for the upload to complete
        TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});

        // Get the media download URL
        mediaUrl = await storageSnapshot.ref.getDownloadURL();

        // Close the dialog once the upload is done
        Navigator.pop(context);
      }

      await FirebaseFirestore.instance
          .collection('userpost')
          .doc(widget.userID)
          .collection('posts')
          .add({
        'userID': widget.userID,
        'description': _postdes.text,
        'mediaUrl': mediaUrl,
        'mediaType': isVideo ? 'video' : 'image',
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _postdes.clear();
        mediaFile = null;
        isVideo = false;
        isload = false;
        _videoController?.dispose();
      });
      scaffoldmessenger('Post created!');
    } catch (e) {
      debugPrint('Error creating post: $e');
      scaffoldmessenger('Error creating post');
      setState(() {
        isload = false;
      });
      // Close the dialog if there is an error
      Navigator.pop(context);
    }
  }

  void scaffoldmessenger(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Pick Image'),
                onTap: () async {
                  Navigator.pop(context);
                  XFile? imageData =
                      await _imagePicker.pickImage(source: ImageSource.gallery);
                  if (imageData != null) {
                    setState(() {
                      mediaFile = imageData;
                      isVideo = false;
                      _videoController?.dispose();
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Pick Video'),
                onTap: () async {
                  Navigator.pop(context);
                  XFile? videoData =
                      await _imagePicker.pickVideo(source: ImageSource.gallery);
                  if (videoData != null) {
                    setState(() {
                      mediaFile = videoData;
                      isVideo = true;
                      _initializeVideoPlayer(videoData);
                    });
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> _initializeVideoPlayer(XFile videoFile) async {
    _videoController = VideoPlayerController.file(File(videoFile.path))
      ..initialize().then((_) {
        setState(() {}); // Update the UI after the controller is initialized
        _videoController!.setLooping(true); // Enable looping (optional)
        _videoController!.play(); // Autoplay video once it's initialized
      });
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
              onTap: _pickMedia,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 240,
                decoration: mediaFile != null
                    ? BoxDecoration(
                        color: secondColor,
                        image: isVideo
                            ? null
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(File(mediaFile!.path)),
                              ),
                      )
                    : const BoxDecoration(color: secondColor),
                child: Center(
                  child: mediaFile == null
                      ? const PrimaryText(
                          data: "Add Media",
                          fcolor: Colors.white,
                        )
                      : isVideo &&
                              _videoController != null &&
                              _videoController!.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            )
                          : Container(),
                ),
              ),
            ),
            if (isVideo && _videoController != null)
              VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
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
                    hintText: 'What\'s on your mind?',
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
                            isVideo == false
                                ? GlobalButton(
                                    callback: () {
                                      creatpost("story");
                                    },
                                    title: "Story")
                                : Container()
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

  @override
  void dispose() {
    super.dispose();
    _postdes.dispose();
    _videoController?.dispose(); // Dispose the video controller
  }
}
