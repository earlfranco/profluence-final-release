// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social/controller/loginForm.dart';
import 'package:social/utils/globaltheme.dart';
import 'package:social/views/chat.dart';
import 'package:social/views/following.dart';
import 'package:social/views/notif.dart';
import 'package:social/views/pap.dart';
import 'package:social/views/profile.dart';
import 'package:social/views/tac.dart';

class DrawerFb1 extends StatefulWidget {
  const DrawerFb1({super.key});

  @override
  State<DrawerFb1> createState() => _DrawerFb1State();
}

class _DrawerFb1State extends State<DrawerFb1> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
            userData = userDoc.data() as Map<String, dynamic>;
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
    return Drawer(
      child: Material(
        color: const Color(0xff4338CA),
        child: Column(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(color: Colors.white),
                    currentAccountPicture: GestureDetector(
                      onTap: () {
                        userData != null
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserProfile(
                                          userID: userData!['id'],
                                        )))
                            : null;
                      },
                      child: CircleAvatar(
                        foregroundImage: NetworkImage(userData != null
                            ? userData!['profileImage']
                            : "https://avatar.iran.liara.run/public "),
                      ),
                    ),
                    accountName: PrimaryText(
                        data: userData != null ? userData!['name'] : ""),
                    accountEmail: PrimaryText(
                      data: userData != null ? userData!['email'] : "",
                    ))

                // DrawerHeader(
                //     decoration: BoxDecoration(color: Colors.white),
                //     child: Column(
                //       children: [
                //         userData != null
                //             ? CircleAvatar(
                //                 foregroundImage:
                //                     NetworkImage(userData!['profileImage']),
                //               )
                //             : Container(),
                //       ],
                //     )),
                ),
            const SizedBox(height: 12),
            MenuItem(
              text: 'Following',
              icon: Icons.people,
              onClicked: () => selectedItem(context, 0),
            ),
            const SizedBox(height: 5),
            MenuItem(
              text: 'Profile',
              icon: Icons.person_outline,
              onClicked: () => selectedItem(context, 1),
            ),
            const SizedBox(height: 5),
            MenuItem(
              text: 'Messages',
              icon: Icons.workspaces_outline,
              onClicked: () => selectedItem(context, 2),
            ),
            const SizedBox(height: 5),
            const SizedBox(height: 8),
            const Divider(color: Colors.white70),
            const SizedBox(height: 8),
            MenuItem(
              text: 'Notifications',
              icon: Icons.notifications_outlined,
              onClicked: () => selectedItem(context, 3),
            ),
            MenuItem(
              text: 'Privacy and Policy',
              icon: Icons.privacy_tip_outlined,
              onClicked: () => selectedItem(context, 6),
            ),
            MenuItem(
              text: 'Terms and Conditions',
              icon: Icons.security_outlined,
              onClicked: () => selectedItem(context, 7),
            ),
            MenuItem(
              text: 'Logout',
              icon: Icons.logout_rounded,
              onClicked: () async {
                final currentuser = FirebaseAuth.instance.currentUser;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentuser!.uid)
                    .update({
                  'isonline': 0,
                }).then((uid) {
                  FirebaseAuth.instance.signOut().then((uid) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginForm()),
                        (Route<dynamic> route) => false);
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();
    switch (index) {
      case 0:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const ShowFollowing(), // Page 1
        ));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => UserProfile(
            userID: FirebaseAuth.instance.currentUser!.uid,
          ), // Page 2
        ));
        break;
      case 2:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const ChatSystem(), // Page 2
        ));
        break;
      case 3:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const ShowNotification(), // Page 2
        ));
        break;
      case 6:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const PrivacyPolicyScreen(), // Page 2
        ));
        break;
      case 7:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const TermsConditionsScreen(), // Page 2
        ));
        break;
    }
  }
}

class MenuItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onClicked;

  const MenuItem({
    required this.text,
    required this.icon,
    this.onClicked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const color = Colors.white;
    const hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }
}

class SearchFieldDrawer extends StatelessWidget {
  const SearchFieldDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const color = Colors.white;

    return TextField(
      readOnly: true,
      style: const TextStyle(color: color, fontSize: 14),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        hintText: 'Search',
        hintStyle: const TextStyle(color: color),
        prefixIcon: const Icon(
          Icons.search,
          color: color,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white12,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: color.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: color.withOpacity(0.7)),
        ),
      ),
    );
  }
}
