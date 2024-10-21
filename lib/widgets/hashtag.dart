import 'package:flutter/material.dart';

List<TextSpan> buildDescriptionWithHashtags(String? description) {
  if (description == null || description.isEmpty) {
    return [const TextSpan(text: '')];
  }

  final words = description.split(' ');
  final List<TextSpan> spans = [];

  for (var word in words) {
    if (word.startsWith('#')) {
      // If the word starts with '#', treat it as a hashtag and color it blue
      spans.add(
        TextSpan(
          text: '$word ',
          style:
              const TextStyle(color: Colors.blue), // Change color for hashtags
        ),
      );
    } else {
      // Otherwise, add it as normal text
      spans.add(
        TextSpan(
          text: '$word ',
          style: const TextStyle(color: Colors.black), // Normal text color
        ),
      );
    }
  }

  return spans;
}
