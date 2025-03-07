import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kls_project/model/ChangeThemeMode.dart';
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
      home: const NavigationExample()),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

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
        title: Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            onPressed:
                Provider.of<ChangeThemeMode>(context).toggleBrightnessMode,
            icon: Icon(
              Provider.of<ChangeThemeMode>(context).themeData == whiteMode()
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          )
        ],
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
        SafeArea(
          child: Center(
            child: Text('검색',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),
        ),

        // 검색 페이지
        SafeArea(
          child: Center(
            child: Text('설정',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),
        ),
      ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(CupertinoIcons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.double_music_note),
            label: '음악',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.search),
            label: '검색',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
