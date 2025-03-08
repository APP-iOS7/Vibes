import 'package:flutter/material.dart';
import 'package:kls_project/model/VideoModel.dart';
import 'package:kls_project/services/YoutubeSearchState.dart';
import 'package:kls_project/services/utils.dart';
import 'package:kls_project/viewModel/play_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:youtube_scrape_api/models/video.dart';

class YoutubeSearchScreen extends StatefulWidget {
  final Stream<List<Video>> streamInjection;
  const YoutubeSearchScreen({required this.streamInjection, super.key});

  @override
  State<YoutubeSearchScreen> createState() => _YoutubeSearchScreenState();
}

// initState가 불린다.. 아무것도 없다..?
class _YoutubeSearchScreenState extends State<YoutubeSearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _queryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: _queryTextField(context),
          ),
          Expanded(
            child: StreamBuilder(
              stream: widget.streamInjection,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  // 에러르 먼저 걸러서 다음처리에는 stream은 초기화가 안돼서 null상태
                  return Center(child: Text("문제가 있습니다.. ${snapshot.error}"));
                } else {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // stream = null == snapshot.connectionState 입니다
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque, // 빈 영역에서도 터치 감지
                      onTap: () =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: double.infinity,
                        child: Text(
                          "추천 ex) 만두쌤의 코딩 한 코집",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  } else {
                    if (_queryController.text.isEmpty && !snapshot.hasData) {}
                    return _searchListView(snapshot);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // 상단 입력 부분
  TextField _queryTextField(BuildContext context) {
    return TextField(
      controller: _queryController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: "듣고 싶은 음악을 선택해주세요",
        hintStyle: Theme.of(context).textTheme.bodySmall,
        labelText: "검색",
        labelStyle: Theme.of(context).textTheme.bodyLarge,
        suffixIcon: GestureDetector(
            onTap: () {
              Provider.of<Youtubesearchstate>(context, listen: false)
                  .serachYoutube(query: _queryController.text);
              FocusManager.instance.primaryFocus!.unfocus();
              _queryController.clear();
            },
            child: Icon(Icons.search, size: 30)),
      ),
    );
  }

  // 리스트 뷰
  ListView _searchListView(AsyncSnapshot<dynamic> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        Video video = snapshot.data[index];
        return GestureDetector(
          onTapDown: (details) => FocusManager.instance.primaryFocus?.unfocus(),
          onTapUp: (details) => FocusManager.instance.primaryFocus?.unfocus(),
          onTap: () => showDetailVideo(selectedVideo: video, context: context),
          child: PlayListTile(video: video),
        );
      },
    );
  }
}
