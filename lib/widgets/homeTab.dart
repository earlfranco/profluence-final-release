// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:social/widgets/fyp.dart';
import 'package:social/widgets/userpost.dart';

class HomeTabBarWidget extends StatelessWidget {
  const HomeTabBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.photo_outlined),
              ),
              Tab(
                icon: Icon(Icons.autorenew_outlined),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          // Wrap TabBarView with Expanded
          Expanded(
            child: TabBarView(
              children: [
                ForyouPage(),
                UsersPostFeed(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
