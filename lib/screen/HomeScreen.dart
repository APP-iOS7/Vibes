import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Vibes/model/VideoModel.dart';
import 'package:Vibes/services/YoutubeMusicChartState.dart';
import 'package:Vibes/services/RecentlyDownloadedState.dart';
import 'package:Vibes/services/utils.dart';
import 'package:Vibes/components/horizontal_chart_tile.dart';
import 'package:Vibes/components/recently_downloaded_tile.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  VoidCallback onChange;
  HomeScreen({required this.onChange, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer2<YoutubeMusicChartState, RecentlyDownloadedState>(
        builder: (context, chartState, recentlyDownloadedState, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                chartState.refreshChart(),
                recentlyDownloadedState.refresh(),
              ]);
            },
            child: Column(
              children: [
                // 헤더 섹션
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage("assets/images/splash_logo.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "YouTube Music",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              "Vibes로 음악을 즐겨보세요",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onChange,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Text(
                            "검색",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, thickness: 0.5),

                // 차트 리스트
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildRecentlyDownloadedSection(recentlyDownloadedState),
                        _buildChartContent(chartState),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartContent(YoutubeMusicChartState chartState) {
    if (chartState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "인기차트를 불러오는 중...",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    if (chartState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 16),
            Text(
              chartState.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => chartState.refreshChart(),
              child: Text("다시 시도"),
            ),
          ],
        ),
      );
    }

    if (chartState.chartVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Image.asset(
                "assets/images/noSearchFound.png",
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "차트 정보를 불러올 수 없습니다",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () => chartState.refreshChart(),
              child: Text("새로고침"),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 섹션 타이틀
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
          child: Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                "실시간 인기차트",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),

        // 차트 리스트 (가로 스크롤)
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: chartState.chartVideos.length,
            itemBuilder: (context, index) {
              final VideoModel video = chartState.chartVideos[index];
              return HorizontalChartTile(
                video: video,
                ranking: index + 1,
                onTap: () {
                  showDetailVideoFromModel(
                      selectedVideo: video, context: context);
                },
              );
            },
          ),
        ),
        
        // 추가 공간 (향후 다른 섹션 추가 가능)
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRecentlyDownloadedSection(RecentlyDownloadedState recentlyDownloadedState) {
    // Show loading state
    if (recentlyDownloadedState.isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 섹션 타이틀
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.download_done,
                  color: Colors.green[600],
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  "최근 다운로드한 음악",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
          // Loading indicator
          SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          SizedBox(height: 8),
          Divider(height: 1, thickness: 0.3, indent: 16, endIndent: 16),
        ],
      );
    }

    // Don't show the section if no downloads
    if (recentlyDownloadedState.recentlyDownloaded.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 섹션 타이틀
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
          child: Row(
            children: [
              Icon(
                Icons.download_done,
                color: Colors.green[600],
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                "최근 다운로드한 음악",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),

        // 다운로드된 음악 리스트 (가로 스크롤)
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: recentlyDownloadedState.recentlyDownloaded.length,
            itemBuilder: (context, index) {
              final VideoModel video = recentlyDownloadedState.recentlyDownloaded[index];
              return RecentlyDownloadedTile(
                video: video,
                onTap: () {
                  showDetailVideoFromModel(
                      selectedVideo: video, context: context);
                },
              );
            },
          ),
        ),
        
        // 섹션 간 구분
        SizedBox(height: 8),
        Divider(height: 1, thickness: 0.3, indent: 16, endIndent: 16),
      ],
    );
  }
}
