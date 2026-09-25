import 'package:flutter/material.dart';
import 'package:otsukare_app/screens/terms_of_service_screen.dart';

class HomeScreen extends StatelessWidget {
  final String nickname;

  const HomeScreen({super.key, required this.nickname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              'ようこそ、$nicknameさん',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '今日もお疲れさまです。使い方をかんたんにご紹介します。',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            _GuideCard(
              icon: Icons.edit_note,
              title: '投稿する',
              description:
                  '「投稿」タブから、今日あったことや、ひとことお疲れさまメッセージを自由に書き込めます。'
                  '投稿すると、あなたのニックネーム付きでタイムラインに表示されます。',
            ),
            const SizedBox(height: 16),

            _GuideCard(
              icon: Icons.timeline,
              title: 'タイムラインについて',
              description:
                  '「タイムライン」タブでは、みんなの投稿を新しい順に見ることができます。'
                  '表示されるのは常に「今日（深夜3時〜翌深夜3時）」の投稿だけです。'
                  '日付が変わると（深夜3時になると）、タイムラインの表示は自動的にリセットされ、新しい1日の投稿だけが表示されます。',
            ),
            const SizedBox(height: 16),

            _GuideCard(
              icon: Icons.badge_outlined,
              title: 'ニックネームについて',
              description:
                  '最初に決めたニックネームは、後から変更することはできません。'
                  '本名や個人が特定できる情報は入力しないようにしてください。',
            ),
            const SizedBox(height: 16),

            _GuideCard(
              icon: Icons.shield_outlined,
              title: '安心してご利用いただくために',
              description:
                  '誹謗中傷や個人情報の投稿、法令に違反する内容の投稿はお控えください。'
                  '詳しいルールは下記の利用規約をご確認ください。',
            ),

            const SizedBox(height: 32),

            // --- 利用規約への導線 ---
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsOfServiceScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.description_outlined),
              label: const Text('利用規約を見る'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GuideCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
