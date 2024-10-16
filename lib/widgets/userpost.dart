import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social/utils/globaltheme.dart';

class UsersPostFeed extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const UsersPostFeed({super.key, this.userData});

  @override
  State<UsersPostFeed> createState() => _UsersPostFeedState();
}

class _UsersPostFeedState extends State<UsersPostFeed> {
  final TextEditingController usercomment = TextEditingController();
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot> userPosts = [];
  List<Map<String, dynamic>> followedUserData = [];
  Set<String> likedPosts = {};
  bool iscommentopen = false;
  String ispostcomment = "";
  Map<String, int> postLikeCounts = {};
  Set<String> likedComments = {};
  Map<String, int> commentLikeCounts = {};
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
  void dispose() {
    super.dispose();
    usercomment.dispose();
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
                              showBottomsheetcomment(postID);
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

  Future<void> _fetchLikedComments(String postID) async {
    try {
      QuerySnapshot likedCommentSnapshot = await FirebaseFirestore.instance
          .collection('comment')
          .doc(postID)
          .collection('comments')
          .get();

      likedComments.clear();
      commentLikeCounts.clear();

      for (var commentDoc in likedCommentSnapshot.docs) {
        String commentID = commentDoc.id;

        // Fetch if the current user liked this comment
        DocumentSnapshot likedDoc = await FirebaseFirestore.instance
            .collection('likedcomment')
            .doc(commentID)
            .collection('likecomemntcount')
            .doc(currentUserID)
            .get();

        // Check if the current user liked this comment
        if (likedDoc.exists) {
          likedComments.add(commentID);
        }

        // Fetch the total like count for this comment
        QuerySnapshot likeCountSnapshot = await FirebaseFirestore.instance
            .collection('likedcomment')
            .doc(commentID)
            .collection('likecomemntcount')
            .get();

        setState(() {
          commentLikeCounts[commentID] = likeCountSnapshot.docs.length;
        });
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error fetching liked comments: $e');
    }
  }

  Future<void> submitcomment(String postId) async {
    await FirebaseFirestore.instance
        .collection('comment')
        .doc(postId)
        .collection('comments')
        .add({
      'username': widget.userData!['name'],
      'userprofile': widget.userData!['profileImage'],
      'userid': widget.userData!['userid'],
      'postid': postId,
      'comment': usercomment.text,
      'created': Timestamp.now(),
    });
    setState(() {
      usercomment.clear();
    });
  }

  Future<void> addlikecomment(String commentID, String postID) async {
    if (likedComments.contains(commentID)) {
      await FirebaseFirestore.instance
          .collection('likedcomment')
          .doc(commentID)
          .collection('likecomemntcount')
          .doc(currentUserID)
          .delete();
      likedComments.remove(commentID);
    } else {
      // Like the comment
      await FirebaseFirestore.instance
          .collection('likedcomment')
          .doc(commentID)
          .collection('likecomemntcount')
          .doc(currentUserID)
          .set({
        'likes': 1,
        'userid': currentUserID,
      });
      likedComments.add(commentID);
    }

    await _fetchLikedComments(postID);

    setState(() {});
  }

  void showBottomsheetcomment(String postID) {
    _fetchLikedComments(postID);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(
                      children: [
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('comment')
                                .doc(postID)
                                .collection('comments')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const LinearProgressIndicator();
                              } else if (!snapshot.hasData) {
                                return Container();
                              } else {
                                return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      var getcommentdata =
                                          snapshot.data!.docs[index].data();
                                      var commentdataID =
                                          snapshot.data!.docs[index].id;

                                      bool isLiked =
                                          likedComments.contains(commentdataID);
                                      int likeCount =
                                          commentLikeCounts[commentdataID] ?? 0;

                                      return ListTile(
                                        leading: CircleAvatar(
                                          maxRadius: 15,
                                          backgroundImage: NetworkImage(
                                              getcommentdata['userprofile']),
                                        ),
                                        title: Text(
                                          "${getcommentdata['comment']}",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '$likeCount', // Display like count
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                addlikecomment(
                                                    commentdataID, postID);
                                                setState(() {});
                                              },
                                              icon: Icon(
                                                isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_outline,
                                                size: 14,
                                                color:
                                                    isLiked ? Colors.red : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              }
                            }),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    controller: usercomment,
                    decoration: InputDecoration(
                      labelText: 'Write a comment...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: usercomment.text.isNotEmpty
                              ? secondColor
                              : Colors.grey,
                        ),
                        onPressed: () {
                          if (usercomment.text.isNotEmpty) {
                            submitcomment(postID);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
