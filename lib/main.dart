import 'package:flutter/material.dart';
import 'package:otsukare_app/screens/main_navigation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'お疲れさん',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 💡 起動時は MainNavigationScreen（下部メニュー付きの土台）を表示し、
      //    その中で「投稿」タブを初期選択する
      home: const MainNavigationScreen(),
    );
  }
}
