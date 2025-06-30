import 'package:flutter/material.dart';
import 'package:Vibes/model/VideoModel.dart';

class ChartTile extends StatelessWidget {
  final VideoModel video;
  const ChartTile({required this.video, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
      title: Text(
        video.title ?? 'Unknown Title',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 14),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              video.uploadDate ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 5.0),
          Expanded(
            flex: 2,
            child: Text(
              video.views ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      leading: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: video.thumbnailUrls != null && video.thumbnailUrls!.isNotEmpty
                  ? Image.network(
                      video.thumbnailUrls!.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.music_note,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.music_note,
                        color: Colors.grey[600],
                      ),
                    ),
            ),
          ),
          if (video.duration != null)
            Positioned(
              bottom: 3,
              right: 3,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  video.duration!,
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
      trailing: Icon(
        Icons.play_circle_outline,
        color: Theme.of(context).colorScheme.primary,
        size: 32,
      ),
    );
  }
}