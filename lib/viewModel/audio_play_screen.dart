import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kls_project/model/VideoModel.dart';
import 'package:kls_project/services/utils.dart';
import 'package:path_provider/path_provider.dart';

// 오디오를 자세하게 보여주며 실행하는 스크린 입니다.
class AudioPlayScreen extends StatefulWidget {
  final VideoModel videoModel;
  const AudioPlayScreen({required this.videoModel, super.key});

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
  // 현재 위치를 추적하기 위한 변수
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    // 오디오 플레이어 초기화
    audioPlayer.setLoopMode(LoopMode.off);
    playSoundinFile(audioPlayer: audioPlayer, video: widget.videoModel);

    // 위치 스트림 리스너 설정
    audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    // 플레이어 상태 스트림 리스너 설정
    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        if (isLooping) {
          // 반복 재생 시 처음부터 다시 재생
          setState(() {
            _currentPosition = Duration.zero;
          });
          audioPlayer.seek(Duration.zero);
          audioPlayer.play();
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
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding:
              EdgeInsets.symmetric(vertical: kToolbarHeight, horizontal: 10),
          child: Column(
            children: [
              _topAppBarTitle(context),
              Expanded(child: _thumnailContent()),
              _mainTitle(context),
              SizedBox(height: 8),
              _channelNameView(context),
              _audioSlider(context),
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

  // 썸네일 이미지 부분
  Container _thumnailContent() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          widget.videoModel.thumbnailUrls!.first.toString(),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // 메인 텍스트 뷰
  Text _mainTitle(BuildContext context) {
    return Text(
      widget.videoModel.title.toString(),
      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16),
    );
  }

  // 채널 이름
  Row _channelNameView(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            widget.videoModel.channelName!,
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

  // audio duration Slider 뷰 입니다.
  SliderTheme _audioSlider(BuildContext context) {
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
                      buffered: parseDuration(widget.videoModel.duration!),
                      total: parseDuration(widget.videoModel.duration!),
                      timeLabelLocation: TimeLabelLocation.sides,
                      onSeek: (duration) {
                        audioPlayer.seek(duration);
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
          CircleAvatar(
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.skip_previous),
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
          CircleAvatar(
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.skip_next),
          ),
          GestureDetector(
            onTap: () {},
            child: Icon(Icons.shuffle),
          ),
        ],
      ),
    );
  }
}
