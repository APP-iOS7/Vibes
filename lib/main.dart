import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kls_project/model/ChangeThemeMode.dart';
import 'package:kls_project/model/VideoModel.dart';
import 'package:kls_project/screen/HomeScreen.dart';
import 'package:kls_project/screen/PlayListScreen.dart';
import 'package:kls_project/screen/SettingsScreen.dart';
import 'package:kls_project/screen/YoutubeSearchScreen.dart';
import 'package:kls_project/services/GlobalSnackBar.dart';
import 'package:kls_project/screen/dopeScreen.dart';
import 'package:kls_project/services/PlayListState.dart';
import 'package:kls_project/services/YoutubeSearchState.dart';
import 'package:kls_project/theme/theme.dart';
import 'package:kls_project/components/theme_initialze.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsFlutterBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsFlutterBinding);
  await Hive.initFlutter();

  Hive.registerAdapter(VideoModelAdapter());
  await Hive.openBox<VideoModel>('playlist');
  var tutorialBox = await Hive.openBox<bool>('isTutorial');
  // 앱을 처음 실행하면 true 아니면 false
  bool isFirstRun = tutorialBox.get('isTutorial', defaultValue: false) == false;

  // 다음 실행때는 나오지 않도록 값을 넣어줍니다.
  if (isFirstRun) {
    await tutorialBox.put('isTutorial', true);
  }
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
      ],
      child: ThemeInitialze(
        // ThemeInitialze 커스텀 위젯을 통해 Theme 테마 가져옵니다
        child: Consumer<ChangeThemeMode>(
          builder: (context, changeMode, child) => PageRouteSelection(
            isFirstRun: isFirstRun, // isFirstRun을 전달 해줍니다.
          ),
        ),
      ),
    ),
  );
}

class PageRouteSelection extends StatefulWidget {
  final bool isFirstRun;
  const PageRouteSelection({required this.isFirstRun, super.key});

  @override
  State<PageRouteSelection> createState() => _NavigationBarAppState();
}

class _NavigationBarAppState extends State<PageRouteSelection> {
  bool isFirstRun = false; // 부모에게 받기 위한 상태변수

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove(); // 한곳에서 SplashScreen을 닫게 합니다.
    isFirstRun = widget.isFirstRun;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KSL MUSIC',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ChangeThemeMode>(context).themeData,
      // 글로벌 ScaffoldMessenger 키 설정
      scaffoldMessengerKey: GlobalSnackBar.key,
      home: isFirstRun
          ? DopeScreen(
              nextMainPage: () {
                setState(() {
                  isFirstRun = !isFirstRun;
                });
              },
            )
          : MainScreen(),
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
      body: <Widget>[
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
