import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Vibes/model/ChangeThemeMode.dart';
import 'package:Vibes/theme/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          // 다크모드 설정 Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF3C3C3C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.dark_mode_rounded, size: 30, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "다크 모드",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                Consumer<ChangeThemeMode>(
                  builder: (context, themeMode, child) {
                    final isDarkMode = themeMode.themeData != whiteMode();

                    return CustomSwitch(
                      value: isDarkMode,
                      onChanged: (value) {
                        themeMode.toggleBrightnessMode();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 70,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value ? Colors.blue : Colors.grey.shade300,
        ),
        child: Stack(
          children: [
            // ON/OFF 텍스트
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'ON',
                    style: TextStyle(
                      color: value ? Colors.white : Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'OFF',
                    style: TextStyle(
                      color: value ? Colors.grey.shade700 : Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // 슬라이딩 원형 버튼
            AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 35 : 0,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
