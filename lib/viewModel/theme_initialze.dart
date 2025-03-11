import 'package:flutter/material.dart';
import 'package:kls_project/model/ChangeThemeMode.dart';
import 'package:provider/provider.dart';

class ThemeInitialze extends StatelessWidget {
  final Widget child;

  const ThemeInitialze({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // 앱의 시작부분에서 첫 프레임이 그려진 후 실행될 함수
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 시스템의 테마를 통해 앱의 메인 테마를 GET
      Provider.of<ChangeThemeMode>(context, listen: false)
          .initializeTheme(context);
    });
    return child;
  }
}




/// 
///
///
///
///
///
///
///