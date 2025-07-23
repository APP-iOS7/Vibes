import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_scrape_api/models/video.dart';
import 'package:youtube_scrape_api/youtube_scrape_api.dart';
import 'package:Vibes/model/VideoModel.dart';
import 'package:Vibes/config/api_config.dart';

class YoutubeMusicChartState extends ChangeNotifier {
  List<VideoModel> _chartVideos = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  
  // YouTube Data API v3 상태
  bool _apiInitialized = false;

  List<VideoModel> get chartVideos => _chartVideos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  YoutubeMusicChartState() {
    _initializeYouTubeApi();
    fetchMusicChart();
    // 10분마다 자동 새로고침 (기존 30분에서 단축)
    _refreshTimer = Timer.periodic(Duration(minutes: 10), (timer) {
      fetchMusicChart();
    });
  }

  void _initializeYouTubeApi() {
    print('🔑 API Key Status: ${ApiConfig.hasYoutubeApiKey}');
    print('🔑 API Key Length: ${ApiConfig.youtubeApiKey.length}');
    print('🔑 API Key Preview: ${ApiConfig.youtubeApiKey.isNotEmpty ? ApiConfig.youtubeApiKey.substring(0, 10) + "..." : "Empty"}');
    
    if (ApiConfig.hasYoutubeApiKey) {
      _apiInitialized = true;
      print('✅ YouTube API initialized successfully');
    } else {
      _apiInitialized = false;
      print('❌ YouTube API initialization failed - no valid API key');
    }
  }

  Future<void> fetchMusicChart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<VideoModel> response;
      
      // YouTube Data API v3가 사용 가능한 경우 우선 사용
      if (_apiInitialized && ApiConfig.hasYoutubeApiKey) {
        response = await _fetchOfficialPopularVideos();
      } else {
        // Fallback: 기존 검색 기반 방식 사용
        response = await _fetchPopularMusicVideos();
      }
      
      _chartVideos = response;
      _error = null;
    } catch (e) {
      _error = '인기차트를 불러오는데 실패했습니다: ${e.toString()}';
      print('Chart fetch error: $e');
      
      // 에러 발생 시 기본 차트 사용
      if (_chartVideos.isEmpty) {
        _chartVideos = _getDefaultChart();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// YouTube Data API v3를 사용한 공식 인기차트 가져오기 (직접 HTTP 호출)
  Future<List<VideoModel>> _fetchOfficialPopularVideos() async {
    if (!ApiConfig.hasYoutubeApiKey) {
      throw Exception('YouTube API key is not available');
    }

    try {
      List<VideoModel> allVideoModels = [];

      // 한국과 글로벌(US) 차트 모두 가져오기
      for (String regionCode in [ApiConfig.defaultRegionCode, ApiConfig.globalRegionCode]) {
        try {
          print('🌍 Fetching $regionCode chart...');
          
          // 직접 HTTP 요청으로 YouTube Data API v3 호출
          final url = Uri.parse(
            '${ApiConfig.youtubeApiBaseUrl}/videos'
            '?part=snippet,statistics,contentDetails'
            '&chart=mostPopular'
            '&regionCode=$regionCode'
            '&videoCategoryId=${ApiConfig.musicCategoryId}'
            '&maxResults=25'
            '&key=${ApiConfig.youtubeApiKey}'
          );
          
          final response = await http.get(url);
          
          if (response.statusCode == 200) {
            final jsonData = json.decode(response.body);
            final items = jsonData['items'] as List?;
            
            print('📊 Received ${items?.length ?? 0} videos from $regionCode');

            if (items != null && items.isNotEmpty) {
              for (final item in items) {
                final videoId = item['id'] as String?;
                final snippet = item['snippet'] as Map<String, dynamic>?;
                final contentDetails = item['contentDetails'] as Map<String, dynamic>?;
                final statistics = item['statistics'] as Map<String, dynamic>?;
                
                if (videoId == null || snippet == null) continue;
                
                // 비디오 시간 파싱
                final durationString = contentDetails?['duration'] as String?;
                final duration = _parseIsoDuration(durationString);
                
                // 10분 이하 음악 비디오만 선택
                if (duration > 0 && duration <= 600) {
                  final title = snippet['title'] as String? ?? '';
                  
                  // 플레이리스트, 믹스 등 필터링
                  if (!_isPlaylistOrMix(title.toLowerCase())) {
                    // 썸네일 URL 추출
                    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>?;
                    final thumbnailUrls = <String>[];
                    if (thumbnails != null) {
                      for (final quality in ['high', 'medium', 'default']) {
                        final thumbnail = thumbnails[quality] as Map<String, dynamic>?;
                        final url = thumbnail?['url'] as String?;
                        if (url != null) thumbnailUrls.add(url);
                      }
                    }
                    
                    allVideoModels.add(VideoModel(
                      videoId: videoId,
                      title: title,
                      channelName: snippet['channelTitle'] as String? ?? '',
                      duration: _formatDuration(duration),
                      views: statistics?['viewCount'] as String? ?? '0',
                      uploadDate: snippet['publishedAt'] as String? ?? '',
                      thumbnailUrls: thumbnailUrls,
                    ));
                  }
                }
              }
            }
          } else {
            print('❌ HTTP Error ${response.statusCode}: ${response.body}');
          }
          
          // API 호출 간 지연
          await Future.delayed(Duration(milliseconds: ApiConfig.apiCallDelay));
        } catch (e) {
          print('Failed to fetch $regionCode chart: $e');
          continue;
        }
      }

      // 중복 제거 (videoId 기준)
      final uniqueVideos = <String, VideoModel>{};
      for (VideoModel video in allVideoModels) {
        if (video.videoId != null && !uniqueVideos.containsKey(video.videoId)) {
          uniqueVideos[video.videoId!] = video;
        }
      }

      final finalVideos = uniqueVideos.values.toList();
      return finalVideos.isNotEmpty ? finalVideos.take(15).toList() : _getDefaultChart(); // 15개로 증가
      
    } catch (e) {
      print('Official API error: $e');
      // API 오류 시 기존 방식으로 fallback
      return await _fetchPopularMusicVideos();
    }
  }

  /// 기존 검색 기반 인기차트 방식 (fallback)
  Future<List<VideoModel>> _fetchPopularMusicVideos() async {
    final YoutubeDataApi youtubeAPI = YoutubeDataApi();
    
    // 글로벌 및 다양한 장르 음악 검색어들 (2025년 업데이트)
    final List<String> popularQueries = [
      // K-pop 및 한국 음악
      'kpop 2025 popular songs',
      'korean music chart 2025',
      'trending music korea',
      
      // 글로벌 트렌드
      'viral songs 2025',
      'global music trends 2025',
      'trending music worldwide',
      'popular music 2025',
      'hot music worldwide',
      
      // 다양한 장르
      'pop music hits 2025',
      'hip hop trending 2025',
      'electronic music viral',
      'indie music popular',
      
      // 바이럴/트렌딩
      'tiktok viral songs',
      'music going viral',
      'trending artists 2025',
    ];

    List<VideoModel> allVideos = [];
    
    for (String query in popularQueries) {
      try {
        List<Video> videos = await youtubeAPI.fetchSearchVideo(query);
        
        // Video를 VideoModel로 변환
        for (Video video in videos.take(8)) { // 각 쿼리당 8개씩 (총 쿼리 16개 * 8 = 128개)
          VideoModel videoModel = VideoModel(
            videoId: video.videoId,
            duration: video.duration,
            title: video.title,
            channelName: video.channelName,
            views: video.views,
            uploadDate: video.uploadDate,
            thumbnailUrls: video.thumbnails?.map((thumbnail) => thumbnail.url ?? '').toList() ?? [],
          );
          allVideos.add(videoModel);
        }
        
        // API 호출 간 대기
        await Future.delayed(Duration(milliseconds: ApiConfig.apiCallDelay));
      } catch (e) {
        print('Failed to fetch videos for query: $query, error: $e');
        continue;
      }
    }

    // 중복 제거 (videoId 기준)
    final uniqueVideos = <String, VideoModel>{};
    for (VideoModel video in allVideos) {
      if (video.videoId != null && !uniqueVideos.containsKey(video.videoId)) {
        uniqueVideos[video.videoId!] = video;
      }
    }

    // 플레이리스트, 믹스 및 시간 필터링
    final filteredVideos = uniqueVideos.values.where((video) {
      final title = video.title?.toLowerCase() ?? '';
      return !_isPlaylistOrMix(title) && _isValidDuration(video.duration);
    }).toList();

    // 결과가 적을 경우 기본 차트 반환
    if (filteredVideos.isEmpty) {
      return _getDefaultChart();
    }

    return filteredVideos.take(15).toList(); // 최대 15개로 증가
  }

  /// ISO 8601 duration을 초로 변환 (PT4M13S -> 253초)
  int _parseIsoDuration(String? isoDuration) {
    if (isoDuration == null || isoDuration.isEmpty) return 0;
    
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);
    
    if (match == null) return 0;
    
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  /// 초를 "MM:SS" 형식으로 변환
  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }


  /// 기존 duration 파싱 로직 (fallback용)
  int _parseDurationToSeconds(String? duration) {
    if (duration == null || duration.isEmpty) return 0;
    
    // "3:45", "1:23:45" 같은 형식 파싱
    final parts = duration.split(':');
    int totalSeconds = 0;
    
    try {
      if (parts.length == 1) {
        // "180" (초만 있는 경우)
        totalSeconds = int.parse(parts[0]);
      } else if (parts.length == 2) {
        // "3:45" (분:초)
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);
        totalSeconds = (minutes * 60) + seconds;
      } else if (parts.length == 3) {
        // "1:23:45" (시:분:초)
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
      }
    } catch (e) {
      // 파싱 실패 시 0 반환
      return 0;
    }
    
    return totalSeconds;
  }

  bool _isValidDuration(String? duration) {
    final totalSeconds = _parseDurationToSeconds(duration);
    // 10분(600초) 이하만 허용
    return totalSeconds > 0 && totalSeconds <= 600;
  }

  bool _isPlaylistOrMix(String title) {
    // 핵심 플레이리스트/믹스 키워드만 필터링 (더 유연한 정책)
    final filterKeywords = [
      'playlist',
      '플레이리스트',
      'mix',
      'compilation',
      '모음집',
      'collection',
      '모음',
      '앨범 전곡',
      'full album',
      'megamix',
      'non-stop',
      'continuous',
      '연속재생',
      'medley',
      'hours of music', // 장시간 음악 모음
      'hour mix', // 시간 단위 믹스
      '시간 연속재생',
    ];

    for (String keyword in filterKeywords) {
      if (title.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  List<VideoModel> _getDefaultChart() {
    // 기본 인기 차트 (API 호출이 모두 실패할 경우)
    return [
      VideoModel(
        videoId: 'dQw4w9WgXcQ',
        title: 'Rick Astley - Never Gonna Give You Up',
        channelName: 'RickAstleyVEVO',
        duration: '3:33',
        views: '1,000,000,000',
        uploadDate: '2009-10-25',
        thumbnailUrls: ['https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg'],
      ),
      VideoModel(
        videoId: 'kJQP7kiw5Fk',
        title: 'Luis Fonsi - Despacito ft. Daddy Yankee',
        channelName: 'LuisFonsiVEVO',
        duration: '4:42',
        views: '8,000,000,000',
        uploadDate: '2017-01-12',
        thumbnailUrls: ['https://img.youtube.com/vi/kJQP7kiw5Fk/hqdefault.jpg'],
      ),
    ];
  }

  Future<void> refreshChart() async {
    await fetchMusicChart();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}