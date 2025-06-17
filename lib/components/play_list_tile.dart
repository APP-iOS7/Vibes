import 'package:flutter/material.dart';
import 'package:youtube_scrape_api/models/video.dart';

class PlayListTile extends StatelessWidget {
  final Video video;
  const PlayListTile({required this.video, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
      title: Text(video.title!,
          style:
              Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 14)),
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
            child: Image.network(video.thumbnails!.first.url!),
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
