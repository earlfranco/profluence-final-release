// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Widget morevertOption(String id, BuildContext context,
    Map<String, dynamic> postData, String postID) {
  if (id == FirebaseAuth.instance.currentUser?.uid) {
    return PopupMenuButton<int>(
      onSelected: (value) {
        switch (value) {
          case 1:
            updatePost(Navigator.of(context).context, postData, postID);
            debugPrint("Edit clicked");
            break;
          case 2:
            reportOption(Navigator.of(context).context, postData);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: Text("Edit"),
        ),
        const PopupMenuItem(
          value: 2,
          child: Text("Report"),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  } else {
    return PopupMenuButton<int>(
      onSelected: (value) {
        switch (value) {
          case 1:
            reportOption(Navigator.of(context).context, postData);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: Text("Report"),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}

void reportOption(BuildContext context, Map<String, dynamic> postData) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Report Inappropriate Content'),
              onTap: () {
                submitReport(Navigator.of(context).context, postData,
                        'Report Inappropriate Content')
                    .then((_) {
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Report Spam'),
              onTap: () {
                submitReport(
                        Navigator.of(context).context, postData, "Report Spam")
                    .then((_) {
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Report User'),
              onTap: () {
                submitReport(
                        Navigator.of(context).context, postData, "Report User")
                    .then((_) {
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Report Privacy Violation'),
              onTap: () {
                submitReport(Navigator.of(context).context, postData,
                        "Report Privacy Violation")
                    .then((_) {
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> modalMessage(
    String message, BuildContext context, String title) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Continue"),
          ),
        ],
      );
    },
  );
}

Future<void> updatePost(
    BuildContext context, Map<String, dynamic> postData, String postID) async {
  final TextEditingController editDescription = TextEditingController();
  editDescription.text = postData['description'];
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(
          controller: editDescription,
          decoration: const InputDecoration(
            hintText: 'Enter new description',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (editDescription.text.isNotEmpty) {
                editpost(Navigator.of(context).context, postID,
                    editDescription.text);
              }

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

Future<void> editpost(
    BuildContext context, String postId, String description) async {
  final currentuser = FirebaseAuth.instance.currentUser;
  try {
    await FirebaseFirestore.instance
        .collection('userpost')
        .doc(currentuser!.uid)
        .collection('posts')
        .doc(postId)
        .update({
      'description': description,
    });
    await modalMessage(
        "Post Updated", Navigator.of(context).context, "Post Edited");
  } catch (error) {
    await modalMessage("Error, please try again later.",
        Navigator.of(context).context, "Edit Failed");
  }
}

Future<void> submitReport(
    BuildContext context, Map<String, dynamic> postData, String report) async {
  try {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(postData['userID'])
        .collection('report')
        .add({
      'userID': postData['userID'],
      'reporttitle': report,
      'reportcreated': Timestamp.now()
    });
    await modalMessage("$report has been submitted",
        Navigator.of(context).context, "Report Submitted");
  } catch (error) {
    await modalMessage("Error, please try again later.",
        Navigator.of(context).context, "Report Submission Failed");
  }
}
