import 'package:flutter/material.dart';
import 'package:social/widgets/ownpost.dart';
import 'package:social/widgets/repost.dart';

class TabBarWidget extends StatelessWidget {
  final String ownuserpostid;
  const TabBarWidget({super.key, required this.ownuserpostid});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.photo_outlined),
              ),
              Tab(
                icon: Icon(Icons.autorenew_outlined),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          // Wrap TabBarView with Expanded
          Expanded(
            child: TabBarView(
              children: [
                OwnUsersPostFeed(
                  ownpostID: ownuserpostid,
                ),
                OwnReposted(
                  ownpostID: ownuserpostid,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
