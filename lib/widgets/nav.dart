// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social/controller/loginForm.dart';
import 'package:social/views/chat.dart';
import 'package:social/views/following.dart';
import 'package:social/views/notif.dart';
import 'package:social/views/profile.dart';

class DrawerFb1 extends StatelessWidget {
  const DrawerFb1({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: const Color(0xff4338CA),
        child: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
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
                    text: 'Settings',
                    icon: Icons.settings,
                    onClicked: () => selectedItem(context, 6),
                  ),
                  MenuItem(
                    text: 'Logout',
                    icon: Icons.logout_rounded,
                    onClicked: () async {
                      final currentuser = FirebaseAuth.instance.currentUser;
                      await FirebaseFirestore.instance
                          .collection('loginrecord')
                          .doc(currentuser!.uid)
                          .update({
                        'name': currentuser.email,
                        'userid': currentuser.email,
                        'login': 0,
                        'logout': Timestamp.now(),
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
