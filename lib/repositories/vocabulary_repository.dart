import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_db.dart';
import '../providers/database_provider.dart';

part 'vocabulary_repository.g.dart';

// VocabularyRepository：語彙データへのアクセスを管理するリポジトリクラス
// リポジトリパターン：データベース操作をカプセル化し、ビジネスロジックから分離する設計パターン
// これにより、データベースの詳細を隠蔽し、テストやメンテナンスが容易になります
class VocabularyRepository {
  // _db：データベースインスタンス（プライベートフィールド）
  final AppDb _db;

  // コンストラクタ：データベースインスタンスを受け取って初期化
  // 依存性注入（DI）パターンを使用しています
  VocabularyRepository(this._db);

  // getAllVocabularies：すべての語彙データを取得
  // Future<List<VocabularyData>>：非同期処理で語彙データのリストを返す
  Future<List<VocabularyData>> getAllVocabularies() async {
    // _db.select(_db.vocabulary)：vocabularyテーブルからデータを選択
    // .get()：クエリを実行してすべての行を取得
    // SQLに翻訳すると: SELECT * FROM vocabulary
    return await _db.select(_db.vocabulary).get();
  }

  // getVocabularyById：IDを指定して特定の語彙データを取得
  // nullableな戻り値（VocabularyData?）：該当データが見つからない場合はnullを返す
  Future<VocabularyData?> getVocabularyById(int id) async {
    try {
      return await (_db.select(_db.vocabulary)
      // ..where()：WHERE句を追加（カスケード演算子..を使用）
      // vocabulary.id.equals(id)：IDが一致する行を検索
      // SQLに翻訳すると: SELECT * FROM vocabulary WHERE id = ?
        ..where((vocabulary) => vocabulary.id.equals(id)))
      // getSingleOrNull()：1行だけ取得、見つからない場合はnullを返す
          .getSingleOrNull();
    } catch (e) {
      // エラーが発生した場合はnullを返す（安全なフォールバック）
      return null;
    }
  }

  // getVocabulariesByCategoryId：特定のカテゴリに属する語彙データをすべて取得
  Future<List<VocabularyData>> getVocabulariesByCategoryId(int categoryId) async {
    return await (_db.select(_db.vocabulary)
    // categoryId.equals(categoryId)：指定されたカテゴリIDと一致する行を検索
    // SQLに翻訳すると: SELECT * FROM vocabulary WHERE category_id = ?
      ..where((vocabulary) => vocabulary.categoryId.equals(categoryId)))
        .get();
  }

  // addVocabulary：新しい語彙データを追加
  // VocabularyCompanion：Driftが生成する挿入・更新用のデータクラス
  // 戻り値：新しく作成されたレコードのID
  Future<int> addVocabulary(VocabularyCompanion vocabulary) async {
    // into()：挿入先のテーブルを指定
    // insert()：データを挿入して、新しいIDを返す
    // SQLに翻訳すると: INSERT INTO vocabulary (...) VALUES (...)
    return await _db.into(_db.vocabulary).insert(vocabulary);
  }

  // updateVocabulary：既存の語彙データを更新
  // 戻り値：更新が成功したかどうか（true/false）
  Future<bool> updateVocabulary(VocabularyCompanion vocabulary) async {
    // update()：更新するテーブルを指定
    // replace()：指定されたIDのレコードを新しいデータで置き換える
    // SQLに翻訳すると: UPDATE vocabulary SET ... WHERE id = ?
    return await _db.update(_db.vocabulary).replace(vocabulary);
  }

  // deleteVocabulary：指定されたIDの語彙データを削除
  // 戻り値：削除された行数（通常は1、該当データがない場合は0）
  Future<int> deleteVocabulary(int id) async {
    return await (_db.delete(_db.vocabulary)
    // WHERE句で削除対象を指定
      ..where((vocabulary) => vocabulary.id.equals(id)))
    // go()：削除を実行
    // SQLに翻訳すると: DELETE FROM vocabulary WHERE id = ?
        .go();
  }

  // toggleMastered：語彙の習得状態を切り替える（習得済み ⇔ 未習得）
  // currentStatus：現在の習得状態
  // 戻り値：更新が成功したかどうか
  Future<bool> toggleMastered(int id, bool currentStatus) async {
    // まず対象の語彙データを取得
    final vocabulary = await getVocabularyById(id);
    // データが見つからない場合はfalseを返す
    if (vocabulary == null) return false;

    // 既存のデータをCompanionに変換して、masteredフィールドだけを反転
    return await updateVocabulary(
      // toCompanion(true)：既存のデータをVocabularyCompanionに変換
      vocabulary.toCompanion(true).copyWith(
        // copyWith()：特定のフィールドだけを変更した新しいインスタンスを作成
        // Value()：Driftで値を明示的に設定するためのラッパー
        mastered: Value(!currentStatus), // 現在の状態を反転（true → false、false → true）
      ),
    );
  }
}

// vocabularyRepositoryProvider：VocabularyRepositoryのインスタンスを提供するプロバイダー
// Riverpodの@riverpodアノテーションにより、このプロバイダーは自動生成されます
@riverpod
VocabularyRepository vocabularyRepository(Ref ref) {
  // ref.watch(databaseProvider)：データベースプロバイダーを監視
  // データベースインスタンスが変更されると、このプロバイダーも再構築されます
  final db = ref.watch(databaseProvider);
  // データベースインスタンスを使ってリポジトリを作成
  // これが依存性注入（DI）パターンの実装例です
  return VocabularyRepository(db);
}
