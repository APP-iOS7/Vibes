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
import 'package:kls_project/screen/dopeScreen.dart';
import 'package:kls_project/services/PlayListState.dart';
import 'package:kls_project/services/YoutubeSearchState.dart';
import 'package:kls_project/theme/theme.dart';
import 'package:kls_project/viewModel/theme_initialze.dart';
import 'package:provider/provider.dart';
import 'screen/dope_screen.dart'; // DopeScreen import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KLS Music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(), // MainScreen을 홈 화면으로 설정
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPageIndex = 0;
  String titleName = "KLS MUSIC";

  void goToNextPage() {
    // DopeScreen으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        var dopeScreen = newMethod;
        return newMethod(dopeScreen);
      }),
    );
  }

  newMethod(dopeScreen) => dopeScreen(nextMainPage: goToNextPage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleName),
      ),
      body: // 여기에 현재 페이지에 따라 다른 위젯을 표시하는 로직을 추가
          // 예시로 HomeScreen을 보여줍니다.
          HomeScreen(
        onChange: () {},
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
            // 제목 변경 로직
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: '음악'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}
