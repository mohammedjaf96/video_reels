import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_reels/video_reels.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video reels',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ReelsPlayer(
          urls: // list of url => RxList<String> ,
          animatedIcon: true,
        ),
      ),
    );
  }
}