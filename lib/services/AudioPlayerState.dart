import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:Vibes/model/VideoModel.dart';
import 'package:Vibes/services/PlayListState.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class AudioPlayerState with ChangeNotifier {
  /// 현재 재생 중인 인덱스 (플레이리스트 사용 시)
  late int _currentIndex;
  int get currentIndex => _currentIndex;

  bool isSongPlaying = false; // 노래 재생 여부
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: []);
  get playList => _playlist;
  AudioPlayer get audioPlayer => _audioPlayer;

  VideoModel? _currentVideo;
  get currentVideo => _currentVideo;
  // 재생 변수
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  // 루프 변수
  bool _isLooping = false;
  bool get isLooping => _isLooping;

  // 셔플 변수
  bool _isShuffling = false;
  bool get isShuffling => _isShuffling;

  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;

  Duration _totalDuration = Duration.zero;
  Duration get totalDuration => _totalDuration;

  StreamSubscription<PlayerState>? _playSubscription;

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
  // loop 할지를 토글 하는 함수 및 LoopMode
  void loopSet() {
    _isLooping = !_isLooping;
    if (_isLooping) {
      // 셔플 켜져 있으면 끄기
      if (_isShuffling) {
        _isShuffling = false;
        _playSubscription?.cancel();
      }

      audioPlayer.setLoopMode(LoopMode.one);
    } else {
      audioPlayer.setLoopMode(LoopMode.off);
    }
    notifyListeners();
  }

  // 셔플 기능의 토글 함수
  void shuffleSet(BuildContext context) {
    _isShuffling = !_isShuffling;
    if (_isShuffling) {
      // 루프 켜져 있으면 끄기
      if (_isLooping) {
        _isLooping = false;
        audioPlayer.setLoopMode(LoopMode.off);
      }

      // 총 노래의 개수
      final playListCount =
          Provider.of<PlayListState>(context, listen: false).playlist.length;
      // playList의 length만큼 배열을 생성
      final shuffleList = List.generate(
          playListCount,
          (index) => Provider.of<PlayListState>(context, listen: false)
              .playlist[index]);

      // 혹시 있으면 없애고 listen 생성
      _playSubscription?.cancel();
      _playSubscription = _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          //  shuffleList 랜덤 돌리기
          final randomIndex = Random().nextInt(shuffleList.length);
          final selectedMusic = shuffleList[randomIndex];

          // 곡이 끝났을 때
          playSoundinFile(_audioPlayer, selectedMusic);
        }
      });
    } else {
      _playSubscription?.cancel();
    }
    notifyListeners();
  }

  /// 오디오 재생
  Future<void> playSoundinFile(
      AudioPlayer audioPlayer, VideoModel video) async {
    // 앱 전용 저장소 경로 가져오기
    var directory = await getApplicationDocumentsDirectory();

    // 읽을 파일 경로
    var filePath = '${directory.path}/${video.videoId}.mp3';

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

  void getCurrentIndex(BuildContext context) {
    // currentIndex 넣어주기
    _currentIndex = Provider.of<PlayListState>(context, listen: false)
        .playlist
        .indexOf(_currentVideo!);
  }

  // 재생 및 일시 정지
  Future<void> audioPlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    _isPlaying = !_isPlaying; // 재생 상태 토글
    notifyListeners();
  }

  /// 해제
  void disposePlayer() async {
    _isPlaying = false;
    _isLooping = false;
    _isShuffling = false;
    _currentVideo = null;
    isSongPlaying = false; // 하단 재생 바 여부
    _audioPlayer.setLoopMode(LoopMode.off);
    _playSubscription?.cancel();
    await _audioPlayer.stop();
    await _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: []));
    notifyListeners();
  }

  // audio 뒤로가기 함수
  void playPreviousSong(BuildContext context) {
    if (_currentIndex > 0) {
      _currentIndex--;
      final video = Provider.of<PlayListState>(context, listen: false)
          .playlist[currentIndex];
      _currentVideo = video;
    }

    playSoundinFile(_audioPlayer, _currentVideo!);
    notifyListeners();
  }

  // audio 앞으로 가기 함수
  void playNextSong(BuildContext context) {
    final maxPlayList =
        Provider.of<PlayListState>(context, listen: false).playlist.length;
    if (_currentIndex < maxPlayList - 1) {
      _currentIndex++;
      final video = Provider.of<PlayListState>(context, listen: false)
          .playlist[currentIndex];
      _currentVideo = video;
    } else {
      return;
    }
    playSoundinFile(_audioPlayer, _currentVideo!);
    notifyListeners();
  }

  // Slider bar 컨트롤러 함수
  void sliderControls(Duration duration) {
    _audioPlayer.seek(duration);
    notifyListeners();
  }
}
