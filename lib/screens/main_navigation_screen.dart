import 'package:flutter/material.dart';
import 'package:otsukare_app/screens/home_screen.dart';
import 'package:otsukare_app/screens/post_screen.dart';
import 'package:otsukare_app/screens/timeline_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // 💡 タブの並び: [0]タイムライン [1]投稿 [2]ホーム
  //    アプリ起動時は「投稿」を自動で選択した状態にする
  int _currentIndex = 1;

  // 💡 IndexedStackを使うことで、タブを切り替えても各画面の状態
  //    （入力中のテキストやスクロール位置など）が保持される
  final List<Widget> _pages = const [
    TimelineScreen(),
    PostScreen(),
    HomeScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'タイムライン',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: '投稿',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
        ],
      ),
    );
  }
}
