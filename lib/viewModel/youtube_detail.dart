import 'package:flutter/material.dart';
import 'package:kls_project/model/VideoModel.dart';
import 'package:kls_project/services/FileServices.dart';
import 'package:kls_project/services/GlobalSnackBar.dart';
import 'package:kls_project/services/PlayListState.dart';
import 'package:kls_project/services/utils.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_scrape_api/models/video.dart';

class YoutubeDetailView extends StatefulWidget {
  final Video detailVideo;

  const YoutubeDetailView({
    required this.detailVideo,
    super.key,
  });

  @override
  State<YoutubeDetailView> createState() => _YoutubeDetailViewState();
}

class _YoutubeDetailViewState extends State<YoutubeDetailView> {
  late YoutubePlayerController _youtubePlayerController; // 유튭 동영상 controller
  int soundVolume = 50; // 이페이지에 들어올때 soundVolume은 50으로 초기화

  @override
  void initState() {
    super.initState();
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.detailVideo.videoId!,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: true,
        showLiveFullscreenButton: false,
        enableCaption: false,
      ),
    )..setVolume(soundVolume);
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    super.dispose();
    print(_youtubePlayerController);
  }

  @override
  Widget build(BuildContext context) {
    print(
        "volume : ${_youtubePlayerController.value.volume} / sound : $soundVolume");

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: kToolbarHeight, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar처럼 사용할 부분
          _topAppbar(context),
          // 유튜브 영상 부분
          _customYoutubePlayer(context),
          // 큰 제목 및 자세한 설명 부분
          _largeTitle(context),
          // channel 주인 및 업로드 날짜 View
          _channelNameAndUpload(context),
          SizedBox(height: 5.0),
          // 조회수 뷰뷰
          _detailViews(context),
          // slider 부분
          _customSoundSlider(),
          // 다운로드 버튼 뷰
          _downloadButton(context, video: widget.detailVideo),
        ],
      ),
    );
  }

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
          Text(
            "KLS PREVIEW",
            style: Theme.of(context).textTheme.bodyLarge,
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

  AspectRatio _customYoutubePlayer(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: YoutubePlayer(
        controller: _youtubePlayerController,
        showVideoProgressIndicator: true,
        onEnded: (metaData) {
          Navigator.of(context).pop();
        },
        topActions: [], // top 부분 제거를 위함
        bottomActions: [
          // 바텀 부분 커스텀
          ValueListenableBuilder(
            valueListenable: _youtubePlayerController,
            builder: (context, value, child) {
              return Text(
                formatDuration(_youtubePlayerController.value.position)
                    .toString()
                    .padLeft(2, "0"),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              );
            },
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: ProgressBar(),
          )),
          Text(
            widget.detailVideo.duration!.padLeft(2, "0"),
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Padding _largeTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(widget.detailVideo.title!,
          style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Row _customSoundSlider() {
    return Row(
      children: [
        Icon(Icons.volume_down),
        Expanded(
          child: Slider(
            // 볼륨 값 (0~100을 0~1로 변환해서 사용)
            value: (soundVolume / 100).toDouble(),
            min: 0.0,
            max: 1.0,
            onChanged: (value) {
              // 소수 값 (0~1)을 다시 0~100 정수로 변환하여 볼륨 설정
              setState(() {
                soundVolume = (value * 100).toInt();
                _youtubePlayerController.setVolume(soundVolume);
              });
            },
            activeColor: Theme.of(context).sliderTheme.activeTrackColor,
            inactiveColor: Colors.grey,
            thumbColor: Colors.red,
          ),
        ),
        Icon(Icons.volume_up),
      ],
    );
  }

  Row _channelNameAndUpload(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.detailVideo.channelName!,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          widget.detailVideo.uploadDate!,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Text _detailViews(BuildContext context) {
    return Text(
      widget.detailVideo.views!,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Expanded _downloadButton(BuildContext context, {required Video video}) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // VideoModel 객체 생성
            final selectedVideo = VideoModel(
              videoId: video.videoId,
              duration: video.duration,
              title: video.title,
              channelName: video.channelName,
              views: video.views,
              uploadDate: video.uploadDate,
              thumbnailUrls: convertThumnailURL(video.thumbnails!),
            );
            FileServices.instance
                .isVideoDownloaded(videoId: video.videoId!)
                .then((isDownloaded) {
              if (isDownloaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('이미 다운로드된 영상입니다.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
              } else {
                // 다운로드 시작 알림
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('다운로드를 시작합니다...'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // 뒤로 가기  <- 바텀시트
                Navigator.of(context).pop();

                // 오디오 다운로드
                FileServices.instance
                    .downloadVideo(video: selectedVideo)
                    .then((_) {
                  GlobalSnackBar.show('다운로드가 완료되었습니다!', isSuccess: true);
                }).catchError((error) {
                  GlobalSnackBar.show('다운로드 중 오류가 발생했습니다.', isSuccess: false);
                });

                // playlist 저장
                Provider.of<PlayListState>(context, listen: false)
                    .createPlayList(selectedVideo);
              }
            });
          },
          child: Text(
            "다운로드",
            style: Theme.of(context)
                .textTheme
                .displayLarge!
                .copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
