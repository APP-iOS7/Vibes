import 'dart:io';
import 'package:Vibes/model/VideoModel.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerState with ChangeNotifier {
  bool isSongPlaying = false; // 노래 재생 여부
  final AudioPlayer _audioPlayer = AudioPlayer();
  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  AudioPlayer get audioPlayer => _audioPlayer;

  VideoModel? _currentVideo;
  get currentVideo => _currentVideo;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;

  Duration _totalDuration = Duration.zero;
  Duration get totalDuration => _totalDuration;

  /// 현재 재생 중인 인덱스 (플레이리스트 사용 시)
  int? get currentIndex => _audioPlayer.currentIndex;

  AudioPlayerState() {
    // 상태 변화 리스너 등록
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        notifyListeners();
      }
    });

    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });
  }

  /// 오디오 재생
  Future<void> playSoundinFile(
      AudioPlayer audioPlayer, VideoModel video) async {
    // 앱 전용 저장소 경로 가져오기
    var directory = await getApplicationDocumentsDirectory();

    // 읽을 파일 경로
    var filePath = '${directory.path}/${video.videoId}.mp4';

    // 파일 존재 여부 확인
    var file = File(filePath);

    if (await file.exists()) {
      // 오디오 파일을 just_audio로 실행하기( 둘 다 사용하지 못함 하나만 사용해야 합니다)
      // await audioPlayer.setFilePath(file.path);

      _currentVideo = video; // 현재 재생 중인 비디오 설정

      // 로컬 파일 경로를 AudioSource.file로 로드합니다.
      final audioSource = AudioSource.file(
        file.path,
        tag: MediaItem(
          id: _currentVideo?.videoId ?? "없는 음악입니다", // 고유 ID
          album: _currentVideo?.channelName, // 앨범 이름
          title: _currentVideo?.title ?? "알 수 없는 제목입니다", // 곡 제목
          artUri: Uri.parse(
            _currentVideo?.thumbnailUrls!.first.toString() ??
                "이미지가 없습니다", // 앨범 아트 이미지 URL
          ),
        ),
      );

      try {
        await audioPlayer.setAudioSource(audioSource);
        await audioPlayer.play();
        _isPlaying = true; // 재생 상태 업데이트
        notifyListeners();
      } catch (e) {
        print('오디오 파일 재생 중 오류 발생: $e');
      }
    } else {
      print('파일이 존재하지 않습니다.');
    }
  }

  /// 일시정지
  Future<void> audioPlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    _isPlaying = !_isPlaying; // 재생 상태 토글
    notifyListeners();
  }

  /// 플레이리스트 설정
  Future<void> setPlaylist(List<String> filePaths,
      {int initialIndex = 0}) async {
    _playlist = ConcatenatingAudioSource(
      children:
          filePaths.map((path) => AudioSource.uri(Uri.file(path))).toList(),
    );
    await _audioPlayer.setAudioSource(_playlist, initialIndex: initialIndex);
    await _audioPlayer.play();
  }

  /// 해제
  void disposePlayer() async {
    await _audioPlayer.stop();
    await _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: []));
    _isPlaying = false;
    _currentVideo = null;
    isSongPlaying = false; // 하단 재생 바 여부
    notifyListeners();
  }
}
