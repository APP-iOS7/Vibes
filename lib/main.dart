import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(const NavigationBarApp());

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(useMaterial3: true), home: const NavigationExample());
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
            child: Text('검색',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),
        ),
      ][currentPageIndex],
    );
  }
}
