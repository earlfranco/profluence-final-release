import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social/utils/globaltheme.dart';
import 'package:social/widgets/viewcomments.dart';

class UsersPostFeed extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const UsersPostFeed({super.key, this.userData});

  @override
  State<UsersPostFeed> createState() => _UsersPostFeedState();
}

class _UsersPostFeedState extends State<UsersPostFeed> {
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot> userPosts = [];
  List<Map<String, dynamic>> followedUserData = [];
  Set<String> likedPosts = {};
  bool iscommentopen = false;
  String ispostcomment = "";
  Map<String, int> postLikeCounts = {};

  @override
  void initState() {
    super.initState();
    _fetchFollowedUsersPosts();
  }

  Future<void> _fetchFollowedUsersPosts() async {
    try {
      QuerySnapshot followingSnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .doc(currentUserID)
          .collection('following')
          .get();

      List<String> followedUserIDs =
          followingSnapshot.docs.map((doc) => doc.id).toList();
      userPosts = [];
      followedUserData = [];

      for (String followedUserID in followedUserIDs) {
        QuerySnapshot postSnapshot = await FirebaseFirestore.instance
            .collection('userpost')
            .doc(followedUserID)
            .collection('posts')
            .get();

        DocumentSnapshot getfolloweduserdata = await FirebaseFirestore.instance
            .collection('users')
            .doc(followedUserID)
            .get();

        userPosts.addAll(postSnapshot.docs);
        followedUserData
            .add(getfolloweduserdata.data() as Map<String, dynamic>);
      }

      await _fetchLikedPosts();

      setState(() {});
    } catch (e) {
      debugPrint('Error fetching posts from followed users: $e');
    }
  }

  Future<void> _fetchLikedPosts() async {
    try {
      QuerySnapshot likedSnapshot =
          await FirebaseFirestore.instance.collectionGroup('userslike').get();
      likedPosts.clear();
      postLikeCounts.clear();

      for (var doc in likedSnapshot.docs) {
        if (doc['userID'] == currentUserID) {
          likedPosts.add(doc['postID'] as String);
        }

        setState(() {
          String postId = doc['postID'];
          postLikeCounts[postId] = (postLikeCounts[postId] ?? 0) + 1;
        });
      }
    } catch (e) {
      debugPrint('Error fetching liked posts: $e');
    }
  }

  Future<void> userpostliked(String postid) async {
    if (likedPosts.contains(postid)) {
      await FirebaseFirestore.instance
          .collection('liked')
          .doc(postid)
          .collection('userslike')
          .doc(currentUserID)
          .delete();
      likedPosts.remove(postid);
    } else {
      await FirebaseFirestore.instance
          .collection('liked')
          .doc(postid)
          .collection('userslike')
          .doc(currentUserID)
          .set({
        'userID': currentUserID,
        'liked': Timestamp.now(),
        'postID': postid,
      });
      likedPosts.add(postid);
    }

    await _fetchLikedPosts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userPosts.length,
          itemBuilder: (context, index) {
            var postData = userPosts[index].data() as Map<String, dynamic>;
            var postID = userPosts[index].id;

            if (postData['type'] != 'story') {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(postData['userID'])
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          } else {
                            var userdata = snapshot.data!.data();
                            return Row(
                              children: [
                                CircleAvatar(
                                  foregroundImage: NetworkImage(
                                      '${userdata!['profileImage']}'),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text("${userdata['name']}")
                              ],
                            );
                          }
                        }),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 230,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(postData['imageUrl']))),
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            userpostliked(postID);
                          },
                          icon: Icon(
                            likedPosts.contains(postID)
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color:
                                likedPosts.contains(postID) ? Colors.red : null,
                          )),
                      const SizedBox(
                        width: 3,
                      ),
                      Text(
                        '${postLikeCounts[postID] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              ispostcomment = postID;
                            });
                            if (ispostcomment == postID) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewCommentSection(
                                            postID: postID,
                                            userData: widget.userData,
                                          )));
                            }
                          },
                          icon: const Icon(Icons.comment_outlined)),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.autorenew_outlined)),
                    ],
                  ),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
      ],
    );
  }

  void showBottomsheetcomment(String postID) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75, // Initial height
          minChildSize: 0.5, // Minimum height
          maxChildSize: 1.0, // Full-screen height
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ViewCommentSection(
                postID: postID,
                userData: widget.userData,
              ),
            );
          },
        );
      },
    );
  }
}
