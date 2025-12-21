import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_db.dart';
import '../providers/database_provider.dart';

part 'category_repository.g.dart';

class CategoryRepository {
  final AppDb _db;

  CategoryRepository(this._db);

  Future<List<VCategoryData>> getAllCategories() async {
    return await _db.select(_db.vCategory).get();
  }

  Future<VCategoryData?> getCategoryById(int id) async {
    try {
      return await (_db.select(_db.vCategory)
            ..where((category) => category.id.equals(id)))
          .getSingleOrNull();
    } catch (e) {
      return null;
    }
  }

  Future<int> addCategory(VCategoryCompanion category) async {
    return await _db.into(_db.vCategory).insert(category);
  }

  Future<bool> updateCategory(VCategoryCompanion category) async {
    return await _db.update(_db.vCategory).replace(category);
  }

  Future<int> deleteCategory(int id) async {
    return await (_db.delete(_db.vCategory)
          ..where((category) => category.id.equals(id)))
        .go();
  }

  Future<bool> categoryNameExists(String name) async {
    final result = await (_db.select(_db.vCategory)
          ..where((category) => category.name.equals(name)))
        .get();
    return result.isNotEmpty;
  }
}

@riverpod
CategoryRepository categoryRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepository(db);
}
