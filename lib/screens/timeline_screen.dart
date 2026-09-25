import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  // 💡 投稿が無限に増えても一度に全件取得しないよう上限を設ける
  static const int _fetchLimit = 100;

  // 💡 「1日」の区切りを深夜3時とする。
  //    現在時刻が3時より前なら、まだ「前日のセッション」中とみなし、
  //    昨日の3時を起点にする（夜更かし勢向けの日付の考え方）
  static DateTime _getTodayCutoff() {
    final DateTime now = DateTime.now();
    DateTime cutoff = DateTime(now.year, now.month, now.day, 3, 0, 0);
    if (now.isBefore(cutoff)) {
      cutoff = cutoff.subtract(const Duration(days: 1));
    }
    return cutoff;
  }

  // 💡 intlパッケージを追加せず、シンプルな相対時刻表示を自前で組み立てる
  static String _formatTime(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'たった今';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分前';
    if (diff.inHours < 24) return '${diff.inHours}時間前';
    if (diff.inDays < 7) return '${diff.inDays}日前';
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime cutoff = _getTodayCutoff();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'タイムライン',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 💡 直近の午前3時以降に投稿されたものだけを取得する。
        //    実データを消去しているわけではなく、「表示範囲」を絞ることで
        //    「常に今日の投稿だけが見える」状態を実現している
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff),
            )
            .orderBy('createdAt', descending: true)
            .limit(_fetchLimit)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('エラーが発生しました'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timeline_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      '今日はまだ投稿がありません',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '「投稿」タブから最初の投稿をしてみましょう',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String text = (data['text'] ?? '').toString();
              final String nickname = (data['nickname'] ?? '匿名').toString();
              final Timestamp? createdAt = data['createdAt'] as Timestamp?;
              final String timeStr = createdAt != null
                  ? _formatTime(createdAt.toDate())
                  : '';

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nickname,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      text,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
