import 'package:flutter/material.dart';

// 튜토리얼 오버레이 화면을 보여주는 위젯
class DopeScreen extends StatelessWidget {
  final VoidCallback nextMainPage; // nextMainPage 콜백 추가

  const DopeScreen({Key? key, required this.nextMainPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: nextMainPage, // 콜백 실행
          child: Text("튜토리얼 완료"),
        ),
      ),
    );
  }
}

class TutorialOverlayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경을 반투명한 검은색으로 설정하여 오버레이 효과 적용
          Positioned.fill(
            child: Opacity(
              opacity: 0.7,
              child: Container(color: Colors.black),
            ),
          ),
          // 화살표와 설명이 포함된 박스를 특정 위치에 배치
          Positioned(
            top: MediaQuery.of(context).size.height * 0.55,
            left: MediaQuery.of(context).size.width * 0.2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 화살표를 그림으로 표시
                CustomPaint(
                  size: Size(100, 50),
                  painter: ArrowPainter(),
                ),
                // 설명 텍스트가 포함된 박스
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "이 버튼을 눌러 음악을 검색하세요!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // 튜토리얼 종료 버튼
          Positioned(
            bottom: 50,
            left: MediaQuery.of(context).size.width * 0.25,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context), // 버튼 클릭 시 화면 닫기
              child: Text("튜토리얼 종료"),
            ),
          ),
        ],
      ),
    );
  }
}

// 화살표를 그리는 커스텀 페인터 클래스
class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white // 화살표 색상 설정
      ..strokeWidth = 5 // 선 두께 설정
      ..style = PaintingStyle.stroke; // 선 스타일 설정

    final path = Path()
      ..moveTo(size.width, size.height) // 시작점 설정
      ..lineTo(size.width / 2, 0) // 위쪽 끝점으로 선을 그림
      ..lineTo(0, size.height); // 왼쪽 끝점으로 선을 그림

    canvas.drawPath(path, paint); // 캔버스에 화살표 그리기
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      false; // 화살표는 변하지 않으므로 false 반환
}
