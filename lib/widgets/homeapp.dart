import 'package:flutter/material.dart';
import 'package:social/controller/createpost.dart';
import 'package:social/utils/globaltheme.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.userData,
  });

  final Map<String, dynamic>? userData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 30,
              height: 30,
              decoration: userData != null
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: secondColor,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage("${userData!['profileImage']}")))
                  : const BoxDecoration(
                      shape: BoxShape.circle,
                      color: secondColor,
                    ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateUserPost(
                            userID: "${userData!['id']}",
                          )));
            },
            child: const Icon(Icons.add),
          )
        ],
      ),
    );
  }
}
