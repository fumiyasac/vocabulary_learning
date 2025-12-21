import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_db.dart';
import '../repositories/vocabulary_repository.dart';

part 'vocabulary_provider.g.dart';

class VocabularyState {
  final List<VocabularyData> vocabularies;
  final List<VocabularyData> filteredVocabularies;
  final int? selectedCategoryId;
  final bool isLoading;
  final String? error;

  const VocabularyState({
    this.vocabularies = const [],
    this.filteredVocabularies = const [],
    this.selectedCategoryId,
    this.isLoading = false,
    this.error,
  });

  VocabularyState copyWith({
    List<VocabularyData>? vocabularies,
    List<VocabularyData>? filteredVocabularies,
    int? selectedCategoryId,
    bool? isLoading,
    String? error,
    bool clearCategory = false,
    bool clearError = false,
  }) {
    return VocabularyState(
      vocabularies: vocabularies ?? this.vocabularies,
      filteredVocabularies: filteredVocabularies ?? this.filteredVocabularies,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error,
    );
  }
}

@riverpod
class VocabularyNotifier extends _$VocabularyNotifier {
  @override
  VocabularyState build() {
    _loadVocabularies();
    return const VocabularyState(isLoading: true);
  }

  Future<void> _loadVocabularies() async {
    try {
      final repository = ref.read(vocabularyRepositoryProvider);
      final vocabularies = await repository.getAllVocabularies();
      state = state.copyWith(
        vocabularies: vocabularies,
        filteredVocabularies: vocabularies,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load vocabularies: $e',
      );
    }
  }

  Future<void> loadVocabularies() async {
    await _loadVocabularies();
  }

  void filterByCategory(int? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(
        filteredVocabularies: state.vocabularies,
        clearCategory: true,
      );
    } else {
      final filtered = state.vocabularies
          .where((vocab) => vocab.categoryId == categoryId)
          .toList();
      state = state.copyWith(
        filteredVocabularies: filtered,
        selectedCategoryId: categoryId,
      );
    }
  }

  Future<void> addVocabulary(VocabularyCompanion vocabulary) async {
    try {
      final repository = ref.read(vocabularyRepositoryProvider);
      await repository.addVocabulary(vocabulary);
      await _loadVocabularies();
      if (state.selectedCategoryId != null) {
        filterByCategory(state.selectedCategoryId);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to add vocabulary: $e');
    }
  }

  Future<void> updateVocabulary(VocabularyCompanion vocabulary) async {
    try {
      final repository = ref.read(vocabularyRepositoryProvider);
      await repository.updateVocabulary(vocabulary);
      await _loadVocabularies();
      if (state.selectedCategoryId != null) {
        filterByCategory(state.selectedCategoryId);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update vocabulary: $e');
    }
  }

  Future<void> deleteVocabulary(int id) async {
    try {
      final repository = ref.read(vocabularyRepositoryProvider);
      await repository.deleteVocabulary(id);
      await _loadVocabularies();
      if (state.selectedCategoryId != null) {
        filterByCategory(state.selectedCategoryId);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete vocabulary: $e');
    }
  }

  Future<void> toggleMastered(int id, bool currentStatus) async {
    try {
      final repository = ref.read(vocabularyRepositoryProvider);
      await repository.toggleMastered(id, currentStatus);
      await _loadVocabularies();
      if (state.selectedCategoryId != null) {
        filterByCategory(state.selectedCategoryId);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to toggle mastered: $e');
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
