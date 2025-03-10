import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kls_project/model/VideoModel.dart';
import 'package:kls_project/services/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kls_project/viewModel/play_list_tile2.dart';

// 오디오를 자세하게 보여주며 실행하는 스크린 입니다.
class AudioPlayScreen extends StatefulWidget {
  final VideoModel videoModel;
  final List<VideoModel>? playlist; // 플레이리스트 추가 (선택적)
  final int initialIndex; // 초기 인덱스 추가

  const AudioPlayScreen({
    required this.videoModel,
    this.playlist,
    this.initialIndex = 0,
    super.key,
  });

  @override
  State<AudioPlayScreen> createState() => _AudioPlayScreenState();
}

Future<void> playSoundinFile(
    {required AudioPlayer audioPlayer, required VideoModel video}) async {
  // 앱 전용 저장소 경로 가져오기
  var directory = await getApplicationDocumentsDirectory();

  // 읽을 파일 경로
  var filePath = '${directory.path}/${video.videoId}.mp4';

  // 파일 존재 여부 확인
  var file = File(filePath);

  if (await file.exists()) {
    // 오디오 파일을 just_audio로 실행하기( 둘 다 사용하지 못함 하나만 사용해야 합니다)
    // await audioPlayer.setFilePath(file.path);

    // 로컬 파일 경로를 AudioSource.file로 로드합니다.
    final audioSource = AudioSource.file(
      file.path,
      tag: MediaItem(
        id: video.videoId!, // 고유 ID
        album: video.channelName, // 앨범 이름
        title: video.title!, // 곡 제목
        artUri: Uri.parse(video.thumbnailUrls!.first.toString()), // 앨범 아트 이미지
      ),
    );

    await audioPlayer.setAudioSource(audioSource);

    await audioPlayer.play();
  } else {
    print('파일이 존재하지 않습니다.');
  }
}

class _AudioPlayScreenState extends State<AudioPlayScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = true;
  bool isLooping = false;
  bool isShuffling = false; // 셔플 모드 상태 추가
  // 현재 위치를 추적하기 위한 변수
  Duration _currentPosition = Duration.zero;

  // 플레이리스트 관련 변수
  late List<VideoModel> _playlist;
  late List<VideoModel> _originalPlaylist; // 원본 플레이리스트 저장
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    // 플레이리스트 초기화
    if (widget.playlist != null && widget.playlist!.isNotEmpty) {
      _playlist = List.from(widget.playlist!); // 복사본 생성
      _originalPlaylist = List.from(widget.playlist!); // 원본 저장
      _currentIndex = widget.initialIndex;
    } else {
      // 플레이리스트가 없으면 현재 곡만 포함
      _playlist = [widget.videoModel];
      _originalPlaylist = [widget.videoModel];
      _currentIndex = 0;
    }
    // 오디오 플레이어 초기화
    audioPlayer.setLoopMode(LoopMode.off);
    playSoundinFile(audioPlayer: audioPlayer, video: _playlist[_currentIndex]);

    // 위치 스트림 리스너 설정
    audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });

      // 현재 위치가 곡의 끝에 가까운지 확인 (99% 이상)
      final totalDuration = parseDuration(_playlist[_currentIndex].duration!);
      if (position.inMilliseconds >= totalDuration.inMilliseconds * 0.99) {
        // 곡의 끝에 가까운 위치이고, 반복 모드가 켜져 있다면
        if (isLooping) {
          print("곡의 끝에 도달하고 반복 모드가 켜져 있어 처음으로 돌아갑니다.");

          setState(() {
            // ProgressBar 초기화를 위해 _currentPosition 설정
            _currentPosition = Duration.zero;
          });

          // 오디오 플레이어 위치 초기화 및 재생
          audioPlayer.seek(Duration.zero).then((_) {
            audioPlayer.play();
          });
        }
      }
    });

    // 플레이어 상태 스트림 리스너 설정
    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        if (isLooping) {
          // 반복 재생 시 처음부터 다시 재생
          setState(() {
            _currentPosition = Duration.zero;
          });
          // 약간의 지연 후 오디오 재생 (UI 업데이트 후)
          Future.delayed(Duration(milliseconds: 50), () {
            audioPlayer.seek(Duration.zero).then((_) {
              audioPlayer.play();
            });
          });
        }
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 재생 중인 비디오 모델 가져오기
    final currentVideo = _playlist[_currentIndex];

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding:
              EdgeInsets.symmetric(vertical: kToolbarHeight, horizontal: 10),
          child: Column(
            children: [
              _topAppBarTitle(context),
              Expanded(child: _thumnailContent(currentVideo)), // 현재 비디오 전달
              _mainTitle(context, currentVideo), // 현재 비디오 전달
              SizedBox(height: 8),
              _channelNameView(context, currentVideo), // 현재 비디오 전달
              _audioSlider(context, currentVideo), // 현재 비디오 전달
              _playAudioBox(context)
            ],
          ),
        ),
      ),
    );
  }

  // 맨 위 부분 제목
  Stack _topAppBarTitle(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "KLS PLAYER",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        Positioned(
          bottom: -5,
          child: Icon(Icons.keyboard_arrow_down_rounded, size: 35),
        ),
      ],
    );
  }

  // 썸네일 이미지 부분 (현재 비디오 사용)
  Container _thumnailContent(VideoModel video) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          video.thumbnailUrls!.first.toString(),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // 메인 텍스트 뷰 (현재 비디오 사용)
  Text _mainTitle(BuildContext context, VideoModel video) {
    return Text(
      video.title.toString(),
      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16),
    );
  }

  // 채널 이름 (현재 비디오 사용)
  Row _channelNameView(BuildContext context, VideoModel video) {
    return Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            video.channelName!,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  // audio duration Slider 뷰 (현재 비디오 사용)
  SliderTheme _audioSlider(BuildContext context, VideoModel video) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Theme.of(context).colorScheme.primary, // 진행된 트랙 색상
        inactiveTrackColor:
            Theme.of(context).colorScheme.secondary, // 진행되지 않은 트랙 색상
        trackHeight: 6.0, // 트랙 높이
        thumbColor: Theme.of(context).colorScheme.primary, // 썸(버튼) 색상
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 3.0), // 썸 크기 조절
      ),
      child: StreamBuilder(
        stream: audioPlayer.positionStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text("기다려주세요 >.<"));
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ProgressBar(
                      progress: snapshot.data!,
                      buffered: parseDuration(video.duration!),
                      total: parseDuration(video.duration!),
                      timeLabelLocation: TimeLabelLocation.sides,
                      onSeek: (duration) {
                        // 사용자가 직접 탐색한 경우 해당 위치로 이동
                        audioPlayer.seek(duration);

                        // 현재 위치가 곡의 끝에 가까운지 확인 (99% 이상)
                        final totalDuration = parseDuration(video.duration!);
                        if (duration.inMilliseconds >=
                            totalDuration.inMilliseconds * 0.99) {
                          // 곡의 끝에 가까운 위치로 탐색했고, 반복 모드가 켜져 있다면
                          if (isLooping) {
                            print("곡의 끝에 도달하고 반복 모드가 켜져 있어 처음으로 돌아갑니다.");
                            // 약간의 지연 후 처음으로 돌아가기 (UI 업데이트를 위해)
                            Future.delayed(Duration(milliseconds: 50), () {
                              setState(() {
                                // ProgressBar 초기화를 위해 _currentPosition 설정
                                _currentPosition = Duration.zero;
                              });

                              // 오디오 플레이어 위치 초기화 및 재생
                              audioPlayer.seek(Duration.zero).then((_) {
                                audioPlayer.play();
                              });
                            });
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // 이전 곡이 있는지 확인하는 메서드
  bool hasPreviousSong() {
    return _currentIndex > 0;
  }

  // 이전 곡 재생 메서드
  void playPreviousSong() {
    if (hasPreviousSong()) {
      setState(() {
        _currentIndex--;
      });

      // 이전 곡 재생
      playSoundinFile(
          audioPlayer: audioPlayer, video: _playlist[_currentIndex]);
      _updateCurrentSong();
    }
  }

  // 다음 곡이 있는지 확인하는 메서드
  bool hasNextSong() {
    return _currentIndex < _playlist.length - 1;
  }

  // 다음 곡 재생 메서드
  void playNextSong() {
    if (hasNextSong()) {
      setState(() {
        _currentIndex++;
      });

      // 다음 곡 재생
      playSoundinFile(
          audioPlayer: audioPlayer, video: _playlist[_currentIndex]);
      _updateCurrentSong();
    }
  }

  // 플레이리스트 셔플 메서드
  void toggleShuffle() {
    setState(() {
      isShuffling = !isShuffling;

      if (isShuffling) {
        // 현재 곡 저장
        VideoModel currentSong = _playlist[_currentIndex];

        // 플레이리스트 섞기
        _playlist = List.from(_playlist)..shuffle();

        // 현재 곡을 첫 번째로 이동
        _playlist.remove(currentSong);
        _playlist.insert(0, currentSong);
        _currentIndex = 0;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('셔플 모드가 켜졌습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // 현재 곡 저장
        VideoModel currentSong = _playlist[_currentIndex];

        // 원래 순서로 복원
        _playlist = List.from(_originalPlaylist);

        // 현재 인덱스 업데이트
        _currentIndex = _playlist.indexOf(currentSong);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('셔플 모드가 꺼졌습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  // audio 관련 기능 View
  Container _playAudioBox(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                // 반복 모드 전환
                isLooping = !isLooping;
                if (isLooping) {
                  audioPlayer.setLoopMode(LoopMode.one).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('반복 재생이 켜졌습니다.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  });
                } else {
                  audioPlayer.setLoopMode(LoopMode.off).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('반복 재생이 꺼졌습니다.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  });
                }
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(isLooping ? Icons.repeat_one : Icons.repeat,
                    color: isLooping ? Colors.white : Colors.white70),
                if (!isLooping)
                  Transform.rotate(
                      angle: -0.785,
                      child: Container(
                        width: 24,
                        height: 2,
                        color: Colors.white60,
                      ))
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // 현재 재생 위치 확인
              if (_currentPosition.inSeconds <= 3) {
                // 3초 이내라면 이전 곡으로 이동
                if (hasPreviousSong()) {
                  playPreviousSong();
                } else {
                  // 이전 곡이 없으면 메시지 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('이전 곡이 없습니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } else {
                // 3초 이상이라면 현재 곡의 처음부터 재생
                setState(() {
                  _currentPosition = Duration.zero;
                });
                audioPlayer.seek(Duration.zero).then((_) {
                  // 재생 중이 아니라면 재생 시작
                  if (!isPlaying) {
                    setState(() {
                      isPlaying = true;
                    });
                    audioPlayer.play();
                  }
                });
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.skip_previous),
            ),
          ),
          GestureDetector(
            onTap: () {
              isPlaying = !isPlaying;
              setState(() {
                if (isPlaying) {
                  audioPlayer.play();
                } else {
                  audioPlayer.pause();
                }
              });
            },
            child: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            ),
          ),
          GestureDetector(
            onTap: () {
              // 다음 곡 재생
              if (hasNextSong()) {
                playNextSong();
              } else {
                // 다음 곡이 없으면 메시지 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('다음 곡이 없습니다.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.skip_next),
            ),
          ),
          GestureDetector(
            onTap: () {
              toggleShuffle(); // 셔플 토글 메서드 호출
            },
            child: Icon(
              Icons.shuffle,
              color: isShuffling
                  ? Colors.white
                  : Colors.white70, // 셔플 상태에 따라 색상 변경
            ),
          ),
        ],
      ),
    );
  }

  // 현재 재생 중인 곡 정보 업데이트
  void _updateCurrentSong() {
    setState(() {
      // UI 업데이트를 위한 상태 갱신
      _currentPosition = Duration.zero;
    });

    // 제목과 썸네일 등이 업데이트되도록 build 메서드가 다시 호출됨
  }
}
