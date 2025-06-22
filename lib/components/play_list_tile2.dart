import 'package:Vibes/services/AudioPlayerState.dart';
import 'package:flutter/material.dart';
import 'package:Vibes/model/VideoModel.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class PlayListTile2 extends StatelessWidget {
  final VideoModel video;

  const PlayListTile2({required this.video, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        Provider.of<AudioPlayerState>(context, listen: false).isSongPlaying =
            true;
        final player =
            Provider.of<AudioPlayerState>(context, listen: false).audioPlayer;
        final box = Hive.box<VideoModel>('playlist');
        final audio = box.values.firstWhere(
          (v) => v.videoId == video.videoId, // or pass in selected video
          orElse: () => throw Exception('Video not found in playlist'),
        );

        // 플레이어 재생
        Provider.of<AudioPlayerState>(context, listen: false)
            .playSoundinFile(player, audio);
      },
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
