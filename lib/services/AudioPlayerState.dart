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

enum RepeatMode {
  none,    // 전체 한번 듣기
  one,     // 한곡 반복
  all,     // 전체 반복
  oneTime  // 한곡 한번 듣기
}

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
  
  // 현재 플레이리스트 참조 (Context 없이 자동 재생을 위해)
  List<VideoModel> _currentPlaylist = [];
  List<VideoModel> get currentPlaylist => _currentPlaylist;
  // 재생 변수
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  // 반복 모드 변수
  RepeatMode _repeatMode = RepeatMode.none;
  RepeatMode get repeatMode => _repeatMode;

  // 셔플 변수
  bool _isShuffling = false;
  bool get isShuffling => _isShuffling;
  
  // 셔플된 플레이리스트 인덱스 저장
  List<int> _shuffledIndices = [];
  int _shuffleCurrentIndex = 0;

  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;

  Duration _totalDuration = Duration.zero;
  Duration get totalDuration => _totalDuration;

  StreamSubscription<PlayerState>? _playSubscription;

  AudioPlayerState() {
    // 상태 변화 리스너 등록
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      
      // 곡이 완료되었을 때 자동 재생 로직 실행
      if (state.processingState == ProcessingState.completed) {
        _handleSongCompletion();
      }
      
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
  
  // 곡 완료 시 다음 동작을 결정하는 함수
  void _handleSongCompletion() {
    switch (_repeatMode) {
      case RepeatMode.one:
        // 한곡 반복: JustAudio의 LoopMode.one이 자동으로 처리
        break;
      case RepeatMode.oneTime:
        // 한곡 한번 듣기: 재생 정지
        _isPlaying = false;
        break;
      case RepeatMode.none:
        // 전체 한번 듣기: 다음 곡이 있으면 재생, 없으면 정지
        if (_hasNextSongInternal()) {
          _playNextSongAuto();
        } else {
          _isPlaying = false;
        }
        break;
      case RepeatMode.all:
        // 전체 반복: 다음 곡이 있으면 재생, 없으면 처음부터
        if (_hasNextSongInternal()) {
          _playNextSongAuto();
        } else {
          _playFirstSongAuto();
        }
        break;
    }
    notifyListeners();
  }
  
  // 다음 곡이 있는지 확인 (내부 플레이리스트 사용)
  bool _hasNextSongInternal() {
    if (_currentPlaylist.isEmpty || _currentVideo == null) return false;
    
    if (_isShuffling) {
      return _shuffleCurrentIndex < _shuffledIndices.length - 1;
    } else {
      final currentVideoIndex = _currentPlaylist.indexWhere((video) => video.videoId == _currentVideo!.videoId);
      return currentVideoIndex < _currentPlaylist.length - 1 && currentVideoIndex != -1;
    }
  }
  
  // 자동으로 다음 곡 재생 (Context 없이)
  void _playNextSongAuto() {
    if (_currentPlaylist.isEmpty || _currentVideo == null) return;
    
    if (_isShuffling) {
      if (_shuffleCurrentIndex < _shuffledIndices.length - 1) {
        _shuffleCurrentIndex++;
        final nextIndex = _shuffledIndices[_shuffleCurrentIndex];
        _currentVideo = _currentPlaylist[nextIndex];
        playSoundinFile(_audioPlayer, _currentVideo!);
      }
    } else {
      final currentVideoIndex = _currentPlaylist.indexWhere((video) => video.videoId == _currentVideo!.videoId);
      if (currentVideoIndex < _currentPlaylist.length - 1 && currentVideoIndex != -1) {
        _currentIndex = currentVideoIndex + 1;
        _currentVideo = _currentPlaylist[_currentIndex];
        playSoundinFile(_audioPlayer, _currentVideo!);
      }
    }
  }
  
  // 자동으로 첫 번째 곡 재생 (Context 없이)
  void _playFirstSongAuto() {
    if (_currentPlaylist.isEmpty) return;
    
    if (_isShuffling && _shuffledIndices.isNotEmpty) {
      _shuffleCurrentIndex = 0;
      final firstIndex = _shuffledIndices[0];
      _currentVideo = _currentPlaylist[firstIndex];
      playSoundinFile(_audioPlayer, _currentVideo!);
    } else if (_currentPlaylist.isNotEmpty) {
      _currentIndex = 0;
      _currentVideo = _currentPlaylist[0];
      playSoundinFile(_audioPlayer, _currentVideo!);
    }
  }
  
  // 반복 모드를 순환하는 함수
  void toggleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.oneTime;
        break;
      case RepeatMode.oneTime:
        _repeatMode = RepeatMode.none;
        break;
    }
    
    // JustAudio의 LoopMode 설정
    _updateJustAudioLoopMode();
    notifyListeners();
  }
  
  // JustAudio의 LoopMode를 RepeatMode에 맞게 설정
  void _updateJustAudioLoopMode() {
    switch (_repeatMode) {
      case RepeatMode.one:
        // 한곡 반복만 JustAudio의 LoopMode.one 사용
        audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.all:
      case RepeatMode.none:
      case RepeatMode.oneTime:
        // 나머지는 모두 LoopMode.off로 설정하여 수동으로 제어
        audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
  }

  // 셔플 기능의 토글 함수
  void toggleShuffle(BuildContext context) {
    _isShuffling = !_isShuffling;
    
    if (_isShuffling) {
      // 셔플 모드 활성화: Fisher-Yates 알고리즘으로 셔플된 인덱스 생성
      _generateShuffledPlaylist(context);
    } else {
      // 셔플 모드 비활성화: 셔플된 인덱스 초기화
      _shuffledIndices.clear();
      _shuffleCurrentIndex = 0;
    }
    
    notifyListeners();
  }
  
  // Fisher-Yates 알고리즘으로 셔플된 플레이리스트 생성
  void _generateShuffledPlaylist(BuildContext context) {
    // Context에서 플레이리스트 업데이트
    updatePlaylist(context);
    
    final playListCount = _currentPlaylist.length;
    
    // 0부터 playListCount-1까지의 인덱스 배열 생성
    _shuffledIndices = List.generate(playListCount, (index) => index);
    
    // Fisher-Yates 셔플 알고리즘
    final random = Random();
    for (int i = _shuffledIndices.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      int temp = _shuffledIndices[i];
      _shuffledIndices[i] = _shuffledIndices[j];
      _shuffledIndices[j] = temp;
    }
    
    // 현재 재생 중인 곡을 셔플된 리스트의 첫 번째로 이동
    if (_currentVideo != null) {
      final currentVideoIndex = _currentPlaylist.indexWhere((video) => video.videoId == _currentVideo!.videoId);
      
      if (currentVideoIndex != -1) {
        final shuffleIndex = _shuffledIndices.indexOf(currentVideoIndex);
        if (shuffleIndex != -1) {
          // 현재 곡을 맨 앞으로 이동
          _shuffledIndices.removeAt(shuffleIndex);
          _shuffledIndices.insert(0, currentVideoIndex);
          _shuffleCurrentIndex = 0;
        }
      }
    }
  }

  // 플레이리스트 업데이트 (Context로부터)
  void updatePlaylist(BuildContext context) {
    _currentPlaylist = Provider.of<PlayListState>(context, listen: false).playlist;
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
    // 플레이리스트 업데이트 및 currentIndex 넣어주기
    updatePlaylist(context);
    _currentIndex = _currentPlaylist.indexOf(_currentVideo!);
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
    _repeatMode = RepeatMode.none;
    _isShuffling = false;
    _shuffledIndices.clear();
    _shuffleCurrentIndex = 0;
    _currentVideo = null;
    _currentPlaylist.clear();
    isSongPlaying = false; // 하단 재생 바 여부
    _audioPlayer.setLoopMode(LoopMode.off);
    _playSubscription?.cancel();
    await _audioPlayer.stop();
    await _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: []));
    notifyListeners();
  }

  // audio 이전 곡 재생 함수
  void playPreviousSong(BuildContext context) {
    updatePlaylist(context);
    final playlist = _currentPlaylist;
    
    if (_isShuffling) {
      if (_shuffleCurrentIndex > 0) {
        _shuffleCurrentIndex--;
        final prevIndex = _shuffledIndices[_shuffleCurrentIndex];
        _currentVideo = playlist[prevIndex];
        playSoundinFile(_audioPlayer, _currentVideo!);
      }
    } else {
      final currentVideoIndex = playlist.indexWhere((video) => video.videoId == _currentVideo!.videoId);
      if (currentVideoIndex > 0) {
        _currentIndex = currentVideoIndex - 1;
        _currentVideo = playlist[_currentIndex];
        playSoundinFile(_audioPlayer, _currentVideo!);
      }
    }
    notifyListeners();
  }

  // audio 다음 곡 재생 함수
  void playNextSong(BuildContext context) {
    updatePlaylist(context);
    final playlist = _currentPlaylist;
    
    if (_isShuffling) {
      if (_shuffleCurrentIndex < _shuffledIndices.length - 1) {
        _shuffleCurrentIndex++;
        final nextIndex = _shuffledIndices[_shuffleCurrentIndex];
        _currentVideo = playlist[nextIndex];
        playSoundinFile(_audioPlayer, _currentVideo!);
      } else if (_repeatMode == RepeatMode.all) {
        // 전체 반복 모드에서 셔플 리스트의 끝에 도달하면 처음부터
        _shuffleCurrentIndex = 0;
        final firstIndex = _shuffledIndices[0];
        _currentVideo = playlist[firstIndex];
        playSoundinFile(_audioPlayer, _currentVideo!);
      }
    } else {
      final currentVideoIndex = playlist.indexWhere((video) => video.videoId == _currentVideo!.videoId);
      if (currentVideoIndex < playlist.length - 1) {
        _currentIndex = currentVideoIndex + 1;
        _currentVideo = playlist[_currentIndex];
        playSoundinFile(_audioPlayer, _currentVideo!);
      } else if (_repeatMode == RepeatMode.all) {
        // 전체 반복 모드에서 플레이리스트의 끝에 도달하면 처음부터
        _currentIndex = 0;
        _currentVideo = playlist[0];
        playSoundinFile(_audioPlayer, _currentVideo!);
      }
    }
    notifyListeners();
  }

  // Slider bar 컨트롤러 함수
  void sliderControls(Duration duration) {
    _audioPlayer.seek(duration);
    notifyListeners();
  }
}
