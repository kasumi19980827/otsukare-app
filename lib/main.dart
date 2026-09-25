import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:otsukare_app/screens/auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // 💡 Firebaseの初期化にはネイティブ側の準備が必要なため、
  //    runApp()より前に必ず完了させておく
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      // 💡 起動時は AuthGate が「匿名ログイン → ニックネーム確認」を
      //    自動的に行い、状況に応じて適切な画面を出し分ける
      home: const AuthGate(),
    );
  }
}
