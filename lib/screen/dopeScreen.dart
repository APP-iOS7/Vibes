import 'package:flutter/material.dart';

class DopeScreen extends StatefulWidget {
  final VoidCallback nextMainPage;
  const DopeScreen({required this.nextMainPage, super.key});

  @override
  State<DopeScreen> createState() => _DopeScreenState();
}

class _DopeScreenState extends State<DopeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "dopeScreen입니다",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          ElevatedButton(onPressed: widget.nextMainPage, child: Text("다 읽은 경우"))
        ],
      ),
    ));
  }
}
