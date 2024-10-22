// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:social/controller/videoplayer.dart';
import 'package:social/utils/globaltheme.dart';
import 'package:video_player/video_player.dart';

class MediaPost extends StatefulWidget {
  final String mediaUrl;

  const MediaPost({super.key, required this.mediaUrl});

  @override
  _MediaPostState createState() => _MediaPostState();
}

class _MediaPostState extends State<MediaPost> {
  VideoPlayerController? _videoController;
  bool _isVideo = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkMediaType(widget.mediaUrl);
  }

  Future<void> _checkMediaType(String url) async {
    if (url.contains(".mp4") || url.contains("alt=media")) {
      setState(() {
        _isVideo = true;
      });
      _initializeVideoPlayer(url);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
        _videoController!.setLooping(true);
        _videoController!.play();
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 240,
        color: const Color.fromARGB(96, 158, 158, 158),
      );
    }

    return GestureDetector(
      onTap: () {
        if (_isVideo) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerPage(mediaUrl: widget.mediaUrl),
            ),
          );
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 240,
        decoration: const BoxDecoration(color: secondColor),
        child: _isVideo
            ? _videoController != null && _videoController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                : const Center(child: CircularProgressIndicator())
            : Image.network(
                widget.mediaUrl,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
