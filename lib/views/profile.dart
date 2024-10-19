import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social/controller/editprofile.dart';
import 'package:social/utils/globaltheme.dart';
import 'package:social/widgets/tabs.dart';

class UserProfile extends StatefulWidget {
  final String userID;
  const UserProfile({super.key, required this.userID});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, dynamic>? userData;
  bool isFollowing = false;
  bool isFriend = false;
  final currentUserID = FirebaseAuth.instance;
  int followerCount = 0;
  int followingCount = 0;
  int numberofpost = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _checkFollowStatus();
    _getFollowerCount();
    _getFollowingCount();
    _getnumberofPost();
  }

  // Fetch the profile user's data from Firestore
  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();

      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> _checkFollowStatus() async {
    try {
      DocumentSnapshot followSnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .doc(currentUserID.currentUser!.uid)
          .collection('following')
          .doc(widget.userID)
          .get();

      DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .doc(widget.userID)
          .collection('following')
          .doc(currentUserID.currentUser!.uid)
          .get();

      setState(() {
        isFollowing = followSnapshot.exists;
        isFriend = followSnapshot.exists && friendSnapshot.exists;
      });
    } catch (e) {
      debugPrint('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow() async {
    try {
      DocumentReference followRef = FirebaseFirestore.instance
          .collection('follows')
          .doc(currentUserID.currentUser!.uid)
          .collection('following')
          .doc(widget.userID);

      if (isFollowing) {
        await followRef.delete();
        setState(() {
          isFollowing = false;
          isFriend = false;
        });
      } else {
        await followRef.set({
          'timestamp': FieldValue.serverTimestamp(),
          'userID': widget.userID
        });
        await FirebaseFirestore.instance
            .collection('follows')
            .doc(widget.userID)
            .collection('followers')
            .add({
          'timestamp': FieldValue.serverTimestamp(),
          'userID': currentUserID.currentUser!.uid
        });

        await FirebaseFirestore.instance
            .collection('notification')
            .doc(widget.userID)
            .collection('notif')
            .add({
          'timestamp': FieldValue.serverTimestamp(),
          'userID': currentUserID.currentUser!.uid
        });
        _checkFollowStatus();
      }
      _getFollowerCount();
      _getFollowingCount();
    } catch (e) {
      debugPrint('Error following/unfollowing user: $e');
    }
  }

  Future<void> _getnumberofPost() async {
    try {
      QuerySnapshot numberofposted = await FirebaseFirestore.instance
          .collection('userpost')
          .doc(widget.userID)
          .collection('posts')
          .get();

      setState(() {
        numberofpost = numberofposted.docs.length;
      });
    } catch (e) {
      debugPrint('Error getting follower count: $e');
    }
  }

  // Function to get the count of followers
  Future<void> _getFollowerCount() async {
    try {
      QuerySnapshot followerSnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .doc(widget.userID)
          .collection('followers')
          .get();

      setState(() {
        followerCount = followerSnapshot.docs.length;
        debugPrint("${followerSnapshot.docs}");
      });
    } catch (e) {
      debugPrint('Error getting follower count: $e');
    }
  }

  Future<void> _getFollowingCount() async {
    try {
      QuerySnapshot followingSnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .doc(widget.userID)
          .collection('following')
          .get();

      setState(() {
        followingCount = followingSnapshot.docs.length;
      });
    } catch (e) {
      debugPrint('Error getting following count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: userData != null
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              maxRadius: 50,
                              backgroundImage:
                                  NetworkImage(userData!['profileImage']),
                            ),
                            Text(
                              (userData!['name'] ?? 'No name')
                                  .split(' ')
                                  .take(2)
                                  .join(' '),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text("$numberofpost"),
                                    const Text("post"),
                                  ],
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  children: [
                                    Text("$followerCount"),
                                    const Text("followers"),
                                  ],
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  children: [
                                    Text("$followingCount"),
                                    const Text("following"),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            widget.userID == currentUserID.currentUser!.uid
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                                width: 1, color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(9))),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditprofilePage(
                                                    userID: currentUserID
                                                        .currentUser!.uid,
                                                    userProfile: userData![
                                                        'profileImage'],
                                                  )));
                                    },
                                    child: const Text(
                                        style: TextStyle(color: Colors.black),
                                        "Edit Profile"),
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: secondColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(9))),
                                    onPressed: _toggleFollow,
                                    child: Text(
                                      style:
                                          const TextStyle(color: Colors.white),
                                      isFriend
                                          ? 'Friends'
                                          : isFollowing
                                              ? 'Following'
                                              : 'Follow',
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: TabBarWidget(
                          ownuserpostid: widget.userID,
                        ))
                    // SizedBox(
                    //     width: MediaQuery.of(context).size.width,
                    //     height: MediaQuery.of(context).size.height * 0.60,
                    //     child: const TabBarAndTabViews())
                  ],
                ),
              ),
            )
          : const LinearProgressIndicator(),
    );
  }
}
