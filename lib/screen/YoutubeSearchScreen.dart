import 'package:flutter/material.dart';
import 'package:kls_project/services/YoutubeSearchState.dart';
import 'package:kls_project/services/utils.dart';
import 'package:kls_project/viewModel/play_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'package:hive_flutter/hive_flutter.dart';

class YoutubeSearchScreen extends StatefulWidget {
  final Stream<List<Video>> streamInjection;
  const YoutubeSearchScreen({required this.streamInjection, super.key});

  @override
  State<YoutubeSearchScreen> createState() => _YoutubeSearchScreenState();
}

class _YoutubeSearchScreenState extends State<YoutubeSearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  late final SearchController _searchController;
  bool _isSearching = false;
  bool _isLoading = false;
  List<String> _searchHistory = [];
  final String _searchHistoryBoxName = 'searchHistory';

  @override
  void initState() {
    super.initState();
    _queryController.clear();
    _loadSearchHistory();

    // SearchController 초기화
    _searchController = SearchController();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    var box = await Hive.openBox<String>(_searchHistoryBoxName);
    setState(() {
      _searchHistory = box.values.toList();
    });
  }

  Future<void> _saveSearchQuery(String query) async {
    if (query.isEmpty) return;

    var box = await Hive.openBox<String>(_searchHistoryBoxName);

    // 중복 검색어 제거
    if (_searchHistory.contains(query)) {
      int index = _searchHistory.indexOf(query);
      await box.deleteAt(index);
    }

    // 최대 10개까지만 저장
    if (_searchHistory.length >= 10) {
      await box.deleteAt(0);
    }

    // 새 검색어 추가
    await box.add(query);

    // 검색 기록 다시 로드
    await _loadSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: _buildSearchBar(context),
          ),
          Expanded(
            child: StreamBuilder(
              stream: widget.streamInjection,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("문제가 있습니다.. ${snapshot.error}"));
                } else {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    if (_isLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque, // 빈 영역에서도 터치 감지
                        onTap: () =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: double.infinity,
                          child: Text(
                            "추천 ex) 만두쌤의 코딩 한 꼬집",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      );
                    }
                  } else {
                    if (_isSearching &&
                        snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (_isSearching && snapshot.data?.length == 0) {
                      return Center(child: Text("검색 결과가 없습니다."));
                    }
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

  // 상단 검색바 부분
  Widget _buildSearchBar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SearchAnchor(
      isFullScreen: false,
      viewHintText: "듣고 싶은 음악을 검색해주세요",
      searchController: _searchController,
      viewLeading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          _searchController.closeView('');
        },
      ),
      viewTrailing: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            String query = _searchController.text;
            if (query.isNotEmpty) {
              _searchController.closeView(query);
              _queryController.text = query;
              _performSearch(query);
            }
          },
        ),
      ],
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: _queryController,
          hintText: "듣고 싶은 음악을 검색해주세요",
          hintStyle:
              WidgetStateProperty.all(Theme.of(context).textTheme.bodySmall),
          leading: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // 검색 아이콘 클릭 시에만 검색 제안 뷰 열기
                _searchController.text = ''; // 검색 컨트롤러의 텍스트를 비움
                controller.openView();
              }),
          trailing: [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _queryController.clear();
                setState(() {
                  _isSearching = false;
                });
              },
            ),
          ],
          onSubmitted: (value) {
            _performSearch(value);
          },
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 8.0),
          ),
          elevation: const WidgetStatePropertyAll<double>(2.0),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) => Theme.of(context).colorScheme.surface,
          ),
          shadowColor: WidgetStateProperty.all(
            isDarkMode ? Colors.white : Colors.black,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
              side: BorderSide(
                color: isDarkMode ? Colors.white : Colors.black,
                width: 1.0,
              ),
            ),
          ),
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        // 검색어 입력 시 검색 기록에서 필터링
        String query = controller.text.toLowerCase();
        List<String> filteredHistory = _searchHistory
            .where((item) => item.toLowerCase().contains(query))
            .toList();
        List<Widget> results = [];

        if (filteredHistory.isEmpty) {
          results.add(Center(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("검색 기록이 없습니다."))));

          if (query.isNotEmpty) {
            results.add(ListTile(
                leading: Icon(Icons.search),
                title: Text('"$query" 검색하기'),
                onTap: () {
                  _queryController.text = query;
                  controller.closeView(query);
                  _performSearch(query);
                }));
          }
        } else {
          // 최신 검색어가 위에 표시되도록 역순으로 정렬
          List<String> reversedHistory = List.from(filteredHistory.reversed);

          // 새 검색어 옵션 추가 (입력된 검색어가 있는 경우)
          if (query.isNotEmpty && !filteredHistory.contains(query)) {
            results.add(ListTile(
              leading: Icon(Icons.search),
              title: Text('"$query" 검색하기'),
              onTap: () {
                controller.closeView(query);
                _queryController.text = query;
                _performSearch(query);
              },
            ));
          }

          // 검색 기록 추가
          results.addAll(reversedHistory.map((historyQuery) {
            return ListTile(
              leading: Icon(Icons.history),
              title: Text(historyQuery),
              trailing: IconButton(
                icon: Icon(Icons.close, size: 16),
                onPressed: () async {
                  var box = await Hive.openBox<String>(_searchHistoryBoxName);
                  int index = _searchHistory.indexOf(historyQuery);
                  if (index != -1) {
                    await box.deleteAt(index);
                    await _loadSearchHistory();
                    // 검색 제안 UI 업데이트를 위해 컨트롤러 새로고침
                    controller.openView();
                  }
                },
              ),
              onTap: () {
                _queryController.text = historyQuery;
                controller.closeView(historyQuery);
                _performSearch(historyQuery);
              },
            );
          }).toList());
        }

        return results;
      },
    );
  }

  // 리스트 뷰
  ListView _searchListView(AsyncSnapshot<dynamic> snapshot) {
    return ListView.separated(
      itemCount: snapshot.data?.length ?? 0,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        indent: 16,
        endIndent: 16,
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
      ),
      itemBuilder: (BuildContext context, int index) {
        Video video = snapshot.data[index];
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            showDetailVideo(selectedVideo: video, context: context);
          },
          child: PlayListTile(video: video),
        );
      },
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    // 검색어 저장
    _saveSearchQuery(query);

    // 검색 실행 - 약간의 지연을 추가하여 UI 업데이트 후 검색이 실행되도록 함
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        Provider.of<Youtubesearchstate>(context, listen: false)
            .serachYoutube(query: query);
      }
    });

    FocusManager.instance.primaryFocus?.unfocus();
  }
}
