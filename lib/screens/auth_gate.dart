import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otsukare_app/screens/main_navigation_screen.dart';
import 'package:otsukare_app/screens/nickname_screen.dart';

/// 💡 アプリ起動時に必ず最初に表示されるゲート役のウィジェット。
///    1. まだログインしていなければ匿名ログインを行う
///    2. ログイン済みユーザーのニックネームが未設定なら、ニックネーム入力画面を表示
///    3. 設定済みならメイン画面（タイムライン・投稿・ホーム）を表示
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  static const Duration _networkTimeout = Duration(seconds: 20);

  bool _isSigningIn = false;
  String? _signInError;

  @override
  void initState() {
    super.initState();
    _ensureSignedIn();
  }

  Future<void> _ensureSignedIn() async {
    // 💡 既にログイン済み（前回起動時の匿名アカウントが端末に残っている）なら何もしない
    if (FirebaseAuth.instance.currentUser != null) return;

    setState(() {
      _isSigningIn = true;
      _signInError = null;
    });

    try {
      await FirebaseAuth.instance.signInAnonymously().timeout(_networkTimeout);
    } catch (e) {
      debugPrint('匿名ログインエラー: $e');
      if (mounted) {
        setState(() {
          _signInError = 'ログインに失敗しました。通信環境をご確認のうえ、もう一度お試しください。';
        });
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 ログイン処理中、またはログイン失敗時の表示
    if (_isSigningIn) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_signInError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _signInError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _ensureSignedIn,
                  child: const Text('再試行する'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 💡 ログイン状態を継続的に監視する（自動ログイン完了を検知するため）
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final User? user = authSnapshot.data;
        if (user == null) {
          // 💡 何らかの理由でまだサインインできていない場合は待機表示
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 💡 ニックネームが設定済みかどうかをFirestoreでリアルタイムに確認する。
        //    ニックネーム画面で保存が完了した瞬間、このストリームが自動的に
        //    更新を検知し、明示的な画面遷移コードなしでメイン画面に切り替わる
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasError) {
              return const Scaffold(body: Center(child: Text('エラーが発生しました')));
            }

            final data = userSnapshot.data?.data() as Map<String, dynamic>?;
            final String? nickname = data?['nickname'] as String?;

            if (nickname == null || nickname.trim().isEmpty) {
              return const NicknameScreen();
            }

            return MainNavigationScreen(nickname: nickname);
          },
        );
      },
    );
  }
}
