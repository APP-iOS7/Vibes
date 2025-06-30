import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'package:youtube_scrape_api/youtube_scrape_api.dart';
import 'package:Vibes/model/VideoModel.dart';

class YoutubeMusicChartState extends ChangeNotifier {
  List<VideoModel> _chartVideos = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

  List<VideoModel> get chartVideos => _chartVideos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  YoutubeMusicChartState() {
    fetchMusicChart();
    // 30분마다 자동 새로고침
    _refreshTimer = Timer.periodic(Duration(minutes: 30), (timer) {
      fetchMusicChart();
    });
  }

  Future<void> fetchMusicChart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // youtube_scrape_api를 사용하여 인기 음악 검색
      final response = await _fetchPopularMusicVideos();
      
      _chartVideos = response;
      _error = null;
    } catch (e) {
      _error = '인기차트를 불러오는데 실패했습니다: ${e.toString()}';
      print('Chart fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<VideoModel>> _fetchPopularMusicVideos() async {
    final YoutubeDataApi youtubeAPI = YoutubeDataApi();
    
    // 인기 K-pop 및 음악 검색어들
    final List<String> popularQueries = [
      'kpop 2024 popular songs',
      'korean music chart 2024',
      'trending music korea',
      'popular music videos',
      'hot music 2024',
    ];

    List<VideoModel> allVideos = [];
    
    for (String query in popularQueries) {
      try {
        List<Video> videos = await youtubeAPI.fetchSearchVideo(query);
        
        // Video를 VideoModel로 변환
        for (Video video in videos.take(15)) { // 각 쿼리당 15개씩 (필터링을 고려해서 더 많이)
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
        
        // 너무 많은 API 호출을 방지하기 위해 잠시 대기
        await Future.delayed(Duration(milliseconds: 500));
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

    return filteredVideos.take(10).toList(); // 최대 10개
  }


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
    // 플레이리스트 및 믹스 관련 키워드들
    final filterKeywords = [
      'playlist',
      '플레이리스트',
      'mix',
      'compilation',
      '모음집',
      'best of',
      'top songs',
      'greatest hits',
      'collection',
      '모음',
      '컬렉션',
      'album',
      '앨범 전곡',
      'full album',
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