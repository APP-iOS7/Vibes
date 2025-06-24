import 'package:Vibes/model/VideoModel.dart';
import 'package:Vibes/services/AudioPlayerState.dart';
import 'package:Vibes/services/utils.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({
    super.key,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerState>(builder: (context, audioState, child) {
      final audioPlayer = audioState.audioPlayer;
      final currentVideo = audioState.currentVideo;
      return Padding(
        padding: const EdgeInsets.symmetric(
            vertical: kToolbarHeight / 2, horizontal: 12),
        child: Column(
          children: [
            _topAppbar(context),
            _thumnailContent(currentVideo),
            _mainTitle(context, currentVideo),
            _channelNameView(context, currentVideo),
            _audioSlider(context, currentVideo, audioPlayer),
            _playAudioBox(context, audioState),
          ],
        ),
      );
    });
  }

  // top 상단 바
  Padding _topAppbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // 현재 화면 닫기
            },
            child: Icon(Icons.keyboard_arrow_down_rounded, size: 25),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // 현재 화면 닫기
            },
            child: Icon(Icons.close_rounded, size: 25),
          ),
        ],
      ),
    );
  }

  // 썸네일 이미지 부분 (현재 비디오 사용)
  Expanded _thumnailContent(VideoModel video) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        margin: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            video.thumbnailUrls!.first.toString(),
            fit: BoxFit.contain,
          ),
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
  Padding _channelNameView(BuildContext context, VideoModel video) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
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
      ),
    );
  }

  // audio Duration 슬라이더
  SliderTheme _audioSlider(
      BuildContext context, VideoModel video, AudioPlayer audioPlayer) {
    final totalDuration = parseDuration(video.duration!);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Theme.of(context).colorScheme.primary,
        inactiveTrackColor: Theme.of(context).colorScheme.secondary,
        trackHeight: 6.0,
        thumbColor: Theme.of(context).colorScheme.primary,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 3.0),
      ),
      child: StreamBuilder<Duration>(
        stream: audioPlayer.positionStream,
        builder: (context, snapshot) {
          final position = snapshot.data ?? Duration.zero;

          return StreamBuilder<Duration>(
            stream: audioPlayer.bufferedPositionStream,
            builder: (context, bufferedSnapshot) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ProgressBar(
                  progress: position,
                  total: totalDuration,
                  timeLabelLocation: TimeLabelLocation.sides,
                  onSeek: (duration) =>
                      Provider.of<AudioPlayerState>(context, listen: false)
                          .sliderControls(duration),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // audio 관련 기능 View
  Container _playAudioBox(
    BuildContext context,
    AudioPlayerState audioState, // Provider State
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => audioState.loopSet(), // isLooping setter
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(audioState.isLooping ? Icons.repeat_one : Icons.repeat,
                    color:
                        audioState.isLooping ? Colors.white : Colors.white70),
                if (!audioState.isLooping)
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
            onTap: () => audioState.playPreviousSong(context),
            child: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.skip_previous),
            ),
          ),
          GestureDetector(
            onTap: () => audioState.audioPlay(),
            child: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child:
                  Icon(audioState.isPlaying ? Icons.pause : Icons.play_arrow),
            ),
          ),
          GestureDetector(
            onTap: () => audioState.playNextSong(context),
            child: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.skip_next),
            ),
          ),
          GestureDetector(
            onTap: () => audioState.shuffleSet(context),
            child: Icon(
              Icons.shuffle,
              color: audioState.isShuffling
                  ? Colors.white
                  : Colors.white70, // 셔플 상태에 따라 색상 변경
            ),
          ),
        ],
      ),
    );
  }
}
