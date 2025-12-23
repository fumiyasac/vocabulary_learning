import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_db.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/category_provider.dart';

// AddVocabulary：語彙の追加・編集画面
// ConsumerStatefulWidget：Riverpodの状態監視機能を持つStatefulWidget
// StatefulWidgetは内部状態（フォームの入力値など）を保持できるウィジェット
class AddVocabulary extends ConsumerStatefulWidget {
  // vocabulary：編集する語彙データ（nullの場合は新規追加モード）
  final VocabularyData? vocabulary;

  const AddVocabulary({super.key, this.vocabulary});

  @override
  ConsumerState<AddVocabulary> createState() => _AddVocabularyState();
}

// _AddVocabularyState：AddVocabularyウィジェットの状態を管理するクラス
class _AddVocabularyState extends ConsumerState<AddVocabulary> {
  // _formKey：フォーム全体を識別し、バリデーション（入力チェック）を実行するためのキー
  final _formKey = GlobalKey<FormState>();

  // TextEditingController：テキストフィールドの入力値を管理するコントローラー
  // late：初期化を後回しにする（initStateで初期化）
  late final TextEditingController _wordController;
  late final TextEditingController _definitionController;
  late final TextEditingController _exampleController;

  // _selectedCategory：選択されたカテゴリ（nullの場合はカテゴリなし）
  VCategoryData? _selectedCategory;

  // _isMastered：習得済みフラグ
  bool _isMastered = false;

  // initState：ウィジェットが作成されたときに一度だけ呼ばれる初期化メソッド
  @override
  void initState() {
    super.initState();
    // コントローラーを初期化
    // 編集モードの場合は既存のデータを設定、新規作成の場合は空文字
    _wordController = TextEditingController(text: widget.vocabulary?.word ?? '');
    _definitionController = TextEditingController(text: widget.vocabulary?.definition ?? '');
    _exampleController = TextEditingController(text: widget.vocabulary?.exampleSentence ?? '');
    _isMastered = widget.vocabulary?.mastered ?? false;

    // 編集モードの場合、カテゴリ情報を設定
    if (widget.vocabulary != null) {
      // addPostFrameCallback：ウィジェットが完全に構築された後に実行
      // 最初のビルドが完了するまで待ってから状態を更新する必要がある
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // ref.read()：一度だけプロバイダーの値を読み取る
        final categoryState = ref.read(categoryProvider);
        // 語彙データのcategoryIdに一致するカテゴリを検索
        final category = categoryState.categories
            .where((c) => c.id == widget.vocabulary!.categoryId)
            .firstOrNull;
        // カテゴリが見つかり、かつウィジェットがまだマウントされている場合
        if (category != null && mounted) {
          // setState()：状態を更新してUIを再ビルド
          setState(() {
            _selectedCategory = category;
          });
        }
      });
    }
  }

  // dispose：ウィジェットが破棄されるときに呼ばれるクリーンアップメソッド
  // メモリリークを防ぐため、使わなくなったリソースを解放する
  @override
  void dispose() {
    // TextEditingControllerを破棄（メモリを解放）
    _wordController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.vocabulary == null ? Icons.add_circle_outline : Icons.edit_outlined,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              widget.vocabulary == null ? 'Add Vocabulary' : 'Edit Vocabulary',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Fill in the details to ${widget.vocabulary == null ? 'add' : 'update'} your vocabulary word',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _wordController,
              label: 'Word',
              hint: 'Enter the vocabulary word',
              icon: Icons.text_fields_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Word cannot be empty';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _definitionController,
              label: 'Definition',
              hint: 'Enter the definition',
              icon: Icons.description_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Definition cannot be empty';
                }
                return null;
              },
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _exampleController,
              label: 'Example Sentence',
              hint: 'Enter an example sentence (optional)',
              icon: Icons.format_quote_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.category_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<VCategoryData>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Select a category (optional)',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      ),
                      items: categoryState.categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 1,
              child: CheckboxListTile(
                title: const Text(
                  'Mastered',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Mark if you\'ve mastered this word'),
                value: _isMastered,
                onChanged: (value) {
                  setState(() {
                    _isMastered = value ?? false;
                  });
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isMastered
                        ? Colors.green.withOpacity(0.2)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMastered ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: _isMastered ? Colors.green : Colors.grey,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saveVocabulary,
              icon: Icon(widget.vocabulary == null ? Icons.add_rounded : Icons.save_rounded),
              label: Text(widget.vocabulary == null ? 'Add Vocabulary' : 'Update Vocabulary'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ),
          validator: validator,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
        ),
      ),
    );
  }

  // _saveVocabulary：語彙データを保存するメソッド
  Future<void> _saveVocabulary() async {
    // フォームのバリデーション（入力チェック）を実行
    // validate()：各TextFormFieldのvalidator関数を実行し、エラーがないかチェック
    if (!_formKey.currentState!.validate()) {
      // バリデーションに失敗した場合は処理を中断
      return;
    }

    // VocabularyCompanion：Driftで使用するデータクラス
    // 挿入・更新時にどのフィールドを設定するかを明示的に指定できます
    final vocabularyCompanion = VocabularyCompanion(
      // 編集モードの場合はIDを設定、新規作成の場合はIDを自動採番させる（Value.absent()）
      id: widget.vocabulary != null ? drift.Value(widget.vocabulary!.id) : const drift.Value.absent(),
      // Value()：Driftで値を明示的に設定するためのラッパー
      word: drift.Value(_wordController.text.trim()), // trim()：前後の空白を削除
      definition: drift.Value(_definitionController.text.trim()),
      // 例文が空の場合はnull、それ以外は入力値を設定
      exampleSentence: drift.Value(
        _exampleController.text.trim().isEmpty ? null : _exampleController.text.trim(),
      ),
      categoryId: drift.Value(_selectedCategory?.id), // カテゴリのID（未選択の場合はnull）
      mastered: drift.Value(_isMastered), // 習得フラグ
    );

    // 新規作成モード
    if (widget.vocabulary == null) {
      // vocabularyProviderのnotifierを通じてaddVocabularyメソッドを呼び出す
      await ref.read(vocabularyProvider.notifier).addVocabulary(vocabularyCompanion);
      // context.mounted：ウィジェットがまだ画面に表示されているかをチェック
      // 非同期処理後にウィジェットが破棄されている可能性があるため、必ずチェックが必要
      if (context.mounted) {
        // SnackBar：画面下部に一時的に表示される通知メッセージ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Vocabulary added successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      await ref.read(vocabularyProvider.notifier).updateVocabulary(vocabularyCompanion);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Vocabulary updated successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
