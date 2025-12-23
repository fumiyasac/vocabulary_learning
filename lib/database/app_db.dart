import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'db_tables.dart';

// part文：コード生成ツールが生成したファイルを読み込む
// build_runnerコマンドを実行すると、app_db.g.dartファイルが自動生成されます
part 'app_db.g.dart';

// @DriftDatabaseアノテーション：このクラスがDriftデータベースであることを示す
// tables: [Vocabulary, VCategory]：このデータベースが使用するテーブルを指定
@DriftDatabase(tables: [Vocabulary, VCategory])
class AppDb extends _$AppDb {
  // コンストラクタ：データベース接続を初期化
  // _openConnection()は下記で定義した静的メソッドを呼び出す
  AppDb() : super(_openConnection());

  // schemaVersion：データベーススキーマのバージョン番号
  // テーブル構造を変更したら、この番号を増やす必要があります
  // 現在はバージョン2（カテゴリIDをnullableに変更した後）
  @override
  int get schemaVersion => 2;

  // MigrationStrategy：データベースのマイグレーション（スキーマ変更）戦略を定義
  // データベースのバージョンが変わったときに、既存のデータを保持しながら
  // テーブル構造を変更する方法を指定します
  @override
  MigrationStrategy get migration => MigrationStrategy(
    // onCreate：データベースが初めて作成されるときに実行される処理
    // 新規インストール時に全テーブルを作成します
    onCreate: (Migrator m) async {
      // createAll()：定義されているすべてのテーブルを作成
      await m.createAll();
    },
    // onUpgrade：既存のデータベースを新しいバージョンにアップグレードするときの処理
    // from：現在のバージョン番号、to：新しいバージョン番号
    onUpgrade: (Migrator m, int from, int to) async {
      // バージョン1からバージョン2へのアップグレード処理
      if (from < 2) {
        // 目的：categoryIdカラムをnullableに変更する
        // SQLiteではカラムの属性を直接変更できないため、テーブル全体を再作成する必要があります

        // ステップ1：新しい構造の一時テーブルを作成
        // category_idをINTEGER（nullableなので NOT NULL なし）として定義
        await customStatement(
          'CREATE TABLE vocabulary_temp ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
              'word TEXT NOT NULL, '
              'definition TEXT NOT NULL, '
              'example_sentence TEXT, '
              'mastered INTEGER NOT NULL DEFAULT 0, '
              'category_id INTEGER, ' // nullableにするためNOT NULL制約なし
              'created_at INTEGER NOT NULL, '
              'updated_at INTEGER NOT NULL, '
              'FOREIGN KEY (category_id) REFERENCES v_category (id) ON DELETE SET NULL' // 外部キー制約
              ')',
        );

        // ステップ2：既存のデータを一時テーブルにコピー
        // すべてのカラムのデータを新しいテーブルに移行
        await customStatement(
          'INSERT INTO vocabulary_temp (id, word, definition, example_sentence, mastered, category_id, created_at, updated_at) '
              'SELECT id, word, definition, example_sentence, mastered, category_id, created_at, updated_at FROM vocabulary',
        );

        // ステップ3：古いテーブルを削除
        await m.drop(vocabulary);

        // ステップ4：一時テーブルを本来の名前にリネーム
        // これでマイグレーションが完了し、既存のデータは保持されます
        await customStatement('ALTER TABLE vocabulary_temp RENAME TO vocabulary');
      }
    },
  );

  // _openConnection：データベース接続を作成する静的メソッド
  // QueryExecutor：Driftがデータベースクエリを実行するためのインターフェース
  static QueryExecutor _openConnection() {
    // driftDatabase()：プラットフォームに応じた最適なデータベース実装を返す
    // - モバイル（iOS/Android）：ネイティブのSQLiteを使用
    // - Web：WebAssembly版のSQLiteを使用
    return driftDatabase(
      name: 'vocabulary_database', // データベースファイルの名前
      // web：Webプラットフォーム用の設定（Webアプリとして実行する場合に必要）
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'), // SQLiteのWebAssemblyファイル
        driftWorker: Uri.parse('drift_worker.js'), // バックグラウンドで動作するワーカースクリプト
      ),
    );
  }
}
