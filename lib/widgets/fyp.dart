import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social/views/photoview.dart';
import 'package:social/views/profile.dart';
import 'package:social/widgets/hashtag.dart';
import 'package:social/widgets/mediaplayer.dart';
import 'package:social/widgets/morevert.dart';
import 'package:social/widgets/viewcomments.dart';

class ForyouPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ForyouPage({super.key, this.userData});

  @override
  State<ForyouPage> createState() => _ForyouPageState();
}

class _ForyouPageState extends State<ForyouPage> {
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot> userPosts = [];
  bool isReposting = false;
  List<Map<String, dynamic>> followedUserData = [];
  Set<String> likedPosts = {};
  bool isCommentOpen = false;
  String isPostComment = "";
  Map<String, int> postLikeCounts = {};
  bool isFollowing = false;
  bool isFriend = false; // This seems like a placeholder for future logic
  @override
  void initState() {
    super.initState();
    _fetchLikedPosts();
  }

  Stream<List<DocumentSnapshot>> _fetchFollowedUsersPosts() async* {
    List<DocumentSnapshot> allUserPosts = [];
    followedUserData = [];
    try {
      QuerySnapshot postSnapshot =
          await FirebaseFirestore.instance.collectionGroup('posts').get();

      allUserPosts.addAll(postSnapshot.docs);

      yield allUserPosts;
    } catch (e) {
      yield [];
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

  Future<void> unfollow(String followingID) async {
    DocumentReference followRef = FirebaseFirestore.instance
        .collection('follows')
        .doc(currentUserID)
        .collection('following')
        .doc(followingID);

    await followRef.delete();
    setState(() {
      _isFollowingUser(followingID);
    });
  }

  Future<void> following(String followingID) async {
    DocumentReference followRef = FirebaseFirestore.instance
        .collection('follows')
        .doc(currentUserID)
        .collection('following')
        .doc(followingID);

    await followRef.set(
        {'timestamp': FieldValue.serverTimestamp(), 'userID': followingID});
    await FirebaseFirestore.instance
        .collection('follows')
        .doc(followingID)
        .collection('followers')
        .add({
      'timestamp': FieldValue.serverTimestamp(),
      'userID': currentUserID
    });

    await FirebaseFirestore.instance
        .collection('notification')
        .doc(followingID)
        .collection('notif')
        .add({
      'timestamp': FieldValue.serverTimestamp(),
      'userID': currentUserID
    });
    setState(() {
      _isFollowingUser(followingID);
    });
  }

  Future<bool> _isFollowingUser(String userIdToCheck) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('follows')
        .doc(currentUserID)
        .collection('following')
        .doc(userIdToCheck)
        .get();

    return doc.exists;
  }

  Future<void> userPostLiked(String postId) async {
    if (likedPosts.contains(postId)) {
      await FirebaseFirestore.instance
          .collection('liked')
          .doc(postId)
          .collection('userslike')
          .doc(currentUserID)
          .delete();
      likedPosts.remove(postId);
    } else {
      await FirebaseFirestore.instance
          .collection('liked')
          .doc(postId)
          .collection('userslike')
          .doc(currentUserID)
          .set({
        'userID': currentUserID,
        'liked': Timestamp.now(),
        'postID': postId,
      });
      likedPosts.add(postId);
    }

    await _fetchLikedPosts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<List<DocumentSnapshot>>(
            stream: _fetchFollowedUsersPosts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: LinearProgressIndicator());
              }

              userPosts = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userPosts.length,
                itemBuilder: (context, index) {
                  var postData =
                      userPosts[index].data() as Map<String, dynamic>;
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
                                  var userData = snapshot.data!.data();
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      UserProfile(
                                                          userID: postData[
                                                              'userID']),
                                                ),
                                              );
                                            },
                                            child: CircleAvatar(
                                              foregroundImage: NetworkImage(
                                                  '${userData!['profileImage']}'),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text("${userData['name']}"),
                                        ],
                                      ),
                                      FutureBuilder<bool>(
                                        future: _isFollowingUser(
                                            postData['userID']),
                                        builder: (context, followSnapshot) {
                                          if (!followSnapshot.hasData) {
                                            return const CircularProgressIndicator(); // Show loading while checking
                                          }

                                          bool isFollowing =
                                              followSnapshot.data!;

                                          return TextButton(
                                            onPressed: () {
                                              if (isFollowing) {
                                                unfollow(postData['userID']);
                                              } else {
                                                following(postData['userID']);
                                              }
                                            },
                                            child: postData['userID'] !=
                                                    currentUserID
                                                ? isFollowing == false
                                                    ? Text(
                                                        postData['userID'] !=
                                                                currentUserID
                                                            ? isFollowing
                                                                ? "Following"
                                                                : "Follow"
                                                            : "",
                                                        style: TextStyle(
                                                          color: isFollowing
                                                              ? Colors.grey
                                                              : Colors.blue,
                                                        ),
                                                      )
                                                    : morevertOption(
                                                        postData['userID'],
                                                        context,
                                                        postData,
                                                        postID)
                                                : Container(),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                }
                              }),
                        ),
                        postData['mediaType'] == 'video'
                            ? MediaPost(mediaUrl: postData['imageUrl'])
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyImageView(
                                          imageUrl: postData['imageUrl']),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 230,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                              postData['imageUrl']))),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(
                              children: buildDescriptionWithHashtags(
                                  postData['description']),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  userPostLiked(postID);
                                },
                                icon: Icon(
                                  likedPosts.contains(postID)
                                      ? Icons.favorite
                                      : Icons.favorite_outline,
                                  color: likedPosts.contains(postID)
                                      ? Colors.red
                                      : null,
                                )),
                            const SizedBox(width: 3),
                            Text(
                              '${postLikeCounts[postID] ?? ''}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    isPostComment = postID;
                                  });
                                  if (isPostComment == postID) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ViewCommentSection(
                                          postID: postID,
                                          userData: widget.userData,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.comment_outlined)),
                            isReposting != true
                                ? IconButton(
                                    onPressed: () {
                                      repostBtn(
                                        '${postData['description']}',
                                        '${postData['imageUrl']}',
                                        'post',
                                        '${postData['userID']}',
                                      );
                                    },
                                    icon: const Icon(Icons.autorenew_outlined))
                                : const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator()),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> repostBtn(
      String des, String imgUrl, String type, String userId) async {
    setState(() {
      isReposting = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('repost')
          .doc(currentUserID)
          .collection('reposted')
          .add({
        'userID': userId,
        'description': des,
        'imageUrl': imgUrl,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        isReposting = false;
      });
    } catch (error) {
      debugPrint("error: $error");
      setState(() {
        isReposting = false;
      });
    }
  }

  void showBottomSheetComment(String postID) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 1.0,
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
