import 'package:Vibes/model/VideoModel.dart';
import 'package:flutter/material.dart';

class AudioPlayerScreen extends StatefulWidget {
  final VideoModel currentVideo;
  const AudioPlayerScreen({
    required this.currentVideo,
    super.key,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("hello world",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Colors.green)),
    );
  }
}
