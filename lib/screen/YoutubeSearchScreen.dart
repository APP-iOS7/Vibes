import 'package:flutter/material.dart';
import 'package:kls_project/services/YoutubeSearchState.dart';
import 'package:kls_project/services/utils.dart';
import 'package:provider/provider.dart';
import 'package:youtube_scrape_api/models/video.dart';

class YoutubeSearchScreen extends StatefulWidget {
  const YoutubeSearchScreen({super.key});

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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _queryTextField(context),
          ),
          Expanded(
            child: StreamBuilder(
              stream: Provider.of<Youtubesearchstate>(context, listen: false)
                  .searchResult,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                print("stream Result :  ${snapshot.data}");
                if (snapshot.hasError) {
                  return Center(child: Text("문제가 있습니다.. ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _queryController.text.isNotEmpty &&
                    snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (_queryController.text.isEmpty) {
                    return Center(
                      child: Text(
                        "검색을 해요!",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }
                  return _searchListView(snapshot);
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
        labelText: "검색",
        labelStyle: Theme.of(context).textTheme.bodyLarge,
        suffixIcon: GestureDetector(
            onTap: () {
              Provider.of<Youtubesearchstate>(context, listen: false)
                  .serachYoutube(query: _queryController.text);
            },
            child: Icon(Icons.search, size: 30)),
      ),
    );
  }

  // 리스트 뷰
  ListView _searchListView(AsyncSnapshot<dynamic> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        Video video = snapshot.data[index];
        return GestureDetector(
          onTap: () => showDetailVideo(selectedVideo: video, context: context),
          child: ListTile(
            title: Text(video.title!),
            subtitle: Row(
              children: [
                Text(video.uploadDate!),
                Text(video.views!),
              ],
            ),
            leading: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(video.thumbnails!.first.url!),
            ),
          ),
        );
      },
    );
  }
}
