import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social/controller/searchuser.dart';
import 'package:social/widgets/fyp.dart';
import 'package:social/widgets/homeapp.dart';
import 'package:social/widgets/nav.dart';
import 'package:social/widgets/userpost.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final drawerkey = GlobalKey<ScaffoldState>();
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
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        drawer: const DrawerFb1(),
        appBar: AppBar(
          titleSpacing: 2,
          title: Text(
            "Profluence",
            style: GoogleFonts.dancingScript(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 35,
            ),
          ),
          actions: [
            HomeAppBar(userData: userData),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchuserForm(),
                  ),
                );
              },
              icon: const Icon(Icons.search),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'For you'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: userData != null
            ? RefreshIndicator(
                onRefresh: () async {
                  setState(() {}); // Trigger refresh
                },
                child: const TabBarView(
                  children: [
                    ForyouPage(),
                    UsersPostFeed(),
                  ],
                ),
              )
            : const LinearProgressIndicator(),
      ),
    );
  }
}
