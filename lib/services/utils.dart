import 'package:flutter/material.dart';
import 'package:kls_project/viewModel/youtube_detail.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as explode;
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

// 상세한 비디오 영상과 정보를 가져오고 미리 preview 처럼 보여주는 함수
void showDetailVideo(
    {required scrape.Video selectedVideo, required BuildContext context}) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return Container(
        width: double.infinity,
        height:
            MediaQuery.of(context).size.height - kToolbarHeight, // 앱바 높이만큼 제외
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
