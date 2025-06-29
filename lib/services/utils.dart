import 'package:Vibes/model/VideoModel.dart';
import 'package:Vibes/screen/audioPlayerScreen.dart';
import 'package:flutter/material.dart';
import 'package:Vibes/components/youtube_detail.dart';
import 'package:youtube_scrape_api/models/thumbnail.dart';
import 'package:youtube_scrape_api/models/video.dart' as scrape;

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String hours = twoDigits(duration.inHours);
  String minutes = twoDigits(duration.inMinutes.remainder(60));
  String seconds = twoDigits(duration.inSeconds.remainder(60));

  // hour 가 없다면 다른 포멧을 리턴
  if (hours == "00") {
    return "$minutes:$seconds";
  } else {
    return "$hours:$minutes:$seconds";
  }
}

Duration parseDuration(String duration) {
  List<String> parts = duration.split(':'); // "mm:ss" → ["mm", "ss"]

  if (parts.length == 1) {
    return Duration(seconds: int.parse(duration));
  } else if (parts.length == 2) {
    int minutes = int.tryParse(parts[0]) ?? 0;
    int seconds = int.tryParse(parts[1]) ?? 0;
    return Duration(minutes: minutes, seconds: seconds);
  } else if (parts.length == 3) {
    int hours = int.tryParse(parts[0]) ?? 0;
    int minutes = int.tryParse(parts[1]) ?? 0;
    int seconds = int.tryParse(parts[2]) ?? 0;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
  return Duration.zero; // 변환 실패 시 기본값
}

// 상세한 오디오 정보를 가져오고 음악을 실제로 듣는 View 입니다.
void showDetailAudio({
  required VideoModel selectedVideo,
  required BuildContext context,
  List<VideoModel>? playlist,
}) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height, // 앱바 높이만큼 제외
        color: Theme.of(context).colorScheme.surface,
        child: AudioPlayerScreen(),
      );
    },
  );
}

// 상세한 비디오 영상과 정보를 가져오고 미리 preview 처럼 보여주는 함수
void showDetailVideo(
    {required scrape.Video selectedVideo, required BuildContext context}) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: YoutubeDetailView(detailVideo: selectedVideo),
      );
    },
  );
}

// Thumnail 직렬화 함수
List<String> convertThumnailURL(List<Thumbnail> data) {
  return data.map((thumnail) => thumnail.url.toString()).toList();
}
