import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  VoidCallback onChange;
  HomeScreen({required this.onChange, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(50),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // 모서리 둥글게 (20px)
                child: Image.asset("assets/images/splash_logo.png"),
              ),
            ),
          ),
          Text(
            "KLS MUSIC에 오신걸 환영합니다",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 10),
          Text(
            "PLAYLIST에서 유튜브 영상을 통해 노래를 들어요",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: widget.onChange,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Text(
                "음악 검색 하러 가기",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
