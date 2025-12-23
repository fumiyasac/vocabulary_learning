import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_db.dart';
import '../repositories/category_repository.dart';

part 'category_provider.g.dart';

// CategoryState：カテゴリデータの状態を保持するクラス
// VocabularyStateと同様の構造を持ちます
class CategoryState {
  // categories：すべてのカテゴリデータ
  final List<VCategoryData> categories;

  // selectedCategory：現在選択されているカテゴリ（編集時などに使用）
  final VCategoryData? selectedCategory;

  // isLoading：データ読み込み中フラグ
  final bool isLoading;

  // error：エラーメッセージ
  final String? error;

  const CategoryState({
    this.categories = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.error,
  });

  // copyWith：状態の一部を変更した新しいインスタンスを作成
  CategoryState copyWith({
    List<VCategoryData>? categories,
    VCategoryData? selectedCategory,
    bool? isLoading,
    String? error,
    bool clearSelection = false, // 選択をクリアするフラグ
    bool clearError = false, // エラーをクリアするフラグ
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      selectedCategory: clearSelection ? null : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error,
    );
  }
}

// CategoryNotifier：カテゴリデータの状態を管理するクラス
@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  @override
  CategoryState build() {
    _loadCategories();
    return const CategoryState(isLoading: true);
  }

  // _loadCategories：データベースからカテゴリデータを読み込む
  Future<void> _loadCategories() async {
    try {
      final repository = ref.read(categoryRepositoryProvider);
      final categories = await repository.getAllCategories();
      state = state.copyWith(
        categories: categories,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load categories: $e',
      );
    }
  }

  // loadCategories：外部から呼び出し可能な再読み込みメソッド
  Future<void> loadCategories() async {
    await _loadCategories();
  }

  // addCategory：新しいカテゴリを追加（成功/失敗をboolで返す）
  Future<bool> addCategory(VCategoryCompanion category) async {
    try {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.addCategory(category);
      await _loadCategories(); // 最新データを再読み込み
      return true; // 成功
    } catch (e) {
      state = state.copyWith(error: 'Failed to add category: $e');
      return false; // 失敗
    }
  }

  // updateCategory：既存のカテゴリを更新
  Future<bool> updateCategory(VCategoryCompanion category) async {
    try {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.updateCategory(category);
      await _loadCategories();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update category: $e');
      return false;
    }
  }

  // deleteCategory：カテゴリを削除
  Future<bool> deleteCategory(int id) async {
    try {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.deleteCategory(id);
      await _loadCategories();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete category: $e');
      return false;
    }
  }

  // selectCategory：カテゴリを選択（または選択解除）
  void selectCategory(VCategoryData? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearSelection: category == null,
    );
  }

  // clearError：エラーメッセージをクリア
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // categoryNameExists：カテゴリ名の重複チェック
  Future<bool> categoryNameExists(String name) async {
    final repository = ref.read(categoryRepositoryProvider);
    return await repository.categoryNameExists(name);
  }
}
