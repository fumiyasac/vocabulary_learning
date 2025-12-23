import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_db.dart';
import '../providers/database_provider.dart';

part 'category_repository.g.dart';

// CategoryRepository：カテゴリデータへのアクセスを管理するリポジトリクラス
// VocabularyRepositoryと同様のパターンを使用しています
class CategoryRepository {
  final AppDb _db;

  CategoryRepository(this._db);

  // getAllCategories：すべてのカテゴリデータを取得
  Future<List<VCategoryData>> getAllCategories() async {
    return await _db.select(_db.vCategory).get();
  }

  // getCategoryById：IDを指定して特定のカテゴリデータを取得
  Future<VCategoryData?> getCategoryById(int id) async {
    try {
      return await (_db.select(_db.vCategory)
        ..where((category) => category.id.equals(id)))
          .getSingleOrNull();
    } catch (e) {
      return null;
    }
  }

  // addCategory：新しいカテゴリを追加
  Future<int> addCategory(VCategoryCompanion category) async {
    return await _db.into(_db.vCategory).insert(category);
  }

  // updateCategory：既存のカテゴリを更新
  Future<bool> updateCategory(VCategoryCompanion category) async {
    return await _db.update(_db.vCategory).replace(category);
  }

  // deleteCategory：指定されたIDのカテゴリを削除
  // 注意：外部キー制約により、このカテゴリに属する語彙のcategoryIdはnullになります
  Future<int> deleteCategory(int id) async {
    return await (_db.delete(_db.vCategory)
      ..where((category) => category.id.equals(id)))
        .go();
  }

  // categoryNameExists：指定された名前のカテゴリが既に存在するかをチェック
  // 重複チェックに使用（カテゴリ名はユニークである必要があります）
  Future<bool> categoryNameExists(String name) async {
    final result = await (_db.select(_db.vCategory)
    // WHERE name = ? で検索
      ..where((category) => category.name.equals(name)))
        .get();
    // 結果が空でなければ、既に存在する
    return result.isNotEmpty;
  }
}

// categoryRepositoryProvider：CategoryRepositoryのインスタンスを提供するプロバイダー
@riverpod
CategoryRepository categoryRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepository(db);
}
