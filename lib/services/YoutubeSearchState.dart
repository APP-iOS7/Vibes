import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'package:youtube_scrape_api/youtube_scrape_api.dart';

class Youtubesearchstate extends ChangeNotifier {
  final StreamController<List<Video>> _streamController =
      StreamController.broadcast();
  final YoutubeDataApi youtubeAPI = YoutubeDataApi();

  StreamController<List<Video>> get streamController => _streamController;
  Stream<List<Video>> get searchResult => _streamController.stream;

  Future<void> serachYoutube({required String query}) async {
    if (query.isNotEmpty) {
      List<Video> videoResult = await youtubeAPI.fetchSearchVideo(query);
      for (var element in videoResult) {
        Video video = element;
        print('Video :  $video');
      }

      _streamController.add(videoResult);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
  }
}

/// StreamController는 data가 전달 되기 전까지 값이 StreamBuilder에서 Waiting 상태에 걸려있다는 것을 알았고
/// 그래서 ConnectionState.waiting에 걸리지 않기 위해 입력값을 조건으로 waiting을 넘어가지만 
/// 검색 아이콘을 눌럿을때 searchYoutube함수가 실행이 되더라도 함수내부에는 List<Video>를 먼저 넣고 값을 지정하는 함수입니다.
/// data가 들어오는 시간이 즉시 List<Video>가 들어오는 시간이기 때문에 로딩바가 나타날수가 없음..
/// 그래서 내부 data인 List<Video>를 옵셔널로 바꾸었지만 바로 null safety가 되지 않암..(미해결...)