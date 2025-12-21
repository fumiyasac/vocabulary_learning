import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_db.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/category_provider.dart';

class AddVocabulary extends ConsumerStatefulWidget {
  final VocabularyData? vocabulary;

  const AddVocabulary({super.key, this.vocabulary});

  @override
  ConsumerState<AddVocabulary> createState() => _AddVocabularyState();
}

class _AddVocabularyState extends ConsumerState<AddVocabulary> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _wordController;
  late final TextEditingController _definitionController;
  late final TextEditingController _exampleController;
  VCategoryData? _selectedCategory;
  bool _isMastered = false;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.vocabulary?.word ?? '');
    _definitionController = TextEditingController(text: widget.vocabulary?.definition ?? '');
    _exampleController = TextEditingController(text: widget.vocabulary?.exampleSentence ?? '');
    _isMastered = widget.vocabulary?.mastered ?? false;

    if (widget.vocabulary != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final categoryState = ref.read(categoryProvider);
        final category = categoryState.categories
            .where((c) => c.id == widget.vocabulary!.categoryId)
            .firstOrNull;
        if (category != null && mounted) {
          setState(() {
            _selectedCategory = category;
          });
        }
      });
    }
  }

  @override
  void dispose() {
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

  Future<void> _saveVocabulary() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vocabularyCompanion = VocabularyCompanion(
      id: widget.vocabulary != null ? drift.Value(widget.vocabulary!.id) : const drift.Value.absent(),
      word: drift.Value(_wordController.text.trim()),
      definition: drift.Value(_definitionController.text.trim()),
      exampleSentence: drift.Value(
        _exampleController.text.trim().isEmpty ? null : _exampleController.text.trim(),
      ),
      categoryId: drift.Value(_selectedCategory?.id),
      mastered: drift.Value(_isMastered),
    );

    if (widget.vocabulary == null) {
      await ref.read(vocabularyProvider.notifier).addVocabulary(vocabularyCompanion);
      if (context.mounted) {
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
