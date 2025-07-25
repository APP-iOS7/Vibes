import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:Vibes/model/VideoModel.dart';
import 'package:Vibes/services/PlayListState.dart';
import 'package:Vibes/components/play_list_tile2.dart';
import 'package:provider/provider.dart';

class PlayListScreen extends StatefulWidget {
  final bool isEditMode;
  final Function(bool) onEditModeChanged;
  
  const PlayListScreen({
    super.key,
    this.isEditMode = false,
    required this.onEditModeChanged,
  });

  @override
  State<PlayListScreen> createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlayListScreen> {

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
          
          // 편집 모드에 따라 다른 리스트 위젯 사용
          return widget.isEditMode
              ? ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: playListState.playlist.length,
                  onReorder: (oldIndex, newIndex) {
                    playListState.reorderPlaylist(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    VideoModel music = playListState.playlist[index];
                    return PlayListTile2(
                      key: ValueKey(music.videoId),
                      video: music,
                      isEditMode: widget.isEditMode,
                      index: index,
                    );
                  },
                )
              : ListView.builder(
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
                                playListState.deletePlayList(context, music.videoId!),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            icon: Icons.delete_forever,
                            label: 'delete',
                          ),
                        ],
                      ),
                      child: PlayListTile2(
                        video: music,
                        isEditMode: widget.isEditMode,
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
