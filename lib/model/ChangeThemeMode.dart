import 'package:flutter/material.dart';
import 'package:kls_project/theme/theme.dart';

class ChangeThemeMode extends ChangeNotifier {
  ThemeData? _themeData; // 내부에서만 사용 가능한 themeData

  // get
  ThemeData get themeData => _themeData ?? darkMode();

  /// set
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // method
  void initializeTheme(BuildContext context) {
    if (_themeData == null) {
      // 현재 시스템의 테마 가져오기
      final Brightness brightness = MediaQuery.of(context).platformBrightness;

      if (brightness == Brightness.dark) {
        // 테마가 darkMode 라면 darkMode 변경
        _themeData = darkMode();
      } else {
        _themeData = whiteMode();
      }
    }
    notifyListeners();
  }

  void toggleBrightnessMode() {
    if (_themeData == darkMode()) {
      _themeData = whiteMode();
    } else {
      _themeData = darkMode();
    }

    notifyListeners();
  }
}
