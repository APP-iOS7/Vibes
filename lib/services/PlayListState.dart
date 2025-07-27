import 'package:Vibes/services/AudioPlayerState.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:Vibes/model/VideoModel.dart';
import 'package:Vibes/services/FileServices.dart';
import 'package:provider/provider.dart';

class PlayListState extends ChangeNotifier {
  final Box<VideoModel> _playlistBox = Hive.box<VideoModel>("playlist");
  final List<VideoModel> _playlist = [];
  
  // 싱글톤 인스턴스를 위한 정적 변수
  static PlayListState? _instance;

  // 생성자에서 Hive에서 데이터 로드
  PlayListState() {
    // 싱글톤 인스턴스 설정
    _instance = this;
    // 즉시 동기 데이터 로드
    _loadPlaylistSync();
    // 비동기 초기화는 별도로 실행
    _initPlaylistAsync();
  }
  
  // 싱글톤 인스턴스 접근자
  static PlayListState? get instance => _instance;

  // 동기적으로 데이터 로드 (UI 즉시 업데이트용)
  void _loadPlaylistSync() {
    _playlist.clear();
    final videos = _playlistBox.values.toList();
    _playlist.addAll(videos);
    // 즉시 UI 업데이트
    notifyListeners();
    print('[PlayListState] Sync loaded ${_playlist.length} videos');
  }
  
  // 비동기 초기화 (정렬 처리)
  Future<void> _initPlaylistAsync() async {
    try {
      final videos = _playlistBox.values.toList();
      
      // playlistOrder에 따라 정렬, null인 경우 맨 뒤로
      videos.sort((a, b) {
        if (a.playlistOrder == null && b.playlistOrder == null) return 0;
        if (a.playlistOrder == null) return 1;
        if (b.playlistOrder == null) return -1;
        return a.playlistOrder!.compareTo(b.playlistOrder!);
      });
      
      _playlist.clear();
      _playlist.addAll(videos);
      notifyListeners();
      print('[PlayListState] Async sorted ${_playlist.length} videos');
    } catch (e) {
      print('[PlayListState] Error in async init: $e');
    }
  }
  

  // 모든 플레이리스트 데이터 갱신 CRUD -> Update
  Future<void> refreshPlaylist() async {
    _loadPlaylistSync(); // 즉시 동기 로드
    await _initPlaylistAsync(); // 이후 비동기 정렬
  }

  // 특정 비디오의 정보를 업데이트하는 메서드 추가
  Future<void> updateVideoModel(VideoModel updatedVideo) async {
    // 메모리에서 업데이트
    final index = _playlist.indexWhere((video) => video.videoId == updatedVideo.videoId);
    if (index != -1) {
      _playlist[index] = updatedVideo;
    }

    // Hive DB에 업데이트
    await _playlistBox.put(updatedVideo.videoId, updatedVideo);
    
    notifyListeners();
    print('[PlayListState] Updated VideoModel: ${updatedVideo.title} with downloadDate: ${updatedVideo.downloadDate}');
  }

  // 플레이 리스트에 비디오 객체를 추가하는 코드 CRUD -> Create
  Future<List<VideoModel>> createPlayList(VideoModel video) async {
    // 새 비디오에 playlistOrder 설정 (맨 마지막 순서)
    final videoWithOrder = VideoModel(
      videoId: video.videoId,
      duration: video.duration,
      title: video.title,
      channelName: video.channelName,
      views: video.views,
      uploadDate: video.uploadDate,
      thumbnailUrls: video.thumbnailUrls,
      audioPath: video.audioPath,
      downloadDate: video.downloadDate,
      playlistOrder: _playlist.length,
    );
    
    _playlist.add(videoWithOrder); // 관리되고 있는 List에 저장

    // HIVE DB에 데이터 저장장
    await _playlistBox.put(videoWithOrder.videoId, videoWithOrder);

    notifyListeners();
    // hive db에 저장
    return _playlist;
  }

  // delete 과정  CRUD -> Delete
  Future<void> deletePlayList(BuildContext context, String videoId) async {
    final VideoModel? currentVideo =
        Provider.of<AudioPlayerState>(context, listen: false).currentVideo;
    // 삭제시 해당 음악이 틀어져 있다면 종료
    if (currentVideo != null && currentVideo.videoId == videoId) {
      Provider.of<AudioPlayerState>(context, listen: false).disposePlayer();
    }

    _playlist.removeWhere((element) => element.videoId == videoId);

    //Hive DB에 videoID를 식별자로 사용하여 삭제
    await _playlistBox.delete(videoId);

    // 파일 경로에 있는 mp3 파일 삭제도 해야 합니다.
    await FileServices.instance.deleteVideo(videoId: videoId);
    notifyListeners();
  }

  // 플레이리스트 순서 재조정 메서드
  Future<void> reorderPlaylist(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final VideoModel item = _playlist.removeAt(oldIndex);
    _playlist.insert(newIndex, item);
    
    // 모든 비디오의 playlistOrder 업데이트
    for (int i = 0; i < _playlist.length; i++) {
      _playlist[i] = VideoModel(
        videoId: _playlist[i].videoId,
        duration: _playlist[i].duration,
        title: _playlist[i].title,
        channelName: _playlist[i].channelName,
        views: _playlist[i].views,
        uploadDate: _playlist[i].uploadDate,
        thumbnailUrls: _playlist[i].thumbnailUrls,
        audioPath: _playlist[i].audioPath,
        downloadDate: _playlist[i].downloadDate,
        playlistOrder: i,
      );
      
      // Hive DB에 업데이트된 순서 저장
      await _playlistBox.put(_playlist[i].videoId, _playlist[i]);
    }
    
    notifyListeners();
  }

  // get
  List<VideoModel> get playlist => _playlist;
}


/// HIVE DATABASE
/// KEY - VALUE 타입
/// EX) 'playlist' : [VideoModel,VideoModel,VideoModel,VideoModel] 이런 형식식
///