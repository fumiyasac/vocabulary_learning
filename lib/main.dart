import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/vocabulary_home.dart';

// アプリケーションのエントリーポイント
// Flutterアプリはこの関数から実行が始まります
void main() {
  // runApp()はFlutterアプリを起動する関数
  runApp(
    // ProviderScopeはRiverpodの状態管理を使用するために必要なウィジェット
    // アプリ全体をProviderScopeで囲むことで、どこからでもProviderにアクセス可能になります
    const ProviderScope(
      child: VocabularyApp(),
    ),
  );
}

// VocabularyAppはアプリのルートウィジェット
// StatelessWidgetは状態を持たないウィジェット（再ビルド時に内部の値が変わらない）
class VocabularyApp extends StatelessWidget {
  const VocabularyApp({super.key});

  // buildメソッドはウィジェットのUIを構築するメソッド
  // このメソッドが返すウィジェットツリーが画面に表示されます
  @override
  Widget build(BuildContext context) {
    // MaterialAppはマテリアルデザインを使用するFlutterアプリのベースウィジェット
    // テーマ、ナビゲーション、ローカライゼーションなどの設定を一元管理します
    return MaterialApp(
      title: 'Vocabulary Learning App', // アプリのタイトル（タスクスイッチャーなどで表示される）
      debugShowCheckedModeBanner: false, // 右上のデバッグバナーを非表示にする
      theme: _buildLightTheme(), // ライトモードのテーマ設定
      darkTheme: _buildDarkTheme(), // ダークモードのテーマ設定
      themeMode: ThemeMode.system, // システムの設定に従ってテーマを切り替え
      home: const VocabularyHome(), // アプリの最初に表示される画面
    );
  }

  // ライトモード用のテーマデータを構築するメソッド
  ThemeData _buildLightTheme() {
    // シードカラー：このカラーを基準にして、アプリ全体のカラーパレットが自動生成されます
    const seedColor = Color(0xFF6750A4); // Material Design 3の紫色

    // ColorScheme.fromSeedを使用して、シードカラーから調和の取れたカラースキームを生成
    // これにより、primary、secondary、surface、errorなどの色が自動的に決定されます
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light, // ライトモード用の明るい配色
    );

    // ThemeDataはアプリ全体のテーマ設定を保持するクラス
    return ThemeData(
      useMaterial3: true, // Material Design 3を使用（最新のデザインシステム）
      colorScheme: colorScheme, // 生成したカラースキームを適用
      scaffoldBackgroundColor: colorScheme.surface, // 画面の背景色を設定
      // AppBarTheme：アプリバー（画面上部のバー）のデフォルトスタイルを設定
      appBarTheme: AppBarTheme(
        elevation: 0, // 影の高さを0に（フラットデザイン）
        centerTitle: true, // タイトルを中央揃えにする
        backgroundColor: colorScheme.primary, // プライマリカラーを背景色に
        foregroundColor: colorScheme.onPrimary, // テキストとアイコンの色
      ),
      // CardTheme：カードウィジェットのデフォルトスタイルを設定
      cardTheme: CardThemeData(
        elevation: 2, // カードの影の高さ（立体感）
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // 角を丸くする（半径16px）
        ),
        clipBehavior: Clip.antiAlias, // カードの角を滑らかにクリップ
      ),
      // InputDecorationTheme：テキストフィールドのデフォルトスタイルを設定
      inputDecorationTheme: InputDecorationTheme(
        filled: true, // 背景を塗りつぶす
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // 枠線の角を丸くする
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, // 左右のパディング
          vertical: 16, // 上下のパディング
        ),
      ),
      // ElevatedButtonTheme：立体的なボタンのデフォルトスタイルを設定
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2, // ボタンの影の高さ
          padding: const EdgeInsets.symmetric(
            horizontal: 24, // 左右のパディング
            vertical: 12, // 上下のパディング
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 角を丸くする
          ),
          textStyle: const TextStyle(
            fontSize: 16, // フォントサイズ
            fontWeight: FontWeight.w600, // フォントの太さ（セミボールド）
            letterSpacing: 0.5, // 文字間隔
          ),
        ),
      ),
      // FilledButtonTheme：塗りつぶしボタンのデフォルトスタイルを設定
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      // FloatingActionButtonTheme：フローティングアクションボタン（FAB）のスタイルを設定
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4, // FABは他のボタンより高い影を持つ
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      // ChipTheme：チップウィジェット（タグのような小さなUI要素）のスタイルを設定
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      // DialogTheme：ダイアログ（ポップアップ）のスタイルを設定
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // ダイアログは大きめの角丸
        ),
        elevation: 8, // ダイアログは高い影を持つ（最前面に表示される）
      ),
      // SnackBarTheme：スナックバー（画面下部の通知）のスタイルを設定
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating, // 浮いているスタイル
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ダークモード用のテーマデータを構築するメソッド
  // 基本的な構造はライトモードと同じですが、brightness: Brightness.darkにすることで
  // ダークモード用の配色が自動生成されます
  ThemeData _buildDarkTheme() {
    const seedColor = Color(0xFF6750A4);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark, // ダークモード用の暗い配色
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}