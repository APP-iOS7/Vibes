import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DopeScreen extends StatefulWidget {
  final VoidCallback nextMainPage;
  const DopeScreen({required this.nextMainPage, super.key});

  @override
  State<DopeScreen> createState() => _DopeScreenState();
}

class _DopeScreenState extends State<DopeScreen> {
  bool isScrollEnd = false;
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF606060),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int value) {
              setState(() {
                isScrollEnd = (value == 2);
              });
            },
            children: [
              _customPageView(intro: "검색은 총 20개의 데이터만 가져옵니다.", index: 1),
              _customPageView(intro: "다운로드 한 음원은 앱 삭제시 꼭 지워주세요", index: 2),
              _customPageView(intro: "마지막으로 다크모드는 시스템의 영향을 받습니다", index: 3),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => _pageController.jumpToPage(2),
                  child:
                      const Text("건너뛰기", style: TextStyle(color: Colors.white)),
                ),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    dotColor: Colors.white.withValues(alpha: 0.5),
                    activeDotColor: Colors.white,
                  ),
                ),
                isScrollEnd
                    ? GestureDetector(
                        onTap: widget.nextMainPage,
                        child: const Text("이동",
                            style: TextStyle(color: Colors.white)),
                      )
                    : GestureDetector(
                        onTap: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        ),
                        child: const Text("다음",
                            style: TextStyle(color: Colors.white)),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 첫번째 스크롤 페이지
  Column _customPageView({required int index, required String intro}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(intro,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white)),
        Container(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 70),
          child: Image.asset("assets/images/dope$index.jpeg"),
        ),
      ],
    );
  }
}
