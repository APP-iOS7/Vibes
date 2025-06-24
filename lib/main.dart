import 'package:Vibes/services/AudioPlayerState.dart';
import 'package:Vibes/services/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:Vibes/model/ChangeThemeMode.dart';
import 'package:Vibes/model/VideoModel.dart';
import 'package:Vibes/screen/HomeScreen.dart';
import 'package:Vibes/screen/PlayListScreen.dart';
import 'package:Vibes/screen/SettingsScreen.dart';
import 'package:Vibes/screen/YoutubeSearchScreen.dart';
import 'package:Vibes/services/GlobalSnackBar.dart';
import 'package:Vibes/services/PlayListState.dart';
import 'package:Vibes/services/YoutubeSearchState.dart';
import 'package:Vibes/theme/theme.dart';
import 'package:Vibes/components/theme_initialze.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsFlutterBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsFlutterBinding);
  await Hive.initFlutter();

  Hive.registerAdapter(VideoModelAdapter());
  await Hive.openBox<VideoModel>('playlist');

  // 백그라운드 재생을 위한 초기화
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(
    MultiProvider(
      providers: [
        // 확장을 위해 멀티 Provider 사용
        ChangeNotifierProvider(create: (_) => ChangeThemeMode()),
        ChangeNotifierProvider(create: (_) => Youtubesearchstate()),
        ChangeNotifierProvider(create: (_) => PlayListState()),
        ChangeNotifierProvider(create: (_) => AudioPlayerState()),
      ],
      child: ThemeInitialze(
        // ThemeInitialze 커스텀 위젯을 통해 Theme 테마 가져옵니다
        child: Consumer<ChangeThemeMode>(
          builder: (context, changeMode, child) => PageRouteSelection(),
        ),
      ),
    ),
  );
}

class PageRouteSelection extends StatefulWidget {
  const PageRouteSelection({super.key});

  @override
  State<PageRouteSelection> createState() => _NavigationBarAppState();
}

class _NavigationBarAppState extends State<PageRouteSelection> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove(); // 한곳에서 SplashScreen을 닫게 합니다.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KSL MUSIC',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ChangeThemeMode>(context).themeData,
      // 글로벌 ScaffoldMessenger 키 설정
      scaffoldMessengerKey: GlobalSnackBar.key,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<MainScreen> {
  int currentPageIndex = 0;
  String titleName = "KLS MUSIC";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(titleName, style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Stack(
        children: [
          <Widget>[
            /// 홈 스크린
            HomeScreen(
              onChange: () {
                currentPageIndex = 2;
                setState(() {});
              },
            ),

            // 음악재생 페이지
            PlayListScreen(),

            // 검색 페이지
            YoutubeSearchScreen(
              streamInjection:
                  Provider.of<Youtubesearchstate>(context, listen: false)
                      .searchResult,
            ),

            // 검색 페이지
            SettingsScreen(),
          ][currentPageIndex],
          // 현재 페이지 인덱스에 따라 다른 위젯을 보여줍니다.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Consumer<AudioPlayerState>(
              builder: (context, audioState, child) {
                if (!audioState.isSongPlaying) return SizedBox.shrink();
                // 현재 비디오 및 index 가져오기
                final currentVideo = audioState.currentVideo;
                audioState.getCurrentIndex(context);

                return GestureDetector(
                  onTap: () => showDetailAudio(
                    selectedVideo: currentVideo,
                    playlist: Provider.of<PlayListState>(context, listen: false)
                        .playlist,
                    context: context,
                  ),
                  child: Container(
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 6),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentVideo != null)
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                              currentVideo.thumbnailUrls?.first.toString() ??
                                  'https://via.placeholder.com/150',
                            ),
                          )
                        else
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.music_note, color: Colors.white),
                          ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            currentVideo?.title ?? "재생 중인 곡 없음",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                              audioState.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.black),
                          onPressed: () => audioState.audioPlay(),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.black),
                          onPressed: () async {
                            audioState.disposePlayer();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
            if (currentPageIndex > 0) {
              // 0이 아닌 경우 ex ) KLS MUSIC
              switch (currentPageIndex) {
                case 1:
                  titleName = "플레이 리스트";
                  break;
                case 2:
                  titleName = "검색";
                  break;
                case 3:
                  titleName = "설정";
                  break;
              }
            } else {
              titleName = "KLS MUSIC";
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor:
            Provider.of<ChangeThemeMode>(context).themeData == whiteMode()
                ? Colors.black
                : Colors.white,
        unselectedItemColor: const Color(0xFF838383),
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.double_music_note),
            label: '음악',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
