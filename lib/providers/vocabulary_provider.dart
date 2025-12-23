import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_db.dart';
import '../repositories/vocabulary_repository.dart';

part 'vocabulary_provider.g.dart';

// VocabularyState：語彙データの状態を保持するクラス
// Flutterでは、状態（State）を不変（immutable）クラスとして定義するのがベストプラクティス
// 状態を変更する際は、新しいインスタンスを作成します（copyWithメソッドを使用）
class VocabularyState {
  // vocabularies：データベースから取得したすべての語彙データ
  final List<VocabularyData> vocabularies;

  // filteredVocabularies：カテゴリでフィルタリングされた語彙データ
  // UI側はこのリストを表示します
  final List<VocabularyData> filteredVocabularies;

  // selectedCategoryId：現在選択されているカテゴリのID
  // null の場合は「すべて」を表示（フィルタリングなし）
  final int? selectedCategoryId;

  // isLoading：データ読み込み中かどうかのフラグ
  // trueの間はローディングインジケーターを表示
  final bool isLoading;

  // error：エラーメッセージ（エラーがない場合はnull）
  final String? error;

  // constコンストラクタ：コンパイル時定数として扱える（パフォーマンス向上）
  const VocabularyState({
    this.vocabularies = const [],
    this.filteredVocabularies = const [],
    this.selectedCategoryId,
    this.isLoading = false,
    this.error,
  });

  // copyWith：現在の状態の一部を変更した新しいインスタンスを作成するメソッド
  // 不変（immutable）クラスで状態を更新するための標準的なパターン
  VocabularyState copyWith({
    List<VocabularyData>? vocabularies,
    List<VocabularyData>? filteredVocabularies,
    int? selectedCategoryId,
    bool? isLoading,
    String? error,
    bool clearCategory = false, // カテゴリ選択をクリアするフラグ
    bool clearError = false, // エラーをクリアするフラグ
  }) {
    return VocabularyState(
      // ?? 演算子：左側がnullの場合、右側の値を使用（デフォルトは現在の値）
      vocabularies: vocabularies ?? this.vocabularies,
      filteredVocabularies: filteredVocabularies ?? this.filteredVocabularies,
      // clearCategoryがtrueの場合はnullに、それ以外は新しい値または現在の値
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      isLoading: isLoading ?? this.isLoading,
      // clearErrorがtrueの場合はnullに、それ以外は新しい値（または現在の値のまま）
      error: clearError ? null : error,
    );
  }
}

// VocabularyNotifier：語彙データの状態を管理するクラス
// @riverpodアノテーションにより、vocabularyProviderが自動生成されます
// このクラスがアプリのビジネスロジックを担当します
@riverpod
class VocabularyNotifier extends _$VocabularyNotifier {
  // build：初期状態を返すメソッド（プロバイダーが最初にアクセスされたときに呼ばれる）
  @override
  VocabularyState build() {
    // バックグラウンドで語彙データを読み込み開始
    _loadVocabularies();
    // 読み込み中の状態を返す
    return const VocabularyState(isLoading: true);
  }

  // _loadVocabularies：データベースから語彙データを読み込むプライベートメソッド
  Future<void> _loadVocabularies() async {
    try {
      // リポジトリを取得（refは自動的に注入されます）
      final repository = ref.read(vocabularyRepositoryProvider);
      // すべての語彙データを取得
      final vocabularies = await repository.getAllVocabularies();
      // 状態を更新（UIは自動的に再ビルドされます）
      state = state.copyWith(
        vocabularies: vocabularies, // 全データを保存
        filteredVocabularies: vocabularies, // 初期状態ではフィルタリングなし
        isLoading: false, // 読み込み完了
        clearError: true, // エラーをクリア
      );
    } catch (e) {
      // エラーが発生した場合、エラー状態に移行
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load vocabularies: $e',
      );
    }
  }

  // loadVocabularies：外部から呼び出し可能な語彙データ再読み込みメソッド
  // 例：データ追加後にリストを更新する場合に使用
  Future<void> loadVocabularies() async {
    await _loadVocabularies();
  }

  // filterByCategory：カテゴリでフィルタリングするメソッド
  // categoryId: null の場合は全件表示、それ以外は指定カテゴリのみ表示
  void filterByCategory(int? categoryId) {
    if (categoryId == null) {
      // 全件表示モード
      state = state.copyWith(
        filteredVocabularies: state.vocabularies, // すべての語彙を表示
        clearCategory: true, // カテゴリ選択をクリア
      );
    } else {
      // カテゴリフィルタリングモード
      // where()：条件に一致する要素だけを抽出
      final filtered = state.vocabularies
          .where((vocab) => vocab.categoryId == categoryId)
          .toList();
      state = state.copyWith(
        filteredVocabularies: filtered, // フィルタリングされたリストを設定
        selectedCategoryId: categoryId, // 選択中のカテゴリIDを保存
      );
    }
  }

  // addVocabulary：新しい語彙を追加するメソッド
  Future<void> addVocabulary(VocabularyCompanion vocabulary) async {
    try {
      final repository = ref.read(vocabularyRepositoryProvider);
      await repository.addVocabulary(vocabulary); // データベースに追加
      await _loadVocabularies(); // 最新データを再読み込み
      // カテゴリフィルタが有効な場合、フィルタを再適用
      if (state.selectedCategoryId != null) {
        filterByCategory(state.selectedCategoryId);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to add vocabulary: $e');
    }
  }

  // updateVocabulary：既存の語彙を更新するメソッド
  Future<void> updateVocabulary(VocabularyCompanion vocabulary) async {
    try {
      final repository = ref.read(vocabularyRepositoryProvider);
      await repository.updateVocabulary(vocabulary); // データベースを更新
      await _loadVocabularies(); // 最新データを再読み込み
      // カテゴリフィルタが有効な場合、フィルタを再適用
      if (state.selectedCategoryId != null) {
        filterByCategory(state.selectedCategoryId);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update vocabulary: $e');
    }
  }

  // deleteVocabulary：語彙を削除するメソッド
  Future<void> deleteVocabulary(int id) async {
    try {
      final repository = ref.read(vocabularyRepositoryProvider);
      await repository.deleteVocabulary(id); // データベースから削除
      await _loadVocabularies(); // 最新データを再読み込み
      // カテゴリフィルタが有効な場合、フィルタを再適用
      if (state.selectedCategoryId != null) {
        filterByCategory(state.selectedCategoryId);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete vocabulary: $e');
    }
  }

  // toggleMastered：習得状態を切り替えるメソッド
  Future<void> toggleMastered(int id, bool currentStatus) async {
    try {
      final repository = ref.read(vocabularyRepositoryProvider);
      await repository.toggleMastered(id, currentStatus); // 状態を反転
      await _loadVocabularies(); // 最新データを再読み込み
      // カテゴリフィルタが有効な場合、フィルタを再適用
      if (state.selectedCategoryId != null) {
        filterByCategory(state.selectedCategoryId);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to toggle mastered: $e');
    }
  }

  // clearError：エラーメッセージをクリアするメソッド
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
