import 'package:flutter/material.dart';
import 'package:kls_project/model/VideoModel.dart';

class PlayListState extends ChangeNotifier {
  final List<VideoModel> _playlist = [];

  // 플레이 리스트에 비디오 객체를 추가하는 코드 CRUD -> Create
  Future<List<VideoModel>> createPlayList(VideoModel video) async {
    _playlist.add(video); // 관리되고 있는 List에 저장

    notifyListeners();
    return _playlist;
  }

  // delete 과정  CRUD -> Delete
  Future<void> deletePlayList(String videoId) async {
    _playlist.removeWhere((element) => element.videoId == videoId);
    notifyListeners();
  }

  // get
  List<VideoModel> get playlist => _playlist;
}
