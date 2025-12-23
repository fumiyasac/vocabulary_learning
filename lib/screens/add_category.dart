import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_db.dart';
import '../providers/category_provider.dart';

// categoryNameControllerProvider：カテゴリ名入力用のTextEditingControllerを提供
// Provider.autoDispose：ウィジェットが破棄されたら自動的にリソースを解放する
// これによりメモリリークを防ぐことができます
final categoryNameControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  // TextEditingControllerを作成
  final controller = TextEditingController();
  // ref.onDispose：プロバイダーが破棄される際のクリーンアップ処理
  // TextEditingControllerを破棄してメモリを解放
  ref.onDispose(controller.dispose);
  return controller;
});

// AddCategory：カテゴリの追加・編集画面
// ConsumerWidget：状態を持たないシンプルな画面（StatelessWidgetにRiverpod機能を追加）
class AddCategory extends ConsumerWidget {
  // category：編集するカテゴリデータ（nullの場合は新規追加モード）
  final VCategoryData? category;

  const AddCategory({super.key, this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // プロバイダーからTextEditingControllerを取得
    final nameController = ref.watch(categoryNameControllerProvider);

    // 編集モードの場合、初期値を設定
    if (category != null) {
      // ビルド完了後に実行（ビルド中は状態を変更できないため）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 空の場合のみ設定（二重設定を防ぐ）
        if (nameController.text.isEmpty) {
          nameController.text = category!.name;
        }
      });
    }

    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category == null ? Icons.add_circle_outline : Icons.edit_outlined,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              category == null ? 'Add Category' : 'Edit Category',
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
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Categories help you organize your vocabulary words into meaningful groups.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.label_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Category Name',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Business, Travel, Technology',
                        prefixIcon: Icon(
                          Icons.category_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Category name cannot be empty';
                        }
                        if (value.trim().length < 2) {
                          return 'Category name must be at least 2 characters';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                      autofocus: true,
                    ),
                  ],
                ),
              ),
            ),
            if (category == null) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Example Categories',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Business',
                  'Travel',
                  'Technology',
                  'Medical',
                  'Academic',
                  'Daily Life',
                  'Science',
                  'Sports',
                ].map((example) {
                  return ActionChip(
                    label: Text(example),
                    onPressed: () {
                      nameController.text = example;
                    },
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _saveCategory(context, ref, formKey),
              icon: Icon(category == null ? Icons.add_rounded : Icons.save_rounded),
              label: Text(category == null ? 'Add Category' : 'Update Category'),
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

  // _saveCategory：カテゴリデータを保存するメソッド
  Future<void> _saveCategory(BuildContext context, WidgetRef ref, GlobalKey<FormState> formKey) async {
    // フォームのバリデーション（入力チェック）を実行
    if (!formKey.currentState!.validate()) {
      return; // バリデーションエラーがある場合は処理を中断
    }

    final nameController = ref.read(categoryNameControllerProvider);
    final categoryName = nameController.text.trim(); // 前後の空白を削除

    // 新規作成モード、または編集モードで名前が変更された場合のみ重複チェック
    // （同じ名前で更新する場合はチェック不要）
    if (category == null || category!.name != categoryName) {
      final categoryNotifier = ref.read(categoryProvider.notifier);
      // カテゴリ名の重複をチェック
      final exists = await categoryNotifier.categoryNameExists(categoryName);

      // 既に同じ名前のカテゴリが存在する場合
      if (exists) {
        if (context.mounted) {
          // エラーメッセージをSnackBarで表示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('A category with this name already exists'),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        // 重複エラーのため処理を中断
        return;
      }
    }

    // VCategoryCompanion：カテゴリデータを挿入・更新するためのクラス
    final categoryCompanion = VCategoryCompanion(
      // 編集モードの場合はIDを設定、新規作成の場合はIDを自動採番
      id: category != null ? drift.Value(category!.id) : const drift.Value.absent(),
      name: drift.Value(categoryName), // カテゴリ名を設定
    );

    final categoryNotifier = ref.read(categoryProvider.notifier);

    // 新規作成モード
    if (category == null) {
      // カテゴリを追加（成功/失敗をboolで取得）
      final success = await categoryNotifier.addCategory(categoryCompanion);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Category added successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Failed to add category'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } else {
      final success = await categoryNotifier.updateCategory(categoryCompanion);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Category updated successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Failed to update category'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }
}
