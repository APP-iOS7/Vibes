import 'package:youtube_scrape_api/models/thumbnail.dart';

class Videomodel {
  /// 유튜브의 주소중 쿼리를 날리고 비디오 재생을 하기 위한 비디오 ID (중요)
  final String? videoId;

  /// 유튜브 총 재생 시간
  final String? duration;

  /// 유튜브 제목
  final String? title;

  /// 해당 영상의 채널 주인
  final String? channelName;

  /// 해당 비디오의 조회 수
  final String? views;

  /// 업로드 된 날짜
  final String? uploadDate;

  /// 영상의 썸네일
  final List<Thumbnail>? thumbnails;

  // 생성자
  Videomodel({
    required this.videoId,
    required this.duration,
    required this.title,
    required this.channelName,
    required this.views,
    required this.uploadDate,
    required this.thumbnails,
  });
}
