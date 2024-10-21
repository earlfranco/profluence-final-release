import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social/utils/globaltheme.dart';
import 'package:social/views/photoview.dart';

class GetFollowingStory extends StatefulWidget {
  const GetFollowingStory({super.key});

  @override
  State<GetFollowingStory> createState() => _GetFollowingStoryState();
}

class _GetFollowingStoryState extends State<GetFollowingStory> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> getFollowingStories = [];

  Future<void> _displayFollowing() async {
    try {
      QuerySnapshot followingDocs = await FirebaseFirestore.instance
          .collection('follows')
          .doc(user!.uid)
          .collection('following')
          .get();

      for (var doc in followingDocs.docs) {
        String userID = doc.id;

        QuerySnapshot userPostsDoc = await FirebaseFirestore.instance
            .collection('userpost')
            .doc(userID)
            .collection('posts')
            .where('type', isEqualTo: 'story')
            .get();

        if (userPostsDoc.docs.isNotEmpty) {
          for (var postDoc in userPostsDoc.docs) {
            Map<String, dynamic>? postData =
                postDoc.data() as Map<String, dynamic>?;
            if (postData != null) {
              postData['userID'] = userID;
              getFollowingStories.add(postData);
            }
          }
        } else {
          debugPrint("No posts found for user $userID");
        }
      }

      setState(() {}); // Trigger UI update after fetching the data
    } catch (error) {
      debugPrint("Error fetching data: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    _displayFollowing();
  }

  @override
  Widget build(BuildContext context) {
    return getFollowingStories.isEmpty
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: getFollowingStories.isEmpty ? 0 : 80,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: getFollowingStories.length,
                itemBuilder: (context, index) {
                  final story = getFollowingStories[index];
                  if (story['type'] == 'story') {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyImageView(imageUrl: story['imageUrl']),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: secondColor,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                maxRadius: 30,
                                backgroundImage:
                                    NetworkImage(story['imageUrl'] ?? ""),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          );
  }
}
