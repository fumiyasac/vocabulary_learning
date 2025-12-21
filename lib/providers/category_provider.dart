import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_db.dart';
import '../repositories/category_repository.dart';

part 'category_provider.g.dart';

class CategoryState {
  final List<VCategoryData> categories;
  final VCategoryData? selectedCategory;
  final bool isLoading;
  final String? error;

  const CategoryState({
    this.categories = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<VCategoryData>? categories,
    VCategoryData? selectedCategory,
    bool? isLoading,
    String? error,
    bool clearSelection = false,
    bool clearError = false,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      selectedCategory: clearSelection ? null : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error,
    );
  }
}

@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  @override
  CategoryState build() {
    _loadCategories();
    return const CategoryState(isLoading: true);
  }

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

  Future<void> loadCategories() async {
    await _loadCategories();
  }

  Future<bool> addCategory(VCategoryCompanion category) async {
    try {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.addCategory(category);
      await _loadCategories();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to add category: $e');
      return false;
    }
  }

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

  void selectCategory(VCategoryData? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearSelection: category == null,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<bool> categoryNameExists(String name) async {
    final repository = ref.read(categoryRepositoryProvider);
    return await repository.categoryNameExists(name);
  }
}
