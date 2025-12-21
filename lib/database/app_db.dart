import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'db_tables.dart';

part 'app_db.g.dart';

@DriftDatabase(tables: [Vocabulary, VCategory])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // categoryIdをnullableに変更するため、テーブルを再作成
            // 1. 一時テーブルを作成
            await customStatement(
              'CREATE TABLE vocabulary_temp ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
              'word TEXT NOT NULL, '
              'definition TEXT NOT NULL, '
              'example_sentence TEXT, '
              'mastered INTEGER NOT NULL DEFAULT 0, '
              'category_id INTEGER, '
              'created_at INTEGER NOT NULL, '
              'updated_at INTEGER NOT NULL, '
              'FOREIGN KEY (category_id) REFERENCES v_category (id) ON DELETE SET NULL'
              ')',
            );

            // 2. データをコピー
            await customStatement(
              'INSERT INTO vocabulary_temp (id, word, definition, example_sentence, mastered, category_id, created_at, updated_at) '
              'SELECT id, word, definition, example_sentence, mastered, category_id, created_at, updated_at FROM vocabulary',
            );

            // 3. 元のテーブルを削除
            await m.drop(vocabulary);

            // 4. 一時テーブルをリネーム
            await customStatement('ALTER TABLE vocabulary_temp RENAME TO vocabulary');
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'vocabulary_database',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}