import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kls_project/model/VideoModel.dart';
import 'package:kls_project/services/FileServices.dart';
import 'package:kls_project/services/PlayListState.dart';
import 'package:kls_project/viewModel/play_list_tile2.dart';
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
              child: Text(
                "플레이 리스트를 추가해 주세요 :( ",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
          // 하나라도 playList에 있다면 아래 위젯을 반환
          return ListView.builder(
            itemCount: playListState.playlist.length,
            itemBuilder: (context, index) {
              VideoModel music = playListState.playlist[index];
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
                child: PlayListTile2(video: music),
              );
            },
          );
        },
      ),
    );
  }
}
