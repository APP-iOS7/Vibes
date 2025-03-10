import 'package:flutter/material.dart';

class GlobalSnackBar {
  // 앱 전체에서 사용할 글로벌 키
  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // 글로벌 키 getter
  static GlobalKey<ScaffoldMessengerState> get key => _scaffoldMessengerKey;

  // SnackBar 표시 메서드
  static void show(String message, {bool isSuccess = true}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
