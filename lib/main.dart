import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kls_project/model/ChangeThemeMode.dart';
import 'package:kls_project/screen/SettingsScreen.dart';
import 'package:kls_project/screen/YoutubeSearchScreen.dart';
import 'package:kls_project/services/YoutubeSearchState.dart';
import 'package:kls_project/theme/theme.dart';
import 'package:kls_project/viewModel/theme_initialze.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 확장을 위해 멀티 Provider 사용
        ChangeNotifierProvider(create: (_) => ChangeThemeMode()),
        ChangeNotifierProvider(create: (_) => Youtubesearchstate()),
      ],
      child: ThemeInitialze(
        // ThemeInitialze 커스텀 위젯을 통해 Theme 테마 가져옵니다
        child: Consumer<ChangeThemeMode>(
          builder: (context, changeMode, child) => const NavigationBarApp(),
        ),
      ),
    ),
  );
}

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: Provider.of<ChangeThemeMode>(context).themeData,
      home: const NavigationExample(title: 'KLS Music'),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key, required this.title});

  final String title;

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title:
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
      ),
      body: <Widget>[
        /// Home page
        SafeArea(
          child: Center(
            child: Text('홈',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),
        ),

        // 음악재생 페이지
        SafeArea(
          child: Center(
            child: Text('음악재생',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),
        ),

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
