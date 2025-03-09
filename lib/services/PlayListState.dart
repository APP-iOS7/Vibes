import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kls_project/model/VideoModel.dart';
import 'package:kls_project/services/FileServices.dart';

class PlayListState extends ChangeNotifier {
  final Box<VideoModel> _playlistBox = Hive.box<VideoModel>("playlist");
  final List<VideoModel> _playlist = [];

  // 생성자에서 Hive에서 데이터 로드
  PlayListState() {
    _initPlaylist();
  }

  // 초기 실행할 함수
  Future<void> _initPlaylist() async {
    _playlist.clear();
    _playlist.addAll(_playlistBox.values.toList());
    notifyListeners();
  }

  // 모든 플레이리스트 데이터 갱신 CRUD -> Update
  Future<void> refreshPlaylist() async {
    await _initPlaylist();
  }

  // 플레이 리스트에 비디오 객체를 추가하는 코드 CRUD -> Create
  Future<List<VideoModel>> createPlayList(VideoModel video) async {
    _playlist.add(video); // 관리되고 있는 List에 저장

    // HIVE DB에 데이터 저장장
    await _playlistBox.put(video.videoId, video);

    notifyListeners();
    // hive db에 저장
    return _playlist;
  }

  // delete 과정  CRUD -> Delete
  Future<void> deletePlayList(String videoId) async {
    _playlist.removeWhere((element) => element.videoId == videoId);

    //Hive DB에 videoID를 식별자로 사용하여 삭제
    await _playlistBox.delete(videoId);

    // 파일 경로에 있는 mp4 파일 삭제도 해야 합니다.
    await FileServices.instance.deleteVideo(videoId: videoId);
    notifyListeners();
  }

  // get
  List<VideoModel> get playlist => _playlist;
}


/// HIVE DATABASE
/// KEY - VALUE 타입
/// EX) 'playlist' : [VideoModel,VideoModel,VideoModel,VideoModel] 이런 형식식
///