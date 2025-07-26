import 'package:Vibes/model/VideoModel.dart';
import 'package:Vibes/services/AudioPlayerState.dart';
import 'package:Vibes/services/utils.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          _buildRepeatModeButton(
            onTap: () => audioState.toggleRepeatMode(),
            repeatMode: audioState.repeatMode,
          ),
          _buildControlButton(
            onTap: () => audioState.playPreviousSong(context),
            icon: Icons.skip_previous,
            isActive: true,
            size: 40,
            label: '이전 곡',
          ),
          _buildPlayPauseButton(
            onTap: () => audioState.audioPlay(),
            isPlaying: audioState.isPlaying,
          ),
          _buildControlButton(
            onTap: () => audioState.playNextSong(context),
            icon: Icons.skip_next,
            isActive: true,
            size: 40,
            label: '다음 곡',
          ),
          _buildControlButton(
            onTap: () => audioState.toggleShuffle(context),
            icon: Icons.shuffle,
            isActive: audioState.isShuffling,
            label: audioState.isShuffling ? '셔플 켜짐' : '셔플 꺼짐',
          ),
        ],
      ),
    );
  }

  // 통일된 컨트롤 버튼 위젯
  Widget _buildControlButton({
    required VoidCallback onTap,
    required IconData icon,
    required bool isActive,
    double size = 32,
    String? label,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive 
                ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.white70,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }

  // 재생/일시정지 버튼 (더 큰 사이즈)
  Widget _buildPlayPauseButton({
    required VoidCallback onTap,
    required bool isPlaying,
  }) {
    return Semantics(
      button: true,
      label: isPlaying ? '일시정지' : '재생',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.onPrimary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Theme.of(context).colorScheme.primary,
            size: 36,
          ),
        ),
      ),
    );
  }

  // 반복 모드 전용 버튼
  Widget _buildRepeatModeButton({
    required VoidCallback onTap,
    required RepeatMode repeatMode,
  }) {
    return Semantics(
      button: true,
      label: _getRepeatModeLabel(repeatMode),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                _getRepeatModeIcon(repeatMode),
                color: (repeatMode != RepeatMode.none && repeatMode != RepeatMode.oneTime) ? Colors.white : Colors.white70,
                size: 19.2,
              ),
              // none과 oneTime 상태일 때 취소선과 텍스트 표시
              if (repeatMode == RepeatMode.none || repeatMode == RepeatMode.oneTime) ...[
                Transform.rotate(
                  angle: -0.785,
                  child: Container(
                    width: 24,
                    height: 1.5,
                    color: Colors.white60,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: repeatMode == RepeatMode.none ? null : 12,
                    height: repeatMode == RepeatMode.none ? null : 12,
                    padding: repeatMode == RepeatMode.none 
                        ? EdgeInsets.symmetric(horizontal: 2, vertical: 1) 
                        : null,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      shape: repeatMode == RepeatMode.none 
                          ? BoxShape.rectangle 
                          : BoxShape.circle,
                      borderRadius: repeatMode == RepeatMode.none 
                          ? BorderRadius.circular(4) 
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        repeatMode == RepeatMode.none ? 'All' : '1',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 반복 모드에 따른 아이콘 반환
  IconData _getRepeatModeIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none:
        return Icons.repeat;         // 전체 한번 듣기 - repeat + 취소선 + "All"
      case RepeatMode.one:
        return Icons.repeat_one;     // 한곡 반복
      case RepeatMode.all:
        return Icons.repeat;         // 전체 반복
      case RepeatMode.oneTime:
        return Icons.repeat;         // 한곡 한번 듣기 - repeat + 취소선 + "1"
    }
  }

  // 반복 모드에 따른 라벨 반환
  String _getRepeatModeLabel(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none:
        return '반복 없음';
      case RepeatMode.one:
        return '한곡 반복';
      case RepeatMode.all:
        return '전체 반복';
      case RepeatMode.oneTime:
        return '한곡 한번 듣기';
    }
  }
}
