import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otsukare_app/screens/post_comments_sheet.dart';

class TimelineScreen extends StatefulWidget {
  final String nickname;

  const TimelineScreen({super.key, required this.nickname});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  // 💡 投稿が無限に増えても一度に全件取得しないよう上限を設ける
  static const int _fetchLimit = 100;
  static const Duration _networkTimeout = Duration(seconds: 15);

  // 💡 連打防止用：処理中の投稿IDを保持する
  final Set<String> _togglingOtsukaresamaIds = {};
  final Set<String> _deletingPostIds = {};

  // 💡 「1日」の区切りを深夜3時とする。
  //    現在時刻が3時より前なら、まだ「前日のセッション」中とみなし、
  //    昨日の3時を起点にする（夜更かし勢向けの日付の考え方）
  DateTime _getTodayCutoff() {
    final DateTime now = DateTime.now();
    DateTime cutoff = DateTime(now.year, now.month, now.day, 3, 0, 0);
    if (now.isBefore(cutoff)) {
      cutoff = cutoff.subtract(const Duration(days: 1));
    }
    return cutoff;
  }

  // 💡 intlパッケージを追加せず、シンプルな相対時刻表示を自前で組み立てる
  String _formatTime(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'たった今';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分前';
    if (diff.inHours < 24) return '${diff.inHours}時間前';
    if (diff.inDays < 7) return '${diff.inDays}日前';
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  // ==========================================
  // 💡 お疲れ様ボタン（トグル式のリアクション）
  //    投稿ドキュメント自身の 'otsukaresamaBy' 配列に、押した人のuidを
  //    追加/削除するだけのシンプルな実装。カウントは配列の要素数で表す
  // ==========================================
  Future<void> _toggleOtsukaresama(String postId, bool currentlyTapped) async {
    if (_togglingOtsukaresamaIds.contains(postId)) return;
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _togglingOtsukaresamaIds.add(postId));

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update({
            'otsukaresamaBy': currentlyTapped
                ? FieldValue.arrayRemove([uid])
                : FieldValue.arrayUnion([uid]),
          })
          .timeout(_networkTimeout);
    } catch (e) {
      debugPrint('お疲れ様処理エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('処理に失敗しました。もう一度お試しください。')));
      }
    } finally {
      if (mounted) setState(() => _togglingOtsukaresamaIds.remove(postId));
    }
  }

  // ==========================================
  // 💡 投稿の削除（投稿者本人のみ）
  // ==========================================
  Future<void> _confirmAndDeletePost(String postId) async {
    if (_deletingPostIds.contains(postId)) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('投稿を削除しますか？'),
        content: const Text('この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '削除する',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _deletingPostIds.add(postId));

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .delete()
          .timeout(_networkTimeout);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('投稿を削除しました')));
      }
    } catch (e) {
      debugPrint('投稿削除エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('削除に失敗しました。もう一度お試しください。')));
      }
    } finally {
      if (mounted) setState(() => _deletingPostIds.remove(postId));
    }
  }

  // ==========================================
  // 💡 コメント一覧・投稿用のボトムシートを開く
  // ==========================================
  void _openComments(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          PostCommentsSheet(postId: postId, myNickname: widget.nickname),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime cutoff = _getTodayCutoff();
    final String? myUid = FirebaseAuth.instance.currentUser?.uid;

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
              final String postId = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;
              final String text = (data['text'] ?? '').toString();
              final String nickname = (data['nickname'] ?? '匿名').toString();
              final String postUid = (data['uid'] ?? '').toString();
              final Timestamp? createdAt = data['createdAt'] as Timestamp?;
              final String timeStr = createdAt != null
                  ? _formatTime(createdAt.toDate())
                  : '';

              // 💡 投稿はストリームで常に最新のデータが来るため、
              //    'otsukaresamaBy'配列は別途購読しなくてもここで直接参照できる
              final List<dynamic> otsukaresamaBy =
                  data['otsukaresamaBy'] as List? ?? [];
              final bool iTapped =
                  myUid != null && otsukaresamaBy.contains(myUid);
              final bool isMyPost = myUid != null && postUid == myUid;
              final bool isDeleting = _deletingPostIds.contains(postId);

              return Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- ヘッダー：アバター・ニックネーム・時刻 ---
                    Row(
                      children: [
                        _NicknameAvatar(nickname: nickname),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            nickname,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (isMyPost) ...[
                          const SizedBox(width: 4),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: isDeleting
                                ? null
                                : () => _confirmAndDeletePost(postId),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: isDeleting
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // --- 本文 ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(42, 8, 4, 4),
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --- アクション行：お疲れ様・コメント（ピル型チップ） ---
                    Padding(
                      padding: const EdgeInsets.only(left: 38),
                      child: Row(
                        children: [
                          _ActionChip(
                            icon: iTapped
                                ? Icons.favorite
                                : Icons.favorite_border,
                            label: otsukaresamaBy.isEmpty
                                ? 'お疲れ様'
                                : '${otsukaresamaBy.length}',
                            color: iTapped ? Colors.pinkAccent : null,
                            onTap: _togglingOtsukaresamaIds.contains(postId)
                                ? null
                                : () => _toggleOtsukaresama(postId, iTapped),
                          ),
                          const SizedBox(width: 8),
                          // 💡 cloud_firestoreのバージョンによっては
                          //    count().snapshots()（集計クエリのリアルタイム購読）が
                          //    使えないため、コレクション自体を購読して件数を数える方式にする
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .doc(postId)
                                .collection('comments')
                                .snapshots(),
                            builder: (context, commentSnap) {
                              final int count =
                                  commentSnap.data?.docs.length ?? 0;
                              return _ActionChip(
                                icon: Icons.chat_bubble_outline,
                                label: count == 0 ? 'コメント' : '$count',
                                onTap: () => _openComments(postId),
                              );
                            },
                          ),
                        ],
                      ),
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

// 💡 ニックネームの頭文字を、名前ごとに一定の色で表示する簡易アバター。
//    プロフィール画像の仕組みがないアプリなので、視覚的な見分けやすさを補う
class _NicknameAvatar extends StatelessWidget {
  final String nickname;

  const _NicknameAvatar({required this.nickname});

  static const List<Color> _palette = [
    Color(0xFF7C4DFF),
    Color(0xFF26A69A),
    Color(0xFFFF7043),
    Color(0xFF42A5F5),
    Color(0xFFEC407A),
    Color(0xFF9CCC65),
    Color(0xFFFFA726),
  ];

  @override
  Widget build(BuildContext context) {
    final String trimmed = nickname.trim();
    final String initial = trimmed.isNotEmpty ? trimmed.substring(0, 1) : '?';
    final Color color = _palette[nickname.hashCode.abs() % _palette.length];

    return CircleAvatar(
      radius: 15,
      backgroundColor: color.withOpacity(0.15),
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

// 💡 お疲れ様・コメントボタン共通の、ピル型チップデザイン
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? Colors.grey[600]!;
    final Color backgroundColor = color != null
        ? color!.withOpacity(0.1)
        : Colors.grey[100]!;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: effectiveColor),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: effectiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
