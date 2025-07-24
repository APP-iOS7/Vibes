import 'package:Vibes/services/AudioPlayerState.dart';
import 'package:flutter/material.dart';
import 'package:Vibes/model/VideoModel.dart';
import 'package:Vibes/services/FileServices.dart';
import 'package:Vibes/services/GlobalSnackBar.dart';
import 'package:Vibes/services/PlayListState.dart';
import 'package:Vibes/services/utils.dart';
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
  @override
  void initState() {
    super.initState();

    Provider.of<AudioPlayerState>(context, listen: false).disposePlayer();

    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.detailVideo.videoId!,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: true,
        showLiveFullscreenButton: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // 조회수 뷰
          _detailViews(context),
          // 다운로드 버튼 뷰
          SizedBox(height: 10),
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
            "Vibes",
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

  Row _downloadButton(BuildContext context, {required Video video}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
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
                .then((isDownloaded) async {
              if (isDownloaded) {
                // GlobalSnackBar 사용으로 BuildContext 의존성 제거
                GlobalSnackBar.show('이미 다운로드된 영상입니다. 플레이리스트에 추가됩니다.', isSuccess: true);
                
                // 이미 다운로드된 경우에도 플레이리스트에 추가하고 audioPath와 downloadDate 설정
                selectedVideo.audioPath = await FileServices.instance.getAudioFilePath(
                  videoId: selectedVideo.videoId!
                );
                
                // 파일 생성 날짜를 downloadDate로 설정
                selectedVideo.downloadDate = await FileServices.instance.getFileCreationDate(
                  videoId: selectedVideo.videoId!
                ) ?? DateTime.now().subtract(Duration(days: 30));
                
                // mounted 체크 추가
                if (!mounted) return;
                
                final playListState = Provider.of<PlayListState>(context, listen: false);
                
                // 기존에 플레이리스트에 있는지 확인
                final existingVideoIndex = playListState.playlist.indexWhere(
                  (video) => video.videoId == selectedVideo.videoId
                );
                
                if (existingVideoIndex != -1) {
                  // 이미 존재하면 업데이트
                  await playListState.updateVideoModel(selectedVideo);
                } else {
                  // 존재하지 않으면 새로 추가
                  await playListState.createPlayList(selectedVideo);
                }
                
                // mounted 체크 후 Navigator 사용
                if (mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                // 다운로드 시작 알림 - GlobalSnackBar 사용
                GlobalSnackBar.show('다운로드를 시작합니다...', isSuccess: true);

                // mounted 체크 후 Navigator 사용
                if (mounted) {
                  Navigator.of(context).pop();
                }

                // 오디오 다운로드 - 콜백을 통한 컨텍스트 프리 플레이리스트 추가
                try {
                  final bool downloadSuccess = await FileServices.instance.downloadVideo(
                    video: selectedVideo,
                    onDownloadComplete: (VideoModel completedVideo) async {
                      // PlayListState 싱글톤 인스턴스로 접근 - BuildContext 불필요
                      final playListState = PlayListState.instance;
                      if (playListState != null) {
                        // 기존에 플레이리스트에 있는지 확인
                        final existingVideoIndex = playListState.playlist.indexWhere(
                          (video) => video.videoId == completedVideo.videoId
                        );
                        
                        if (existingVideoIndex != -1) {
                          // 이미 존재하면 업데이트
                          await playListState.updateVideoModel(completedVideo);
                          print("[youtube_detail] Updated existing video in playlist: ${completedVideo.title}");
                        } else {
                          // 존재하지 않으면 새로 추가
                          await playListState.createPlayList(completedVideo);
                          print("[youtube_detail] Added new video to playlist: ${completedVideo.title}");
                        }
                      } else {
                        print("[youtube_detail] Warning: PlayListState instance is null");
                      }
                    }
                  );
                  
                  if (downloadSuccess) {
                    GlobalSnackBar.show('다운로드가 완료되었습니다!', isSuccess: true);
                  } else {
                    // 실제 다운로드 실패
                    GlobalSnackBar.show('다운로드에 실패했습니다. 다시 시도해주세요.', isSuccess: false);
                  }
                } catch (error) {
                  print("[youtube_detail] Download exception: $error");
                  // 예외 발생 시에만 실패 메시지 표시
                  GlobalSnackBar.show('다운로드 중 오류가 발생했습니다.', isSuccess: false);
                }
              }
            }).catchError((error) {
              print("[youtube_detail] isVideoDownloaded error: $error");
              // 파일 확인 과정에서의 에러는 별도 처리
              GlobalSnackBar.show('파일 확인 중 오류가 발생했습니다.', isSuccess: false);
            });
          },
          icon: Icon(Icons.download),
        ),
        IconButton(onPressed: () {}, icon: Icon(Icons.share_rounded))
      ],
    );
  }
}
