import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social/controller/searchuser.dart';
import 'package:social/views/profile.dart';
import 'package:social/widgets/chatwidget.dart';
import 'package:social/widgets/homeapp.dart';

class ChatSystem extends StatefulWidget {
  const ChatSystem({super.key});

  @override
  State<ChatSystem> createState() => _ChatSystemState();
}

class _ChatSystemState extends State<ChatSystem> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> userFollowingList = [];

  Future<void> _displayfollowing() async {
    try {
      QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('follows')
          .doc(user!.uid)
          .collection('following')
          .get();

      for (var doc in userDocs.docs) {
        String userID = doc.id;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;
          userData!['id'] = userID;
          userFollowingList.add(userData);
        } else {
          debugPrint("No user data found for $userID");
        }
      }

      setState(() {});
    } catch (error) {
      debugPrint("Error fetching data: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _displayfollowing();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>?;
            userData!['id'] = userDoc.id;
          });
        } else {
          debugPrint('No such user data in Firestore');
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 2,
        title: Text(
          "Socials",
          style: GoogleFonts.dancingScript(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 35),
        ),
        actions: [
          HomeAppBar(userData: userData),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchuserForm()));
              },
              icon: const Icon(Icons.search)),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: userFollowingList.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userFollowingList.length,
                  itemBuilder: (context, index) {
                    final user = userFollowingList[index];
                    final userID = user['id'];

                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfile(userID: userID),
                          ),
                        );
                      },
                      trailing: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatWidget(
                                          recieverID: userID,
                                        )));
                          },
                          icon: const Icon(Icons.chat_bubble_outline)),
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(user['profileImage'] ?? ''),
                      ),
                      title: Text(user['name'] ?? 'Unknown'),
                      subtitle: Text(user['email'] ?? 'No email'),
                    );
                  },
                )
              : const Center(
                  child:
                      CircularProgressIndicator()), // Show a loader while data is loading
        ),
      ),
    );
  }
}
