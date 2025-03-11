import 'package:hive/hive.dart';
import 'package:youtube_scrape_api/models/thumbnail.dart';

part 'VideoModel.g.dart';

@HiveType(typeId: 1)
class VideoModel {
  /// 유튜브의 주소중 쿼리를 날리고 비디오 재생을 하기 위한 비디오 ID (중요)
  @HiveField(0)
  final String? videoId;

  /// 유튜브 총 재생 시간
  @HiveField(1)
  final String? duration;

  /// 유튜브 제목
  @HiveField(2)
  final String? title;

  /// 해당 영상의 채널 주인
  @HiveField(3)
  final String? channelName;

  /// 해당 비디오의 조회 수
  @HiveField(4)
  final String? views;

  /// 업로드 된 날짜
  @HiveField(5)
  final String? uploadDate;

  /// 영상의 썸네일
  @HiveField(6)
  final List<String>? thumbnailUrls;

  /// audio의 저장 경로를 가지고 있어야 합니다
  @HiveField(7)
  String? audioPath;

  // 생성자
  VideoModel({
    required this.videoId,
    required this.duration,
    required this.title,
    required this.channelName,
    required this.views,
    required this.uploadDate,
    required this.thumbnailUrls,
    this.audioPath,
  });
}
