import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/category_provider.dart';
import 'add_vocabulary.dart';
import 'add_category.dart';

// VocabularyHome：アプリのホーム画面
// ConsumerWidget：Riverpodの状態を監視できるウィジェット
// 通常のStatelessWidgetと異なり、refパラメータを通じてプロバイダーにアクセスできます
class VocabularyHome extends ConsumerWidget {
  const VocabularyHome({super.key});

  // build：画面のUIを構築するメソッド
  // WidgetRef ref：Riverpodプロバイダーへのアクセスを提供する参照
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch()：プロバイダーを監視し、状態が変更されたら自動的に再ビルド
    // vocabularyProviderの状態を取得
    final vocabularyState = ref.watch(vocabularyProvider);
    // categoryProviderの状態を取得
    final categoryState = ref.watch(categoryProvider);

    // Scaffold：Material Designの基本的な画面構造を提供するウィジェット
    // AppBar、Body、FloatingActionButtonなどの標準的なレイアウトを簡単に構築できます
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // 背景色をテーマから取得
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.book_rounded, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Vocabulary Learning',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'About',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add New'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
      ),
      body: Column(
        children: [
          if (categoryState.categories.isNotEmpty)
            _buildCategoryFilter(context, ref, categoryState),
          Expanded(
            child: _buildVocabularyList(context, ref, vocabularyState),
          ),
        ],
      ),
    );
  }

  // _buildCategoryFilter：カテゴリフィルターUIを構築するメソッド
  Widget _buildCategoryFilter(BuildContext context, WidgetRef ref, CategoryState categoryState) {
    // ref.read()：プロバイダーのNotifier（メソッド）にアクセス（再ビルドは不要）
    // vocabularyNotifierを取得してfilterByCategoryメソッドを呼び出せるようにする
    final vocabularyNotifier = ref.read(vocabularyProvider.notifier);
    // 現在選択されているカテゴリIDを取得
    final selectedCategoryId = ref.watch(vocabularyProvider).selectedCategoryId;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filter by Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 56,
            // 横スクロール可能なリストビュー（カテゴリチップを表示）
            child: ListView(
              scrollDirection: Axis.horizontal, // 横方向にスクロール
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: [
                // 「All」フィルターチップ（すべての語彙を表示）
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    // selectedCategoryIdがnullなら選択中
                    selected: selectedCategoryId == null,
                    // タップされたら全件表示モードに切り替え
                    onSelected: (_) => vocabularyNotifier.filterByCategory(null),
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                    showCheckmark: true, // チェックマークを表示
                  ),
                ),
                // スプレッド演算子(...)：リストを展開して個別の要素として追加
                // 各カテゴリをFilterChipとして表示
                ...categoryState.categories.map((category) {
                  final isSelected = selectedCategoryId == category.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.name),
                      selected: isSelected,
                      // タップされたらそのカテゴリでフィルタリング
                      onSelected: (_) => vocabularyNotifier.filterByCategory(category.id),
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                      showCheckmark: true,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // _buildVocabularyList：語彙リストのUIを構築するメソッド
  // 状態に応じて異なるUIを表示（読み込み中、空、リスト表示）
  Widget _buildVocabularyList(BuildContext context, WidgetRef ref, VocabularyState state) {
    // 読み込み中の場合：ローディングインジケーターを表示
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CircularProgressIndicator：くるくる回るローディングアニメーション
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading vocabularies...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // データが空の場合：空状態のメッセージを表示
    if (state.filteredVocabularies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.book_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No vocabularies yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start building your vocabulary\nby adding your first word',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ListView.builder：リストを効率的に表示するウィジェット
    // スクロール可能なリストを構築し、画面に表示される項目だけを生成（パフォーマンス最適化）
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      // itemCount：リストの項目数
      itemCount: state.filteredVocabularies.length,
      // itemBuilder：各項目のUIを構築する関数
      // index：現在の項目のインデックス（0から始まる）
      itemBuilder: (context, index) {
        final vocabulary = state.filteredVocabularies[index];
        // 各語彙データのカードウィジェットを返す
        return _buildVocabularyCard(context, ref, vocabulary, index);
      },
    );
  }

  Widget _buildVocabularyCard(BuildContext context, WidgetRef ref, vocabulary, int index) {
    final vocabularyNotifier = ref.read(vocabularyProvider.notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // InkWell：タップ可能な領域を作成し、タップ時にリップルエフェクト（波紋効果）を表示
      child: InkWell(
        // onTap：タップされたときの処理
        onTap: () {
          // Navigator.push：新しい画面に遷移
          // Flutterのナビゲーションは「スタック」構造（画面を積み重ねる）
          Navigator.push(
            context,
            // MaterialPageRoute：Material Designのページ遷移アニメーションを提供
            MaterialPageRoute(
              // builder：遷移先の画面を構築
              // 語彙データを渡して編集画面を開く
              builder: (_) => AddVocabulary(vocabulary: vocabulary),
            ),
          );
        },
        // onLongPress：長押しされたときの処理
        onLongPress: () => _showDeleteDialog(context, ref, vocabulary),
        borderRadius: BorderRadius.circular(16), // リップルエフェクトの範囲を角丸に
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vocabulary.word,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      vocabulary.definition,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    if (vocabulary.exampleSentence != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                vocabulary.exampleSentence!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: vocabulary.mastered,
                  onChanged: (value) {
                    vocabularyNotifier.toggleMastered(
                      vocabulary.id,
                      vocabulary.mastered,
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  activeColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline_rounded),
              SizedBox(width: 12),
              Text('About'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vocabulary Learning App',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Built with Flutter, Riverpod, and Drift',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tips:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Tap a card to edit\n'
                    '• Long press to delete\n'
                    '• Use categories to organize',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.category_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Add Category',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Create a new category'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddCategory()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: Theme.of(context).colorScheme.onSecondary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Add Vocabulary',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Add a new word'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddVocabulary()),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, vocabulary) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Delete Vocabulary'),
          content: Text(
            'Are you sure you want to delete "${vocabulary.word}"?',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(vocabularyProvider.notifier).deleteVocabulary(vocabulary.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Vocabulary deleted'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
