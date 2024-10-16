import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MyImageView extends StatelessWidget {
  final String imageUrl;

  const MyImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text("Image View"),
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        heroAttributes: const PhotoViewHeroAttributes(tag: "imageHero"),
      ),
    );
  }
}

// Example usage of MyImageView
class MyHomePage extends StatelessWidget {
  final Map<String, dynamic> postData;

  const MyHomePage({super.key, required this.postData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Posts"),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            // Navigate to MyImageView when the image is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MyImageView(imageUrl: postData['imageUrl']),
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 230,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(postData['imageUrl']),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
