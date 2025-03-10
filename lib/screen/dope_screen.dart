import 'package:flutter/material.dart';

class DopeScreen extends StatefulWidget {
  DopeScreen(void Function() goToNextPage);

  @override
  State<DopeScreen> createState() => _DopeScreenState();
}

class _DopeScreenState extends State<DopeScreen> {
  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          // 첫 번째 페이지 (이미지)
          Center(
            child: Image.asset(
              'assets/images/tutorial.png', // 실제 이미지 경로로 수정
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          // 두 번째 페이지 (텍스트 및 버튼)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "KLS MUSIC에 오신걸 환영합니다",
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "PLAYLIST에서 유튜브 영상을 통해 노래를 들어요",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // 다음 페이지로 이동
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                  child: Text("다음"),
                ),
              ],
            ),
          ),
          // 세 번째 페이지 (예시)
          Center(
            child: Text(
              "여기가 마지막입니다.",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ],
      ),
    );
  }
}
