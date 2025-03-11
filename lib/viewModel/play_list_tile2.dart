import 'package:flutter/material.dart';
import 'package:kls_project/model/VideoModel.dart';
import 'package:kls_project/services/utils.dart';

class PlayListTile2 extends StatelessWidget {
  final VideoModel video;
  final List<VideoModel> allVideos;
  final int currentIndex;

  const PlayListTile2(
      {required this.video,
      required this.allVideos,
      required this.currentIndex,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => showDetailAudio(
        selectedVideo: video,
        playlist: allVideos,
        initialIndex: currentIndex,
        context: context,
      ),
      title: Text(video.title!,
          style:
              Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16)),
      subtitle: Row(
        children: [
          Text(video.uploadDate!),
          SizedBox(width: 5.0),
          Text(video.views!),
        ],
      ),
      leading: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(video.thumbnailUrls!.first.toString()),
          ),
          Positioned(
            bottom: 3,
            right: 3,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: Colors.grey.shade200.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                video.duration.toString().padLeft(2, "00"),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
