import 'package:Vibes/services/AudioPlayerState.dart';
import 'package:flutter/material.dart';
import 'package:Vibes/model/VideoModel.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class PlayListTile2 extends StatelessWidget {
  final VideoModel video;
  final bool isEditMode;
  final int? index;

  const PlayListTile2({required this.video, this.isEditMode = false, this.index, super.key});

  // 날짜 포매팅: T와 시간 부분 제거
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    
    // T가 포함된 ISO 8601 형식인 경우 T 이전 부분만 추출
    if (dateString.contains('T')) {
      return dateString.split('T')[0];
    }
    
    return dateString;
  }

  // 조회수 포매팅: 만 단위로 변환
  String _formatViews(String? viewsString) {
    if (viewsString == null || viewsString.isEmpty) return '';
    
    // 콤마 제거 후 숫자로 변환
    String cleanedViews = viewsString.replaceAll(',', '');
    int? views = int.tryParse(cleanedViews);
    
    if (views == null) return viewsString;
    
    if (views >= 100000000) {
      // 1억 이상
      double result = views / 100000000;
      return result % 1 == 0 ? '${result.toInt()}억' : '${result.toStringAsFixed(1)}억';
    } else if (views >= 10000) {
      // 1만 이상
      double result = views / 10000;
      return result % 1 == 0 ? '${result.toInt()}만' : '${result.toStringAsFixed(1)}만';
    } else if (views >= 1000) {
      // 1천 이상
      double result = views / 1000;
      return result % 1 == 0 ? '${result.toInt()}천' : '${result.toStringAsFixed(1)}천';
    }
    
    return views.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: isEditMode ? null : () async {
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
          Text(
            _formatDate(video.uploadDate),
            style: Theme.of(context).listTileTheme.subtitleTextStyle,
          ),
          SizedBox(width: 8.0),
          Text(
            '•',
            style: Theme.of(context).listTileTheme.subtitleTextStyle,
          ),
          SizedBox(width: 8.0),
          Text(
            _formatViews(video.views),
            style: Theme.of(context).listTileTheme.subtitleTextStyle,
          ),
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
      trailing: isEditMode && index != null ? ReorderableDragStartListener(
        index: index!,
        child: Icon(
          Icons.drag_handle,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ) : null,
    );
  }
}
