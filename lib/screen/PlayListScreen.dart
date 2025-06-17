import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:Vibes/model/VideoModel.dart';
import 'package:Vibes/services/PlayListState.dart';
import 'package:Vibes/components/play_list_tile2.dart';
import 'package:provider/provider.dart';

class PlayListScreen extends StatelessWidget {
  const PlayListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<PlayListState>(
        builder: (context, playListState, child) {
          if (playListState.playlist.isEmpty) {
            // 플레이 리스트가 비어있다면
            return Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  "assets/images/noPlayList.png",
                ),
              ),
            );
          }
          // 하나라도 playList에 있다면 아래 위젯을 반환
          return ListView.builder(
            itemCount: playListState.playlist.length,
            itemBuilder: (context, index) {
              VideoModel music = playListState.playlist[index];
              // 플레이리스트 데이터는 PlayListState에서 가져옴
              List<VideoModel> allVideos = playListState.playlist;

              return Slidable(
                endActionPane: ActionPane(
                  extentRatio: 0.25,
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (BuildContext context) =>
                          playListState.deletePlayList(music.videoId!),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_forever,
                      label: 'delete',
                    ),
                  ],
                ),
                // child: PlayListTile2(video: music),
                child: PlayListTile2(
                  video: music,
                  allVideos: allVideos, // 전체 플레이리스트 전달
                  currentIndex: index, // 현재 인덱스 전달
                ),
              );
            },
          );
        },
      ),
    );
  }
}
