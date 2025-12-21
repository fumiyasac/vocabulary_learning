import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_db.dart';
import '../providers/database_provider.dart';

part 'vocabulary_repository.g.dart';

class VocabularyRepository {
  final AppDb _db;

  VocabularyRepository(this._db);

  Future<List<VocabularyData>> getAllVocabularies() async {
    return await _db.select(_db.vocabulary).get();
  }

  Future<VocabularyData?> getVocabularyById(int id) async {
    try {
      return await (_db.select(_db.vocabulary)
            ..where((vocabulary) => vocabulary.id.equals(id)))
          .getSingleOrNull();
    } catch (e) {
      return null;
    }
  }

  Future<List<VocabularyData>> getVocabulariesByCategoryId(int categoryId) async {
    return await (_db.select(_db.vocabulary)
          ..where((vocabulary) => vocabulary.categoryId.equals(categoryId)))
        .get();
  }

  Future<int> addVocabulary(VocabularyCompanion vocabulary) async {
    return await _db.into(_db.vocabulary).insert(vocabulary);
  }

  Future<bool> updateVocabulary(VocabularyCompanion vocabulary) async {
    return await _db.update(_db.vocabulary).replace(vocabulary);
  }

  Future<int> deleteVocabulary(int id) async {
    return await (_db.delete(_db.vocabulary)
          ..where((vocabulary) => vocabulary.id.equals(id)))
        .go();
  }

  Future<bool> toggleMastered(int id, bool currentStatus) async {
    final vocabulary = await getVocabularyById(id);
    if (vocabulary == null) return false;

    return await updateVocabulary(
      vocabulary.toCompanion(true).copyWith(
        mastered: Value(!currentStatus),
      ),
    );
  }
}

@riverpod
VocabularyRepository vocabularyRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return VocabularyRepository(db);
}
