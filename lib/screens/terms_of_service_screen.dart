import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const String _effectiveDate = '2026年1月1日';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '利用規約',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'お疲れさんAPP 利用規約',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '施行日：$_effectiveDate',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            const _Body(
              text:
                  '本利用規約（以下「本規約」といいます）は、〔運営者名〕（以下「当方」といいます）が提供するアプリケーション'
                  '「お疲れさんAPP」（以下「本アプリ」といいます）の利用条件を定めるものです。'
                  '本アプリをご利用いただく方（以下「ユーザー」といいます）には、本規約に従ってご利用いただきます。',
            ),

            const _Section(
              title: '第1条（本アプリの内容）',
              body:
                  '本アプリは、ユーザーが匿名で日々の出来事やひとことメッセージを投稿し、'
                  '当日中（深夜3時から翌深夜3時まで）に限り、他のユーザーと共有できるサービスです。'
                  '投稿は日付が変わるタイミングでタイムラインの表示対象から外れます。',
            ),

            const _Section(
              title: '第2条（利用登録・ニックネーム）',
              body:
                  '1. 本アプリの利用にあたり、匿名でのログインおよびニックネームの登録を行っていただきます。\n'
                  '2. ニックネームは登録後の変更ができません。本名その他個人を特定しうる情報をニックネームや投稿内容に含めないようご注意ください。\n'
                  '3. 当方は、不適切なニックネームや投稿があると判断した場合、ユーザーへの通知なく利用を制限できるものとします。',
            ),

            const _Section(
              title: '第3条（禁止事項）',
              body:
                  'ユーザーは、本アプリの利用にあたり、以下の行為をしてはなりません。\n\n'
                  '1. 法令または公序良俗に違反する行為\n'
                  '2. 他者に対する誹謗中傷、脅迫、嫌がらせ\n'
                  '3. 自己または第三者の個人情報（氏名、連絡先、住所等）を投稿する行為\n'
                  '4. 犯罪行為を助長し、または関連する投稿\n'
                  '5. わいせつ、暴力的、差別的な内容を含む投稿\n'
                  '6. 営業、宣伝、勧誘、スパムを目的とした投稿\n'
                  '7. 本アプリのシステムに不正にアクセスし、またはその運営を妨害する行為\n'
                  '8. その他、当方が不適切と判断する行為',
            ),

            const _Section(
              title: '第4条（投稿内容の取扱い）',
              body:
                  '1. ユーザーが投稿した内容にかかる著作権は、ユーザー本人に帰属します。\n'
                  '2. 当方は、本アプリの提供・運営に必要な範囲で投稿内容を利用（複製、表示等）できるものとします。\n'
                  '3. 投稿はタイムライン上での表示期間（当日中）を過ぎると一覧から表示されなくなります。'
                  'ただし、システム上のバックアップ等の事情により、一定期間サーバー内にデータが残存する場合があります。\n'
                  '4. 当方は、第3条の禁止事項に該当すると判断した投稿について、ユーザーへの事前の通知なく削除できるものとします。',
            ),

            const _Section(
              title: '第5条（利用制限）',
              body:
                  '当方は、ユーザーが本規約に違反したと判断した場合、事前の通知なく、当該ユーザーの本アプリの利用を制限できるものとします。',
            ),

            const _Section(
              title: '第6条（保証の否認および免責事項）',
              body:
                  '1. 当方は、本アプリに事実上または法律上の瑕疵がないことを保証するものではありません。\n'
                  '2. 当方は、本アプリの利用によりユーザーに生じた損害について、当方の故意または重過失による場合を除き、一切の責任を負いません。\n'
                  '3. ユーザー間、またはユーザーと第三者との間で生じたトラブルについて、当方は一切の責任を負いません。',
            ),

            const _Section(
              title: '第7条（サービス内容の変更・終了）',
              body: '当方は、ユーザーへの事前の告知をもって、本アプリの内容を変更し、または提供を終了することがあります。',
            ),

            const _Section(
              title: '第8条（本規約の変更）',
              body:
                  '当方は、必要と判断した場合には、ユーザーへの通知なく本規約を変更できるものとします。'
                  '変更後も本アプリの利用を継続した場合、変更後の規約に同意したものとみなします。',
            ),

            const _Section(
              title: '第9条（準拠法）',
              body: '本規約の解釈にあたっては、日本法を準拠法とします。',
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              '以上',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.7,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.7,
          color: Colors.black87,
        ),
      ),
    );
  }
}
