import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // YouTube Data API v3 설정
  static String get youtubeApiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';
  
  // API 키가 설정되어 있는지 확인
  static bool get hasYoutubeApiKey => youtubeApiKey.isNotEmpty && youtubeApiKey != 'your_youtube_api_key_here';
  
  // YouTube Data API v3 기본 설정
  static const String youtubeApiBaseUrl = 'https://www.googleapis.com/youtube/v3';
  
  // 요청 제한 설정
  static const int maxResults = 50;
  static const int apiCallDelay = 300; // milliseconds
  
  // 지역 및 카테고리 설정
  static const String defaultRegionCode = 'KR'; // 한국
  static const String globalRegionCode = 'US'; // 글로벌 (미국 기준)
  static const String musicCategoryId = '10'; // 음악 카테고리
  
  // 지역별 차트 지원
  static const List<String> supportedRegions = ['KR', 'US', 'GB', 'JP'];
  static const Map<String, String> regionNames = {
    'KR': '한국',
    'US': '글로벌',
    'GB': '영국',
    'JP': '일본',
  };
  
  // 에러 메시지
  static const String noApiKeyError = 'YouTube API 키가 설정되지 않았습니다.';
  static const String apiQuotaExceededError = 'YouTube API 할당량이 초과되었습니다.';
  static const String networkError = '네트워크 연결에 문제가 있습니다.';
}